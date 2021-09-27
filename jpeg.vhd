library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;

entity jpeg is
generic (width : natural := 256;
height : natural := 192   );
port(clock,start : in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    clock_delay_n : in std_logic;
    hex_1,hex_2,hex_3,hex_4,hex_5 : out std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(7 downto 0));
end jpeg;   

architecture arch of jpeg is
    type state_t is (idle,converting,dct,encoding);
    signal address : std_logic_vector(17 downto 0);
    signal address_bid : integer range 0 to 262144;
    shared variable address_rgb_ycbcr,address_dct,address_encoding : std_logic_vector(17 downto 0);
    shared variable data_rgb_ycbcr,data_dct,data_encoding : std_logic_vector(7 downto 0);
    signal v,u : unsigned(2 downto 0);
    signal rw_counter : integer range 0 to 11:= 0; 
    --read write counter for 0-11 read : r,g,b and then 6-11 :write y,cb,cr even are for addressing and odd for reading q. dct_clock cant be 50mhz. slow but it works idc at this point.
    
    signal clock_count: integer range 0 to 1 := 0;
    signal present_state : state_t;
    signal next_state : state_t;
    signal image_index_count,index_count : integer range 0 to 49151:= 0;
    shared variable r,g,b : unsigned(7 downto 0):= "00000000";
    signal y,cb,cr,y_reg,cb_reg,cr_reg : sfixed(7 downto 0);
    signal wren,wren_rgb_ycbcr,wren_dct,image_converted,image_index_clock,clock_delay,wren_encoding,encoding_done: std_logic := '0';
    signal data,q,converting_data_out : std_logic_vector(7 downto 0);
    signal jpeg_start,dct_working: std_logic := '0';
    shared variable img_pixel : sfixed(7 downto 0);
    signal v_in,u_in : unsigned(2 downto 0);
    signal hex_out,dct_coeff_block,dct_coeff_block_qz : dct_coeff_block_t;
    signal dct_read_counter : integer range 0 to 1 := 0;
    signal dct_clock,dct_finished :std_logic := '0';
    signal block_index_count : integer range 0 to 1024 := 0;
    signal dct_start : std_logic:= '1'; 
    signal y_x_index : unsigned(5 downto 0);
    signal dct_coeff_zz : dct_coeff_zz_t;
    signal huff_value_zz : dct_coeff_zz_t; 
    signal length_zz : length_zz_t;
    signal old_dc_reg : sfixed(10 downto 0) := "00000000000";
begin
-- clock_delay <= not clock_delay_n;
--jpeg_start_pr : process( start )
-- begin
--     if image_converted = '1' then 
--         jpeg_start <= '0';
--     elsif falling_edge(start) then
--         jpeg_start <= '1';
--     end if;
-- end process ; -- jpeg_start_pr
jpeg_start <= '1';
delayed_clock : process(clock)
begin
if rising_edge(clock) then
    if clock_count = 1  then     --1/4 of clock is necessary, i tried 1/2 and its corrupted data
        clock_delay <= not clock_delay;
        clock_count <= 0;
    else
        clock_count <= 1;
    end if;
end if;
end process ; -- dct_clock


bram_comp : bram_ip port map (address,clock,data,wren,q);




----------------------------------- CONVERTING STATE -------------------------------------
image_index_count_clock_pr : process(clock_delay,present_state)
    begin
    if present_state /= converting then
        rw_counter <= 0;
        image_index_clock <= '0';
    elsif falling_edge(clock_delay) then
        if rw_counter = 5 then
            image_index_clock <= '1';
            rw_counter <= 6;
        elsif rw_counter = 11 then
            image_index_clock <= '0';
            rw_counter <= 0;    
        else
            rw_counter <= rw_counter + 1; 
        end if;
    end if;
end process;
image_index_count_pr : process(image_index_clock) 
    begin
    if present_state /= converting then
        image_index_count <= 0;
    elsif falling_edge(image_index_clock) then
        if image_index_count = (height * width) then
            image_converted <= '1';
        elsif present_state = converting then
            image_index_count <= image_index_count + 1;
        end if;
    end if;
end process;
rgb_ycbcr_pr :process(clock_delay)
    begin
    if rising_edge(clock_delay) and present_state = converting then
        case rw_counter is
            when 0 => 
                wren_rgb_ycbcr <= '0';
                address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count,18));
            when 1 =>
                r := unsigned(q);
                converting_data_out <= std_logic_vector(r);
            when 2 => 
                wren_rgb_ycbcr <= '0';
                address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width ,18));
            when 3 =>
                g := unsigned(q); 
                converting_data_out <= std_logic_vector(g);
            when 4 => 
                wren_rgb_ycbcr <= '0';
                address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width * 2 ,18));
            when 5 =>
                b := unsigned(q); 
                converting_data_out <= std_logic_vector(b); 
            when 6 => 
                wren_rgb_ycbcr <= '1';
                address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count,18));
            when 7 =>
                data_rgb_ycbcr := std_logic_vector(y);  
                converting_data_out <= std_logic_vector(y);     
            when 8 => 
                wren_rgb_ycbcr <= '1';
                address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width ,18));
            when 9 =>
                data_rgb_ycbcr := std_logic_vector(cb);
                converting_data_out <= std_logic_vector(cb);
            when 10 => 
                wren_rgb_ycbcr <= '1';
                address_rgb_ycbcr := std_logic_vector(to_unsigned(image_index_count + height * width * 2 ,18));
            when 11 =>
                data_rgb_ycbcr := std_logic_vector(cr);
                converting_data_out <= std_logic_vector(cr);
        end case;
    end if;
end process;
rgb_ycbcr_conversion_pr :process(clock)   
    variable rs,gs,bs,y_temp,cb_temp,cr_temp: unsigned(23 downto 0);
    variable y_temp2,cb_temp2,cr_temp2 : unsigned(7 downto 0);
    begin
        
        if rising_edge(clock) and present_state = converting then
            rs :=x"0000"&r;
            gs :=x"0000"&g;
            bs :=x"0000"&b;

            y_temp := (((rs sll 14)+(rs sll 11)+(rs sll 10)+(rs sll 7)+(rs sll 3)+(rs sll 2)+(rs sll 1)+(gs sll 15)+(gs sll 12)+(gs sll 10)+(gs sll 9)+(gs sll 6)+(gs sll 2)+(bs sll 12)+(bs sll 11)+(bs sll 10)+(bs sll 8)+(bs sll 5)+(bs sll 3)+(bs sll 2)+(bs sll 1)) srl 16) - "10000000";
            cb_temp := ((bs sll 15)-(rs sll 13)-(rs sll 11)-(rs sll 9)-(rs sll 8)-(rs sll 5)-(rs sll 4)-(rs sll 1)-(gs sll 14)-(gs sll 12)-(gs sll 10)-(gs sll 7)-(gs sll 6)-(gs sll 2)) srl 16;
            cr_temp := ((rs sll 15)-(gs sll 14)-(gs sll 13)-(gs sll 11)-(gs sll 9)-(gs sll 8)-(gs sll 5)-(gs sll 3)-(gs sll 2)-(gs sll 1)-(bs sll 12)-(bs sll 10)-(bs sll 7)-(bs sll 6)-(bs sll 4)) srl 16;

            y_temp2 := y_temp(7 downto 0);
            cb_temp2 := cb_temp(7 downto 0);
            cr_temp2 := cr_temp(7 downto 0);
        
            
            y  <= to_sfixed(std_logic_vector(y_temp2),7,0);
            cb <= to_sfixed(std_logic_vector(cb_temp2),7,0);
            cr <= to_sfixed(std_logic_vector(cr_temp2),7,0);
        end if;
end process;
-------------------------------------------------------------------------------------------

--------------------------------------- DCT STATE -----------------------------------------
dct_comp : dct_block port map(dct_clock,dct_start,dct_finished,dct_working,y_x_index,img_pixel,dct_coeff_block);
y_quant_comp : y_quantizer port map(dct_coeff_block,dct_coeff_block_qz);
-- cb_quant_comp : cb_quantizer port map(dct_coeff_block,dct_coeff_block_qz);
-- cr_quant_comp : cr_quantizer port map(dct_coeff_block,dct_coeff_block_qz);
bid_comp : block_index_decoder port map(to_unsigned(index_count,6),0,0,width,height,0,address_bid);
zigzag_comp : zigzag port map(dct_coeff_block_qz,dct_coeff_zz);
process(clock)
begin
    address_dct := std_logic_vector(to_unsigned(address_bid,18));
end process;
y_x_index_pr : process(dct_working,dct_clock)
begin
    if dct_working = '0' then 
        y_x_index <= "000000";
        dct_finished <= '0';
    elsif falling_edge(dct_clock) and dct_working = '1' then
        if y_x_index = "111111" then 
            dct_finished <= '1';
        else
            y_x_index <= y_x_index + 1;
        end if;
    end if;
end process ; --y_x_index

pixel_pr : process(clock_delay,present_state)
begin
    if present_state /= dct then
        dct_read_counter <= 0;
        
        dct_clock <= '0';
        index_count <= 0;
    elsif rising_edge(clock_delay) then
        if dct_working = '1' then
            case dct_read_counter is
                when 0 =>
                    wren_dct <= '0';
                    dct_clock <= '0';
                    dct_read_counter <= 1;
                when 1 => 
                    wren_dct <= '0';
                    dct_clock <= '1';
                    dct_read_counter <= 0;
                    index_count <= index_count + 1;
            end case;
        end if;     
    end if; 
end process ; -- pixel_process
-------------------------------------------------------------------------------------------
-------------------------------------ENCODING STATE----------------------------------------
mini_length_comp : mini_length_block port map(dct_coeff_zz(0) - old_dc_reg,dct_coeff_zz,huff_value_zz,length_zz);
old_dc_reg_pr : process( encoding_done,present_state )
begin  
    if present_state = idle then
        old_dc_reg <= "00000000000";
    elsif rising_edge(encoding_done) then
        old_dc_reg <= dct_coeff_zz(0);
    end if;
    
end process ; -- old_dc_reg_pr


-------------------------------------------------------------------------------------------
present_state_pr : process(clock_delay)
    begin
        if rising_edge(clock_delay) then
            if jpeg_start = '1' then
                present_state <= next_state;
            else 
                present_state <= idle;
            end if;
        end if;
    end process;


next_state_pr : process(present_state,image_converted)
    begin 
        case present_state is
            when idle => 
                if image_converted = '0' then
                    next_state <= converting;
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
                if encoding_done = '1' then
                    next_state <= dct;
                else
                    next_state <= encoding;
                end if;
        end case;
end process;

outputs_fsm_pr : process(present_state)
begin
    case present_state is 
        when idle => 
            v <= unsigned(data_in(5 downto 3));
            u <= unsigned(data_in(2 downto 0));
            address(7 downto 0) <= data_in;
            if start = '1' then  
                address(17 downto 8) <= (others => '0');
            else
                address(17 downto 8) <= "0011000000";
            end if;
            data <= (others => '0');
            wren <= '0';
            data_out <= q;
            dct_start <= '1';
        when converting =>
            address <= address_rgb_ycbcr;
            data <= data_rgb_ycbcr;
            wren <= wren_rgb_ycbcr;
            data_out <= converting_data_out;
            dct_start <= '1';
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
            wren <= wren_encoding;
            dct_start <= '1';
    end case;
end process;
hex_out <= dct_coeff_block when data_in(7 downto 6) = "00" else dct_coeff_block_qz;
--with hex_out(to_integer(v))(to_integer(u))(3 downto 0) select hex_1 <=
with dct_coeff_zz(to_integer(v&u))(3 downto 0) select hex_1 <=
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
--with hex_out(to_integer(v))(to_integer(u))(7 downto 4) select hex_2 <=
with dct_coeff_zz(to_integer(v&u))(7 downto 4) select hex_2 <=
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
with dct_coeff_zz(to_integer(v&u))(10 downto 8) select hex_3 <=
    "1000000" when "000",	
    "1111001" when "001",	
    "0100100" when "010", 	 
    "0110000" when "011", 	
    "0011001" when "100", 	
    "0010010" when "101", 	
    "0000010" when "110", 	
    "1111000" when "111", 	
    "1111111" when others;

with q(3 downto 0) select hex_4 <= 
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

with q(7 downto 4) select hex_5 <= 
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

