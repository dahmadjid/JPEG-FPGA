library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_slave is
    
    Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            spi_clk : in STD_LOGIC;
            spi_mosi : in STD_LOGIC;
            spi_miso : out STD_LOGIC;
            spi_cs : in STD_LOGIC;
            rx_data : out STD_LOGIC_VECTOR (511 downto 0);
            rx_valid : out STD_LOGIC;                       -- Data received and ready to be read from rx_data
            tx_data : in STD_LOGIC_VECTOR (511 downto 0);
            tx_load : in STD_LOGIC;
            tx_ready : out STD_LOGIC
          );
end spi_slave;


architecture Behavioral of spi_slave is
signal bit_count: integer range 0 to 511 := 0;
signal rx_reg: std_logic_vector(511 downto 0) := (others => '0');
signal tx_reg: std_logic_vector(511 downto 0) := (others => '0');
signal spi_clk_reg: std_logic_vector(1 downto 0) := "00";
signal spi_clk_rising, spi_clk_falling: std_logic := '0';
signal sending: std_logic := '0';
begin

    -- Detect SPI clock edges
    process(clk, spi_cs, reset)
    begin
    
        if reset = '1' or spi_cs = '1' then
            spi_clk_reg <= "00";
            
        elsif rising_edge(clk) then
            
            spi_clk_reg <= spi_clk_reg(0) & spi_clk;
            
            if spi_clk_reg = "01" then
                spi_clk_rising <= '1';
            else
                spi_clk_rising <= '0';
            end if;
 
            if spi_clk_reg = "10" then
                spi_clk_falling <= '1';
            else
                spi_clk_falling <= '0';
            end if;
 
        end if;
    
    end process;


    process(clk, reset)
    begin
    
        if reset = '1' then
            tx_ready <= '1';
            
        elsif rising_edge(clk) then
        
            if spi_clk_falling = '1' and bit_count = 511 then
                tx_ready <= '1';
                
            elsif tx_load = '1' and sending = '0' then
                tx_reg <= tx_data;
                tx_ready <= '0';
                
            elsif sending = '1' then
                tx_ready <= '0';
                
            end if;
            
        end if;
    
    end process;


    process(clk, spi_cs, reset)
    begin
        
        if reset = '1' or spi_cs = '1' then
            bit_count <= 0;
            rx_reg <= (others => '0');
            rx_data <= (others => '0');
            rx_valid <= '0';
            sending <= '0';
            spi_miso <= 'Z';
            
        elsif rising_edge(clk) then
            
            
            if spi_clk_rising = '1' then
                rx_reg(511 - to_integer(bit_count)) <= spi_mosi;

            end if;
            
            
            if spi_clk_falling = '1' then
            
                if bit_count = 511 then
                    bit_count <= 0;
                else
                    bit_count <= bit_count + 1;
                end if;
            
            end if;
            
            
            if spi_clk_falling = '1' and bit_count = 511 then
                rx_data <= rx_reg;
                rx_valid <= '1';
                
            else
                rx_valid <= '0';
                
            end if;
            
            
            if spi_clk_rising = '1' then
                sending <= '1';
            
            elsif spi_clk_falling = '1' and bit_count = 511 then
                sending <= '0';
                
            end if;


            spi_miso <= tx_reg(511 - to_integer(bit_count));
            
        end if;
    
    end process;


end Behavioral;
