library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;
library std;
use std.textio.all;

entity jpeg is
generic (width : natural := 8;
height : natural := 8);
port(clock,start : in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    clock_delay_n : in std_logic;
    hex_1,hex_2,hex_3 : out std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(7 downto 0));
end jpeg;

architecture arch of jpeg is
    type state_t is (idle,converting,transformation);
    signal address : std_logic_vector(17 downto 0);
    shared variable address_rgb_ycbcr : std_logic_vector(17 downto 0);
    shared variable data_rgb_ycbcr : std_logic_vector(7 downto 0);

    signal rw_counter : integer range 0 to 11:= 0; 
    --read write counter for 0-11 read : r,g,b and then 6-11 :write y,cb,cr even are for addressing and odd for reading q. dct_clock cant be 50mhz. slow but it works idc at this point.
    
    signal clock_count: integer range 0 to 1:= 0;
    signal present_state : state_t;
    signal next_state : state_t;
    signal image_index_count : integer range 0 to 49151:= 0;
    shared variable r,g,b : unsigned(7 downto 0):= "00000000";
    signal y,cb,cr,y_reg,cb_reg,cr_reg : sfixed(7 downto 0);
    signal wren,wren_rgb_ycbcr,image_converted,image_index_clock,clock_delay: std_logic := '0';
    signal data,q,converting_data_out : std_logic_vector(7 downto 0);
    signal jpeg_start,ready_to_convert: std_logic := '0';
    
begin
--clock_delay <= not clock_delay_n;
jpeg_start_pr : process( start )
begin
    if image_converted = '1' then 
        jpeg_start <= '0';
    elsif falling_edge(start) then
        jpeg_start <= '1';
    end if;
end process ; -- jpeg_start_pr

delayed_clock : process(clock)
begin
if rising_edge(clock) then
    if clock_count = 1 then
        clock_count <= 0;
        clock_delay <= not clock_delay;
    else
        clock_count <= clock_count + 1; 
    end if;
end if;
end process ; -- dct_clock


bram_comp : bram_ip port map (address,clock,data,wren,q);


------------------------------------- CONVERTING STATE -------------------------------------
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
    variable rs,gs,bs,y_temp,cb_temp,cr_temp: unsigned(22 downto 0);
    variable y_temp2,cb_temp2,cr_temp2,y_temp3 : unsigned(7 downto 0);
    begin
        
        if rising_edge(clock) and present_state = converting then
            rs := "000000000000000"&r;
            gs := "000000000000000"&g;
            bs := "000000000000000"&b;

            y_temp := ((rs sll 14)+(rs sll 11)+(rs sll 10)+(rs sll 7)+(rs sll 3)+(rs sll 2)+(rs sll 1)+(gs sll 15)+(gs sll 12)+(gs sll 10)+(gs sll 9)+(gs sll 6)+(gs sll 2)+(bs sll 12)+(bs sll 11)+(bs sll 10)+(bs sll 8)+(bs sll 5)+(bs sll 3)+(bs sll 2)+(bs sll 1)) srl 16;
            cb_temp := ((bs sll 15)-(rs sll 13)-(rs sll 11)-(rs sll 9)-(rs sll 8)-(rs sll 5)-(rs sll 4)-(rs sll 1)-(gs sll 14)-(gs sll 12)-(gs sll 10)-(gs sll 7)-(gs sll 6)-(gs sll 2)) srl 16;
            cr_temp := ((rs sll 15)-(gs sll 14)-(gs sll 13)-(gs sll 11)-(gs sll 9)-(gs sll 8)-(gs sll 5)-(gs sll 3)-(gs sll 2)-(gs sll 1)-(bs sll 12)-(bs sll 10)-(bs sll 7)-(bs sll 6)-(bs sll 4)) srl 16;

            y_temp2 := y_temp(7 downto 0);
            cb_temp2 := cb_temp(7 downto 0);
            cr_temp2 := cr_temp(7 downto 0);
            
            if y_temp2(7) = '1' then
                y_temp3 := resize(y_temp2 - 256,8);
            else
                y_temp3 :=  y_temp2;
            end if;
            
            y  <= to_sfixed(std_logic_vector(y_temp3 ),7,0);
            cb <= to_sfixed(std_logic_vector(cb_temp2),7,0);
            cr <= to_sfixed(std_logic_vector(cr_temp2),7,0);
        end if;
end process;
---------------------------------------------------------------------------------------------


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
                    next_state <= transformation;
                else 
                    next_state <= converting;
                end if;
            when transformation => 
                next_state <= idle;
        end case;
end process;

outputs_fsm_pr : process(present_state)
begin
    case present_state is 
        when idle => 
            address(7 downto 0) <= data_in;
            address(17 downto 8) <= (others => '0');
            data <= (others => '0');
            wren <= '0';
            data_out <= q;
        when converting =>
            address <= address_rgb_ycbcr;
            data <= data_rgb_ycbcr;
            wren <= wren_rgb_ycbcr;
            data_out <= converting_data_out;
        when transformation => 
            address <= (others => '0');
            data <= (others => '0');
            wren <= '0';
            data_out <= "00000000";


    end case;
end process;

with q(3 downto 0) select hex_1 <=
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
with q(7 downto 4) select hex_2 <=
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
with rw_counter select hex_3 <=
    "1000000" when 0,	
    "1111001" when 1,	
    "0100100" when 2, 	 
    "0110000" when 3, 	
    "0011001" when 4, 	
    "0010010" when 5, 	
    "1111111" when others;
end arch ; 
