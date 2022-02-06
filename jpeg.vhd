library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;


entity jpeg is
generic (
    width : natural := 256;
    height : natural := 192);
port(clock,start : in std_logic;

    jpeg_start : in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    clock_delay_n : in std_logic;
    hex_0,hex_1,hex_2,hex_3,hex_4,hex_5 : out std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(7 downto 0);


    sck : out std_logic;
    mosi :out std_logic;
    miso :in std_logic;
    cs :out std_logic);
end jpeg; 

architecture arch of jpeg is
    type state_t is (idle,converting,dct,encoding, final);
    signal address : std_logic_vector(17 downto 0);
    signal address_bid : integer range 0 to 262144;
    shared variable address_rgb_ycbcr,address_dct,address_encoding : std_logic_vector(17 downto 0);
    shared variable data_rgb_ycbcr,data_dct,data_encoding : std_logic_vector(7 downto 0);
    signal v,u : unsigned(2 downto 0);
    signal rw_counter : integer range 0 to 11:= 0; 
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
    shared variable img_pixel : sfixed(7 downto 0);
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
    signal old_dc_reg : sfixed(10 downto 0) := "00000000000";
    signal length : integer range 0 to 512;
    signal l : std_logic := '0';
    signal huff_code_table : huff_code_table_t;
    
    signal encoder_clr: std_logic;
    signal encoded_block : std_logic_vector(511 downto 0);

    signal encoding_writing_switch ,writing_done: std_logic := '0';

    signal count:integer range 0 to 63 := 0;

    signal spi_rx_data : std_logic_vector(511 downto 0);
    signal spi_tx_load ,rx_valid: std_logic;
    signal spi_clr : std_logic; 
    signal block_sent : integer range 0 to 511;
begin

--jpeg_start_pr : process( start )
-- begin
--     if image_converted = '1' then 
--         jpeg_start <= '0';
--     elsif falling_edge(start) then
--         jpeg_start <= '1';
--     end if;
-- end process ; -- jpeg_start_pr

-- delayed_clock : process(clock)
-- begin
-- if rising_edge(clock) then
--     if present_state = idle then
--         clock_delay <= '0';
--         clock_count <= 0;
--     elsif clock_count = 1 then     --1/4 of clock is necessary, i tried 1/2 and its corrupted data when writing to bram
--         clock_delay <= not clock_delay;
--         clock_count <= 0;
--     else
--         clock_count <= clock_count + 1;
--     end if;
-- end if;
-- end process ; -- dct_clock

-- bram_comp : bram_ip port map (address,clock,data,wren,q);




-- ----------------------------------- CONVERTING STATE -------------------------------------
-- image_index_count_clock_pr : process(clock_delay,present_state)
--     begin
--     if present_state /= converting then
--         rw_counter <= 0;
--         image_index_clock <= '0';
--     elsif falling_edge(clock_delay) then
--         if rw_counter = 5 then
--             image_index_clock <= '1';
--             rw_counter <= 6;
--         elsif rw_counter = 11 then
--             image_index_clock <= '0';
--             rw_counter <= 0;    
--         else
--             rw_counter <= rw_counter + 1; 
--         end if;
--     end if;
-- end process;

-- image_index_count_pr : process(image_index_clock,present_state) 
--     begin
--     if present_state /= converting then
--         image_index_count <= 0;
--     elsif falling_edge(image_index_clock) then
--         if image_index_count = (height * width) then
--             image_converted <= '1';
--         elsif present_state = converting then
--             image_index_count <= image_index_count + 1;
--         end if;
--     end if;
-- end process;

-- rgb_ycbcr_pr :process(clock_delay,present_state)
--     begin
--     if rising_edge(clock_delay) and present_state = converting then
--         case rw_counter is
--             when 0 => 
--                 wren_rgb_ycbcr <= '0';
--                 address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count,18));
--             when 1 =>
--                 r := unsigned(q);
--                 converting_data_out <= std_logic_vector(r);
--             when 2 => 
--                 wren_rgb_ycbcr <= '0';
--                 address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width ,18));
--             when 3 =>
--                 g := unsigned(q); 
--                 converting_data_out <= std_logic_vector(g);
--             when 4 => 
--                 wren_rgb_ycbcr <= '0';
--                 address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width * 2 ,18));
--             when 5 =>
--                 b := unsigned(q); 
--                 converting_data_out <= std_logic_vector(b); 
--             when 6 => 
--                 wren_rgb_ycbcr <= '1';
--                 address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count,18));
--             when 7 =>
--                 data_rgb_ycbcr := std_logic_vector(y);  
--                 converting_data_out <= std_logic_vector(y);     
--             when 8 => 
--                 wren_rgb_ycbcr <= '1';
--                 address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width ,18));
--             when 9 =>
--                 data_rgb_ycbcr := std_logic_vector(cb);
--                 converting_data_out <= std_logic_vector(cb);
--             when 10 => 
--                 wren_rgb_ycbcr <= '1';
--                 address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width * 2 ,18));
--             when 11 =>
--                 data_rgb_ycbcr := std_logic_vector(cr);
--                 converting_data_out <= std_logic_vector(cr);
--         end case;
--     end if;
-- end process;

-- rgb_ycbcr_conversion_pr :process(clock,present_state)   
--     variable rs,gs,bs,y_temp,cb_temp,cr_temp: unsigned(23 downto 0);
--     variable y_temp2,cb_temp2,cr_temp2 : unsigned(7 downto 0);
--     begin
        
--         if rising_edge(clock) and present_state = converting then
--             rs :=x"0000"&r;
--             gs :=x"0000"&g;
--             bs :=x"0000"&b;

--             y_temp := (((rs sll 14)+(rs sll 11)+(rs sll 10)+(rs sll 7)+(rs sll 3)+(rs sll 2)+(rs sll 1)+(gs sll 15)+(gs sll 12)+(gs sll 10)+(gs sll 9)+(gs sll 6)+(gs sll 2)+(bs sll 12)+(bs sll 11)+(bs sll 10)+(bs sll 8)+(bs sll 5)+(bs sll 3)+(bs sll 2)+(bs sll 1)) srl 16) - "10000000";
--             cb_temp := ((bs sll 15)-(rs sll 13)-(rs sll 11)-(rs sll 9)-(rs sll 8)-(rs sll 5)-(rs sll 4)-(rs sll 1)-(gs sll 14)-(gs sll 12)-(gs sll 10)-(gs sll 7)-(gs sll 6)-(gs sll 2)) srl 16;
--             cr_temp := ((rs sll 15)-(gs sll 14)-(gs sll 13)-(gs sll 11)-(gs sll 9)-(gs sll 8)-(gs sll 5)-(gs sll 3)-(gs sll 2)-(gs sll 1)-(bs sll 12)-(bs sll 10)-(bs sll 7)-(bs sll 6)-(bs sll 4)) srl 16;

--             y_temp2 := y_temp(7 downto 0);
--             cb_temp2 := cb_temp(7 downto 0);
--             cr_temp2 := cr_temp(7 downto 0);
        
            
--             y  <= to_sfixed(std_logic_vector(y_temp2),7,0);
--             cb <= to_sfixed(std_logic_vector(cb_temp2),7,0);
--             cr <= to_sfixed(std_logic_vector(cr_temp2),7,0);
--         end if;
-- end process;
-- -------------------------------------------------------------------------------------------

-- --------------------------------------- DCT STATE -----------------------------------------

-- bid_comp : block_index_decoder port map(to_unsigned(index_count,6),0,0,width,height,0,address_bid);
-- process(clock)
-- begin
--     address_dct := std_logic_vector(to_unsigned(address_bid,18));
-- end process;
-- pixel_pr : process(clock_delay,present_state)
-- begin
    
--     if rising_edge(clock_delay) then
--         if present_state /= dct then
--             dct_read_counter <= 0;
--             dct_clock <= '0';
--             index_count <= 0;
--         elsif dct_working = '1' then
--             case dct_read_counter is
--                 when 0 =>
--                     wren_dct <= '0';
--                     dct_clock <= '0';
--                     dct_read_counter <= 1;
--                 when 1 => 
--                     wren_dct <= '0';
--                     dct_clock <= '1';
--                     dct_read_counter <= 0;
--                     index_count <= index_count + 1;
--             end case;
--         end if;     
--     end if; 
-- end process ; -- pixel_pr

-- dct_comp : dct_block port map(dct_clock,dct_start,dct_working,img_pixel,dct_coeff_block);
-- y_quant_comp : y_quantizer port map(dct_coeff_block,dct_coeff_block_qz);
-- -- cb_quant_comp : cb_quantizer port map(dct_coeff_block,dct_coeff_block_qz);
-- -- cr_quant_comp : cr_quantizer port map(dct_coeff_block,dct_coeff_block_qz);
-- zigzag_comp : zigzag port map(dct_coeff_block_qz,dct_coeff_zz);

-------------------------------------------------------------------------------------------

-------------------------------------ENCODING STATE----------------------------------------
dct_coeff_zz <= ("00000011101", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000000", "00000000001", "00000000000");
old_dc_reg_pr : process( encoding_done,present_state )
begin  
    if present_state = idle then
        old_dc_reg <= "00000000000";
    elsif rising_edge(encoding_done) then
        old_dc_reg <= dct_coeff_zz(0);
    end if;
end process ; -- old_dc_reg_pr

delayed_clock_pr : process(clock)
begin
if present_state /= encoding then
    clock_count_2 <= 0;
    clock_delay_2 <= '0';
elsif rising_edge(clock) then
    if clock_count_2 = 1 then    
        clock_delay_2 <= not clock_delay_2;
        clock_count_2 <= 0;
    else
        clock_count_2 <= clock_count_2 + 1;
        
    end if;
end if;
end process ; -- dct_clock  


encoder_comp : encoder port map(clock_delay_2, encoder_clr, old_dc_reg, dct_coeff_zz,encoding_done, length, encoded_block); -- 138 upto 640 clock cycles
spi: spi_master generic map(512) port map(clock, '1', encoded_block, spi_tx_load, spi_rx_data, rx_valid, sck, mosi, miso, cs); -- 5120 clock cycles


encoder_controller : process(clock)
begin
    if present_state /= encoding then
        spi_tx_load <= '1';
        encoder_clr <= '0';
    elsif rising_edge(clock) then
        
        if encoding_done = '1' and spi_tx_load = '1' and rx_valid = '1' then
            spi_tx_load <= '0';   -- 1st clock cycle
            encoder_clr <= '1';
        elsif encoding_done = '1' and spi_tx_load = '0' and rx_valid = '0' then
            encoder_clr <= '0';
            spi_tx_load <= '1';   -- 2nd clock cycle 
        else
            encoder_clr <= '1';
            spi_tx_load <= '1';
        end if ;
    end if;
end process ; -- encoder_controller


block_transmitted_counter_pr : process( clock )
begin
    if present_state = idle then
        block_sent <= 0;
    elsif falling_edge(spi_tx_load) then
        block_sent <= block_sent + 1;
    end if;
end process ; -- block_transmitted_counter


---------------------------------------------------------------------------------------------
present_state_pr : process(clock)
    begin
        if rising_edge(clock) then
            if jpeg_start = '1' then
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
                if block_sent = 1 then
                    next_state <= final;
                else
                    next_state <= encoding;
                end if;
            when final =>
                next_state <= final;
        end case;
end process;
v <= unsigned(data_in(5 downto 3));
u <= unsigned(data_in(2 downto 0));
-- encoding_data_out <= "11000000" srl to_integer(unsigned(data_in(7 downto 5)));
outputs_fsm_pr : process(present_state)
begin
    case present_state is 
        when idle => 
            
            address(7 downto 0) <= data_in;
            if start = '1' then  
                address(17 downto 8) <= (others => '0');
            else
                address(17 downto 8) <= "0011000000";
            end if;
            data <= (others => '0');
            wren <= '0';
            data_out <= x"00";
            
            dct_start <= '1';
            img_pixel := "00000000";
            spi_clr <= '1';
        when converting =>
            address <= address_rgb_ycbcr;
            data <= data_rgb_ycbcr;
            wren <= wren_rgb_ycbcr;
            data_out <= converting_data_out;
            dct_start <= '1';
            img_pixel := "00000000";
        when dct => 
            address <= address_dct;
            data <= data_dct;
            wren <= wren_dct;
            data_out <= dct_working&std_logic_vector(to_unsigned(index_count,6))&dct_clock;
            dct_start <= '0';
            img_pixel := sfixed(q);
        when encoding =>
            address <= address_encoding;
            data <= data_encoding;
            wren <= '0';
            dct_start <= '1';
            data_out <= "10101010";
            img_pixel := "00000000";
            spi_clr <= '1';
        when final =>
            address <= (others => '0');
            data <= (others => '0');
            wren <= '0';
            dct_start <= '1';
            data_out <= (others => '1');
            img_pixel := "00000000";
            spi_clr <= '1';
    end case;
end process;

hex_out <= dct_coeff_block when data_in(7 downto 6) = "00" else dct_coeff_block_qz;
hex_5_data <= huff_code_table(to_integer(v&u)).code(26 downto 23) when data_in(7 downto 6) = "10" else "0000"  when data_in(7 downto 6) = "11" else q(7 downto 4);
hex_4_data <= huff_code_table(to_integer(v&u)).code(22 downto 19) when data_in(7 downto 6) = "10" else std_logic_vector(to_unsigned(huff_value_zz(to_integer(v&u)).code_length,4)) when data_in(7 downto 6) = "11" else q(3 downto 0);
hex_3_data <= huff_code_table(to_integer(v&u)).code(18 downto 15) when data_in(7 downto 6) = "10" else '0'&huff_value_zz(to_integer(v&u)).code(10 downto 8) when data_in(7 downto 6) = "11" else "0000";
hex_2_data <= huff_code_table(to_integer(v&u)).code(14 downto 11) when data_in(7 downto 6) = "10" else huff_value_zz(to_integer(v&u)).code(7 downto 4) when data_in(7 downto 6) = "11" else std_logic_vector('0'&hex_out(to_integer(v))(to_integer(u))(10 downto 8));
hex_1_data <= huff_code_table(to_integer(v&u)).code(10 downto 7) when data_in(7 downto 6) = "10" else huff_value_zz(to_integer(v&u)).code(3 downto 0) when data_in(7 downto 6) = "11" else std_logic_vector(hex_out(to_integer(v))(to_integer(u))(7 downto 4));
hex_0_data <= huff_code_table(to_integer(v&u)).code(6 downto 3) when data_in(7 downto 6) = "10" else std_logic_vector(hex_out(to_integer(v))(to_integer(u))(3 downto 0));
--with hex_out(to_integer(v))(to_integer(u))(3 downto 0) select hex_1 <=

with to_unsigned(length, 9)(7 downto 4) select hex_5 <=
    "1000000" when "0000",	
    "1111001" when "0001",	
    "0100100" when "0010", 	 
    "0110000" when "0011", 	
    "0011001" when "0100", 	
    "0010010" when "0101", 	
    "0000010" when "0110", 	
    "1111000" when "0111", 	
    "0000000" when "1000", 	
    "0011000" when "1001", 
    "0001000" when "1010",    
    "0000011" when "1011",    
    "1000110" when "1100",    
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111",
    "1111111" when others;	
-- --with hex_out(to_integer(v))(to_integer(u))(7 downto 4) select hex_2 <=
with to_unsigned(length, 9)(3 downto 0) select hex_4 <=
    "1000000" when "0000",	
    "1111001" when "0001",	
    "0100100" when "0010", 	 
    "0110000" when "0011", 	
    "0011001" when "0100", 	
    "0010010" when "0101", 	
    "0000010" when "0110", 	
    "1111000" when "0111", 	
    "0000000" when "1000", 	
    "0011000" when "1001", 
    "0001000" when "1010",    
    "0000011" when "1011",    
    "1000110" when "1100",    
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111",
    "1111111" when others;
--with hex_out(to_integer(v))(to_integer(u))(10 downto 8) select hex_3 <=
with hex_3_data select hex_3 <=
    "1000000" when "0000",	
    "1111001" when "0001",	
    "0100100" when "0010", 	 
    "0110000" when "0011", 	
    "0011001" when "0100", 	
    "0010010" when "0101", 	
    "0000010" when "0110", 	
    "1111000" when "0111", 	
    "0000000" when "1000", 	
    "0011000" when "1001", 
    "0001000" when "1010",    
    "0000011" when "1011",    
    "1000110" when "1100",    
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111",
    "1111111" when others;

--with q(3 downto 0) select hex_4 <= 
with hex_2_data select hex_2 <=
    "1000000" when "0000",	
    "1111001" when "0001",	
    "0100100" when "0010", 	 
    "0110000" when "0011", 	
    "0011001" when "0100", 	
    "0010010" when "0101", 	
    "0000010" when "0110", 	
    "1111000" when "0111", 	
    "0000000" when "1000", 	
    "0011000" when "1001", 
    "0001000" when "1010",    
    "0000011" when "1011",    
    "1000110" when "1100",    
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111",
    "1111111" when others;	

--with q(7 downto 4) select hex_5 <= 
with hex_1_data select hex_1 <=
    "1000000" when "0000",	
    "1111001" when "0001",	
    "0100100" when "0010", 	 
    "0110000" when "0011", 	
    "0011001" when "0100", 	
    "0010010" when "0101", 	
    "0000010" when "0110", 	
    "1111000" when "0111", 	
    "0000000" when "1000", 	
    "0011000" when "1001", 
    "0001000" when "1010",    
    "0000011" when "1011",    
    "1000110" when "1100",    
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111",
    "1111111" when others;	
with hex_0_data select hex_0 <=
    "1000000" when "0000",	
    "1111001" when "0001",	
    "0100100" when "0010", 	 
    "0110000" when "0011", 	
    "0011001" when "0100", 	
    "0010010" when "0101", 	
    "0000010" when "0110", 	
    "1111000" when "0111", 	
    "0000000" when "1000", 	
    "0011000" when "1001", 
    "0001000" when "1010",       
    "0000011" when "1011",    
    "1000110" when "1100",    
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111",
    "1111111" when others;	
end arch ; 

