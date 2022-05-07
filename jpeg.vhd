library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;



entity jpeg is
generic (
    width : natural := 16;
    height : natural := 16);
port(clock,start : in std_logic;

    jpeg_start : in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    -- clock_delay_n : in std_logic;
    -- hex_0,hex_1,hex_2,hex_3,hex_4,hex_5 : out std_logic_vector(6 downto 0);
    -- data_out: out std_logic_vector(7 downto 0);

    -- handshake : in std_logic;
    sck : out std_logic;
    mosi :out std_logic;
    miso :in std_logic;
    cs :out std_logic);
end jpeg; 

architecture arch of jpeg is
    type state_t is (idle,converting,dct,encoding, final, delay_state);
    signal address : std_logic_vector(17 downto 0);
    signal address_bid : integer range 0 to 262144;
    shared variable address_rgb_ycbcr,address_dct,address_encoding : std_logic_vector(17 downto 0);
    shared variable data_rgb_ycbcr,data_dct,data_encoding : std_logic_vector(7 downto 0);
    signal v,u : unsigned(2 downto 0);
    signal rw_counter : integer range 0 to 11:= 0; 
    signal pixel_array : pixel_array_t;
    --read write counter for 0-11 read : r,g,b and then 6-11 :write y,cb,cr even are for addressing and odd for reading q. dct_clock cant be 50mhz. slow but it works idc at this point.
    
    signal clock_count,clock_count_2: integer range 0 to 50 := 0;
    signal present_state : state_t;
    signal next_state : state_t;
    signal image_index_count,index_count : integer range 0 to 49151:= 0;
    shared variable r,g,b : unsigned(7 downto 0):= "00000000";
    signal y,cb,cr,y_reg,cb_reg,cr_reg ,encoding_data_out: sfixed(7 downto 0);
    signal wren,wren_rgb_ycbcr,wren_dct,image_converted,image_index_clock,clock_delay,wren_encoding,encoding_done: std_logic := '0';
    signal data,q,converting_data_out : std_logic_vector(7 downto 0);
    signal jpeg_over,dct_working,code_ready: std_logic := '0';
    signal img_pixel : sfixed(7 downto 0);
    signal v_in,u_in : unsigned(2 downto 0);
    signal hex_out,dct_coeff_block,dct_coeff_block_qz : dct_coeff_block_t;
    signal dct_read_counter : integer range 0 to 1 := 0;
    signal dct_clock,clock_delay_2 :std_logic := '0';
    signal block_index_count : integer range 0 to 1024 := 0;
    signal dct_start : std_logic:= '1'; 
    signal hex_5_data,hex_4_data,hex_3_data,hex_2_data,hex_1_data,hex_0_data : std_logic_vector(3 downto 0);
    signal dct_coeff_zz,dct_coeff_zz_temp : dct_coeff_zz_t;
    signal huff_value_zz : huff_value_zz_t; 
    signal length_zz : length_zz_t;
    signal old_dc_reg, old_dc_reg_y, old_dc_reg_cb, old_dc_reg_cr : sfixed(10 downto 0) := "00000000000";
    signal length : integer range 0 to 512;
    signal l : std_logic := '0';
    signal huff_code_table : huff_code_table_t;
    
    signal encoder_clr: std_logic;
    signal encoded_block, encoded_block_s : std_logic_vector(511 downto 0);

    signal encoding_writing_switch ,writing_done: std_logic := '0';

    signal count:integer range 0 to 63 := 0;

    signal spi_rx_data, img_pixel_temp : std_logic_vector(511 downto 0);
    signal spi_tx_load ,rx_valid: std_logic;
    signal spi_clr, transmission_over : std_logic; 
    signal block_sent : integer;
    signal delay_state_counter : integer;


    signal channel: integer range 0 to 3;
    signal row_block_index : integer range 0 to height / 8;
    signal col_block_index : integer range 0 to width / 8;
    signal increment_block_counter, image_covered, delay_done :std_logic;
    signal dct_coeff_zz_0, dct_coeff_zz_1, dct_coeff_zz_2, dct_coeff_zz_3, dct_coeff_zz_4, dct_coeff_zz_5, dct_coeff_zz_6, dct_coeff_zz_7, dct_coeff_zz_8, dct_coeff_zz_9, dct_coeff_zz_10, dct_coeff_zz_11 : dct_coeff_zz_t;
    
begin

delayed_clock : process(clock)
begin
if rising_edge(clock) then
    if present_state = idle then
        clock_delay <= '0';
        clock_count <= 0;
    elsif clock_count = 1 then     --1/4 of clock is necessary, i tried 1/2 and its corrupted data when writing to bram
        clock_delay <= not clock_delay;
        clock_count <= 0;
    else
        clock_count <= clock_count + 1;
    end if;
end if;
end process ; -- dct_clock

spi: spi_master generic map(512) port map(clock, '1', encoded_block_s, spi_tx_load, spi_rx_data, rx_valid, sck, mosi, miso, cs); -- 5120 clock cycles

--------------------------------------- DCT STATE -----------------------------------------
block_index : process( clock )
begin
    if present_state = idle then
        row_block_index <= 0;
        col_block_index <= 0;
        channel <= 3;
        image_covered <= '0';
    elsif rising_edge(increment_block_counter) and image_covered = '0' then
        if channel = 3 then
            channel <= 0;
        elsif channel = 2 then
            channel <= 0;
        else 
            channel <= channel + 1;
            image_covered <= '0';
        end if;
    end if;
end process ; -- block_index


-- pixel_ind : pixel_indexer port map(spi_rx_data, index_count, img_pixel);

-- pixel_pr : process(clock_delay, present_state)
-- variable img_pixel_temp : std_logic_vector(511 downto 0);
-- begin
--     if rising_edge(clock_delay)  then
--         if present_state /= dct then
--             dct_read_counter <= 0;
--             dct_clock <= '0';
--             index_count <= 0;
--         elsif dct_working = '1' then
--             case dct_read_counter is
--                 when 0 =>
--                     dct_clock <= '0';
--                     dct_read_counter <= 1;
--                 when 1 => 
--                     dct_clock <= '1';
--                     dct_read_counter <= 0;
--                     index_count <= index_count + 1;
--             end case;
--         end if;     
--     end if; 
-- end process ; -- pixel_pr

-- dct_comp : dct_block port map(dct_clock, dct_start, dct_working, img_pixel, dct_coeff_block);
-- quant_comp : quantizer port map(dct_coeff_block, channel, dct_coeff_block_qz);
-- zigzag_comp : zigzag port map(dct_coeff_block_qz, dct_coeff_zz);

-------------------------------------------------------------------------------------------

-------------------------------------ENCODING STATE----------------------------------------

-- -- dct_coeff_zz <= ("00000011101", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_0 <= ("00000000000", "00000011110", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_1 <= ("00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_2 <= ("00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_3 <= ("00000111111", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_4 <= ("00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_5 <= ("00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_6 <= ("11111001100", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_7 <= ("00000101010", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_8 <= ("11111111011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_9 <= ("11111101011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_10 <= ("11111110000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
dct_coeff_zz_11 <= ("11111100100", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");

-- -- channel = 0
-- dct_coeff_zz_0 <= ("00000000000", "00001010100", "00000000000", "11111101100", "00000000000", "00000000101", "00000000000", "11111111101", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 1
-- dct_coeff_zz_1 <= ("00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 2
-- dct_coeff_zz_2 <= ("00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 0
-- dct_coeff_zz_3 <= ("00000001011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000101011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "11111110011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000101", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "11111111111", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 1
-- dct_coeff_zz_4 <= ("11111011000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "11111110000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000010", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 2
-- dct_coeff_zz_5 <= ("00000100001", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "11111101011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000010", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 0
-- dct_coeff_zz_6 <= ("11111001100", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 1
-- dct_coeff_zz_7 <= ("00000101010", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 2
-- dct_coeff_zz_8 <= ("11111111011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 0
-- dct_coeff_zz_9 <= ("11111101011", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 1
-- dct_coeff_zz_10 <= ("11111110000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");
-- -- channel = 2
-- dct_coeff_zz_11 <= ("11111100100", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000");

dct_coeff_zz <= dct_coeff_zz_0 when block_sent = 0 else dct_coeff_zz_1 when block_sent = 1 else dct_coeff_zz_2 when block_sent = 2 else dct_coeff_zz_3 when block_sent = 3 else dct_coeff_zz_4 when block_sent = 4 else dct_coeff_zz_5 when block_sent = 5 else dct_coeff_zz_6 when block_sent = 6 else dct_coeff_zz_7 when block_sent = 7 else dct_coeff_zz_8 when block_sent = 8 else dct_coeff_zz_9 when block_sent = 9 else dct_coeff_zz_10 when block_sent = 10 else dct_coeff_zz_11 when block_sent = 11 else dct_coeff_zz_0;

delayed_clock_pr : process(clock) 
begin
if present_state /= encoding then
    clock_count_2 <= 0;
    clock_delay_2 <= '0';
elsif rising_edge(clock) then
    if clock_count_2 = 4 then    
        clock_delay_2 <= not clock_delay_2;
        clock_count_2 <= 0;
    else
        clock_count_2 <= clock_count_2 + 1;
        
    end if;
end if;
end process ; -- dct_clock  

encoder_comp : encoder port map(clock_delay_2, encoder_clr, increment_block_counter, channel, dct_coeff_zz,encoding_done, length, encoded_block); -- 138 upto 640 clock cycles
encoded_block_s <= std_logic_vector(to_unsigned(length, 16)) & encoded_block(511 downto 16);

-- encoded_block_s(511 downto 501) <= std_logic_vector(dct_coeff_zz(0));
-- encoded_block_s(500 downto 490) <= std_logic_vector(dct_coeff_zz(1));
-- encoded_block_s(489 downto 479) <= std_logic_vector(dct_coeff_zz(2));
-- encoded_block_s(478 downto 468) <= std_logic_vector(dct_coeff_zz(3));
-- encoded_block_s(467 downto 457) <= std_logic_vector(dct_coeff_zz(4));
-- encoded_block_s(456 downto 446) <= std_logic_vector(dct_coeff_zz(5));
-- encoded_block_s(445 downto 0) <= (others => '0');




encoder_controller : process(clock)
begin
    if present_state /= encoding then
        spi_tx_load <= '1';
        encoder_clr <= '0';
        transmission_over <= '0';
    elsif rising_edge(clock)  then
        
        if encoding_done = '1' and spi_tx_load = '1' and rx_valid = '1' then
            spi_tx_load <= '0';   -- 1st clock cycle
            encoder_clr <= '1';
            transmission_over <= '0';
        elsif encoding_done = '1' and spi_tx_load = '0' and rx_valid = '1' then
            spi_tx_load <= '1';   -- 2nd clock cycle
            encoder_clr <= '0';
            transmission_over <= '1';
        else
            encoder_clr <= '1';

        end if ; 
    end if;
end process ; -- encoder_controller


block_transmitted_counter_pr : process( clock )
begin
    if present_state = idle then
        block_sent <= 0;
    elsif rising_edge(spi_tx_load) then
        if channel < 3 then
            block_sent <= block_sent + 1;
        end if;
    end if;
end process ; -- block_transmitted_counter

-------------------------------------DELAY STATE----------------------------------------
delay_state_counter_pr : process(clock)
begin
    if present_state /= delay_state then
        delay_state_counter <= 0;
        delay_done <= '0';
    elsif rising_edge(clock) then
        if delay_state_counter = 500000 then
            delay_done <= '1';
        else
            delay_done <= '0';
            delay_state_counter <= delay_state_counter + 1;
        end if;
    end if;
end process ; -- delay_state_counter
---------------------------------------------------------------------------------------------
present_state_pr : process(clock)
    begin
        if falling_edge(clock) then
            if data_in(0) = '1' then
                present_state <= next_state;
            else 
                present_state <= idle;
            
            end if;
        end if;
    end process;


next_state_pr : process(present_state,image_converted,dct_working,encoding_done)
    begin 
        case present_state is
            when idle => 
                if block_sent = 0 then
                    next_state <= encoding;
                else 
                    next_state <= idle;
                end if;
            when converting =>
                if image_converted = '1' then
                    next_state <= dct;
                else 
                    next_state <= converting;
                end if;
            when dct => 
                if dct_working = '1' then
                    next_state <= dct;
                else
                    next_state <= encoding;
                end if;
            when encoding =>
                if transmission_over = '1' then
                    next_state <= delay_state;  
                else
                    next_state <= encoding;
                end if;

            when delay_state =>
                if delay_done = '1' then
                    if image_covered = '1'  then
                        next_state <= final;
                    else
                        next_state <= encoding;
                    end if;
                else
                    next_state <= delay_state;
                end if;
            when final =>
                next_state <= final;
        end case;
end process;

-- v <= unsigned(data_in(5 downto 3));
-- u <= unsigned(data_in(2 downto 0));
-- data_out <= std_logic_vector(pixel_array(to_integer(unsigned(data_in))));
-- encoding_data_out <= "11000000" srl to_integer(unsigned(data_in(7 downto 5)));
outputs_fsm_pr : process(present_state)
begin
    case present_state is 
        when idle => 
            -- data_out <= x"00";
            dct_start <= '1';
            spi_clr <= '1';
            increment_block_counter <= '0';
        when converting =>
            -- data_out <= "10101000";
            dct_start <= '1';
            spi_clr <= '1';
            increment_block_counter <= '0';
        when dct => 
            -- data_out <= "10000001";
            dct_start <= '0';
            spi_clr <= '1';
            increment_block_counter <= '0';
        when encoding =>
            -- data_out <= x"00";
            dct_start <= '1';
            spi_clr <= '1';
            increment_block_counter <= '0';
        when final =>
            dct_start <= '1';
            -- data_out <= (others => '1');
            spi_clr <= '1';
            increment_block_counter <= '0';
        when delay_state =>
            dct_start <= '1';
            -- data_out <= "00001111";
            spi_clr <= '1';
            increment_block_counter <= '1';
    end case;
end process;

end arch ; 

