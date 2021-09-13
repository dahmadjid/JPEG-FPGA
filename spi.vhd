library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Tested on FPGA
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
    signal sck_s : std_logic := '0';
    signal data_rx_reg : std_logic_vector(7 downto 0) := "00000000";
    signal data_tx_reg : std_logic_vector(7 downto 0) := "00000000";
    signal bit_count : integer range 0 to 8 := 0;
    signal mosi_busy : std_logic:='0';
    signal miso_busy : std_logic:='0';
    signal data_tx_rdy_s : std_logic;
    signal cs_s :std_logic := '1';
    signal start_delay_count: integer range 0 to 3 := 0;
    signal end_delay_count: integer range 0 to 3 := 0;
    signal transmission_start :std_logic := '0';
    signal transmission_over :std_logic := '1';
    signal data_tx_s: unsigned(7 downto 0) := "00000000";
begin

start_delay : process(clock,cs_s,start_delay_count,transmission_start)
begin
    if cs_s = '1' then
        start_delay_count <= 0;
        transmission_start <= '0';
    elsif rising_edge(clock) and cs_s = '0' then 
        if start_delay_count = 3 then
            transmission_start <= '1';
        elsif transmission_start = '0' then
            start_delay_count <= start_delay_count + 1;
        end if; 
   end if ;
end process ; -- delay

end_delay : process(clock,end_delay_count,transmission_over,bit_count)
begin
    if bit_count /= 8  then
        end_delay_count <= 0;
        transmission_over <= '0';
    elsif rising_edge(clock) and cs_s = '0' then 
        if end_delay_count = 3 then
            transmission_over <= '1';
            
        elsif transmission_over = '0' then
            end_delay_count <= end_delay_count + 1;
        
        end if;
   end if ;
end process ; -- delay

--chip select 
chip_select : process(data_tx_rdy,end_delay_count)
begin
    if end_delay_count  = 3 then
        cs_s <= '1';

    elsif falling_edge(data_tx_rdy)    then
        cs_s <= '0';


    end if;
end process ; -- chip_select

-- spiclk gen (divide by 10 to get 5mhz)
spiclk_gen:process(clock,clr)
begin          
    if clr = '0' then
        sck_s <= '0';
        clock_count <= 0;
    elsif rising_edge(clock) and start_delay_count = 3 and end_delay_count = 0 then 
        if clock_count = 9 then
            clock_count <= 0;
            sck_s <= not sck_s;
        else
            clock_count <= clock_count + 1; 
        end if;
    end if;
end process;

-- bit count 
bit_count_pr : process(cs_s,sck_s,clr)
begin
    if clr = '0' or cs_s ='1' then
        bit_count <= 0;
    elsif falling_edge(sck_s) and cs_s = '0' and bit_count /= 8 then
        bit_count <= bit_count + 1;
    end if ;
end process ; -- bit_count_pr
data_tx_s_pr : process(cs_s)
begin
    if rising_edge(cs_s) then
        data_tx_s <= data_tx_s + 1;
    end if;
end process ; -- data_tx_s_pr
--mosi
mosi_pr : process(sck_s)
begin
    if bit_count = 8 then
        mosi_busy <= '0';
    elsif rising_edge(sck_s) and mosi_busy = '0' then
        mosi_busy <= '1';
        data_tx_reg <= std_logic_vector(data_tx_s(7 downto 0));
    elsif rising_edge(sck_s) and mosi_busy = '1' then
        data_tx_reg <= data_tx_reg(6 downto 0)&'0';
    end if; 

end process ; -- mosi
--miso 
miso_pr : process(sck_s,clr)
begin
    if clr = '0' then
        miso_busy <= '0';
        data_rx_reg <= "00000000";
    elsif falling_edge(sck_s) then
        data_rx_reg <= data_rx_reg(6 downto 0) & miso;
    end if;
end process ; -- miso_pr

data_rx_rdy_pr : process(clock,bit_count)
begin
    if bit_count = 8 then
        data_rx_rdy <= '1';
    elsif rising_edge(sck_s) then
        data_rx_rdy <= '0';
    end if;
end process ; -- miso_data_rdy

data_rx <= data_rx_reg;
cs <= cs_s;
vcc <= '1';
gnd <= '0';
sck <= sck_s;
mosi <= data_tx_reg(7);
end arch ; -- arch

