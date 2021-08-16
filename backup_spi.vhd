library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity spi_master is
  port (
    clock :in std_logic;
    clr : in std_logic;

    data_tx : in std_logic_vector(7 downto 0);  -- data to be sent
    data_tx_rdy : in std_logic; -- data ready to be written from data_tx register and starts the transimision in the next clock cycle

    --data_reg : out std_logic_vector(7 downto 0);

    data_rx : out std_logic_vector(7 downto 0);  -- data recieved from slave
    data_rx_rdy : out std_logic; -- data ready to be read from data_rx register
    
    vcc: out std_logic;
    gnd: out std_logic;
    sck : out std_logic;
    mosi :out std_logic;
    miso :in std_logic;
    cs :out std_logic

  ) ;
end spi_master;

architecture arch of spi_master is
    signal clock_count: integer range 0 to 9;
    signal start_delay_count: integer range 0 to 3;
    signal end_delay_count: integer range 0 to 3;
    signal sck_s : std_logic;
    signal data_rx_reg : std_logic_vector(7 downto 0);
    signal data_tx_reg : std_logic_vector(7 downto 0);
    shared variable bit_count : integer range 0 to 8 := 0;
    signal mosi_busy : std_logic;
    signal miso_busy : std_logic;
    signal transmit_start : std_logic;
    signal data_tx_rdy_s : std_logic;
    signal cs_s :std_logic := '1';
    signal transmission_start :std_logic := '0';
    signal transmission_over :std_logic := '1';
   
begin
--chip select 
chip_select : process(clock,data_tx_rdy,miso_busy)
begin
    if clr = '0' then
        transmission_over <= '1';
    elsif bit_count = 8 and miso_busy = '0' then
        transmission_over <= '1';
        if rising_edge(clock) then
            if cs_s = '1' then
                end_delay_count <= 0;
            else
                end_delay_count <=  end_delay_count + 1;
            end if;
        end if;


    elsif end_delay_count = 3 then
        cs_s <= '1';

    elsif falling_edge(data_tx_rdy)    then
        cs_s <= '0';
        transmission_over <= '0';
    end if;
end process ; -- chip_select

    -- spiclk gen (divide by (clock_count+1)*2 )

spiclk_gen:process(clock,clr,transmission_over)
begin          
    if clr = '0' then
        sck_s <= '0';
        clock_count <= 0;
        
    elsif transmission_over = '1' then
        start_delay_count <= 0;
        transmission_start <= '0';
    elsif rising_edge(clock) and transmission_over = '0' then 
        if start_delay_count = 3 then
            transmission_start <= '1';
            if clock_count = 9 then
                clock_count <= 0;
                sck_s <= not sck_s;
            else
                clock_count <= clock_count + 1;
            end if;
        else
           start_delay_count <=  start_delay_count + 1;
        end if;
    end if;
end process;


-- bit count 
bit_count_pr : process(start_delay_count,sck_s,clr)
begin
    if clr = '0'  then
        bit_count := 0;
    elsif rising_edge(sck_s) and transmission_over = '0' then
        bit_count := bit_count + 1;
    end if ;
end process ; -- bit_count_pr

--mosi
mosi_pr : process(sck_s,clr)
begin
    if clr = '0' then 
        data_tx_reg <= "00000000";
        mosi_busy <= '0';
    elsif rising_edge(sck_s) and mosi_busy = '0' then
        mosi <= data_tx(7);
        data_tx_reg <= data_tx_reg(6 downto 0)&'0';
        mosi_busy <= '1';
    elsif rising_edge(sck_s) and mosi_busy ='1' then
        mosi <= data_tx_reg(7);
        data_tx_reg <= data_tx_reg(6 downto 0)&'0';
        if bit_count = 8 then
            mosi_busy <= '0';
            
        end if;

    end if; 

end process ; -- mosi
--miso 
miso_pr : process(sck_s,clr)
begin
    if clr = '0' then
        miso_busy <= '0';
        data_rx_rdy <= '0';
        data_rx_reg <= "00000000";
    elsif falling_edge(sck_s) and miso_busy = '0' then
        miso_busy <= '1';
        data_rx_rdy <= '0';
        data_rx_reg <= data_rx_reg(6 downto 0) & miso;
    elsif falling_edge(sck_s) and miso_busy = '1' then
        data_rx_reg <= data_rx_reg(6 downto 0) & miso;
        if bit_count = 8 and mosi_busy = '0' then
            data_rx_rdy <= '1';
            miso_busy <= '0';
        end if;
    end if;
end process ; -- miso_pr
data_rx <= data_rx_reg;
cs <= cs_s;
vcc <= '1';
gnd <= '0';
sck <= sck_s;
end arch ; -- arch

