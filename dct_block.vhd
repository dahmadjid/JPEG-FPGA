library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
library work;
use work.jpeg_pkg.all;

-- TESTED IN FPGA. WORKS GOOD (+- 1 or 2 accuracy)
-- HOW TO USE:
-- the clock is divided by 2.
-- img_pixel_00 has to be ready before the falling edge of dct_start. 
-- the mult-accum is done at the rising edge of clock.
-- the y_x_index is incremented on the falling edge of clock.
-- the next img_pixel (0,1) has to be ready after the falling edge and before the next rising edge of clock.
-- after 64 clocks (128) dct_working goes low again meaning data is ready and u can now start another dct calculation.
-- u can access the coeffcients using u_in and v_in addresses. all coeff will be ready to read after 64 clocks.

entity dct_block is
  port (
    clock,dct_start : in std_logic;
    dct_working : out std_logic;
    img_pixel : in sfixed(7 downto 0);
    dct_coeff_block : out dct_coeff_block_t
    --v_in,u_in : in unsigned(2 downto 0);
    --hex_1,hex_2 : out std_logic_vector(6 downto 0);
    --dct_coeff : out sfixed(10 downto 0)
    
  ) ;
end dct_block ;

architecture arch of dct_block is
    signal end_delay_count: integer range 0 to 3 := 0;
    signal clock_count : integer range 0 to 4;
    signal y_x_index : unsigned(5 downto 0);
    signal const_1,const_2,const_3 : sfixed(1 downto -20);
    signal dct_working_s,dct_finished: std_logic := '0';
    signal y,x : integer range 0 to 7 := 0;
    signal img : image_block_t;
    --signal dct_coeff_block : dct_coeff_block_t;
begin
-- img <= (("01111111","01111111","01111110","01111110","01111110","01111111","01111111","01111111"),
-- ("01111111","01111111","01111111","01111111","01111111","01111111","01111111","01111110"),
-- ("01111111","01111111","01111111","01111111","01111111","01111111","01111110","01111110"),
-- ("01111111","01111111","01111111","01111111","01111111","01111111","01111110","01111110"),
-- ("01111111","01111111","01111111","01111110","01111110","01111110","01111110","01111111"),
-- ("01111111","01111111","01111111","01111110","01111101","01111101","01111110","01111111"),
-- ("01111111","01111111","01111111","01111110","01111101","01111101","01111101","01111110"),
-- ("01111110","01111110","01111111","01111110","01111110","01111101","01111101","01111101"));
-- img_pixel <= img(y)(x);
y_x_index_pr : process(dct_working_s,clock)
begin
    if dct_working_s = '0' then 
        y_x_index <= "000000";
        dct_finished <= '0';
    elsif falling_edge(clock) and dct_working_s = '1' then
        if y_x_index = "111111" then 
            dct_finished <= '1';
        else
            y_x_index <= y_x_index + 1;
        end if;
    end if;
end process ; --y_x_index

const_1 <="0000100000000000000000";  -- u,v = 0  1/8
const_2 <="0000101101010000010011";  -- u or v = 0
const_3 <="0001000000000000000000";  -- else 1/4

dct_working_s_pr : process(dct_start,dct_finished)
begin
    if dct_finished = '1' then
        dct_working_s <= '0';
    elsif falling_edge(dct_start) then
        dct_working_s <= '1';
    end if;
end process;

-- clock_pr : process(clock)
-- begin
-- if rising_edge(clock) then
--     if clock_count = 1 then
--         clock_count <= 0;
--         clock <= not clock;
--     else
--         clock_count <= clock_count + 1; 
--     end if;
-- end if;
-- end process ; -- clock

-- end_delay_count_pr : process(dct_finished,clock)
-- begin
--     if dct_finished = '0' then
--         end_delay_count <= 0;
--     elsif rising_edge(clock) and end_delay_count /= 3 then
--         end_delay_count <= end_delay_count + 1;
--     end if;
-- end process ; -- end_delay_count

y <= to_integer(y_x_index(5 downto 3));
x <= to_integer(y_x_index(2 downto 0));




-- GENERATES according to constants that depends on u and v to save area
-- u,v = 0
dct_00 : dct port map("000","000",img_pixel,clock,dct_working_s,dct_finished,y,x,const_1,dct_coeff_block(0)(0));
dct_0_gen : for a in 1 to 7 generate
        -- u = 0, v ranges 1 to 7 
    dct_u0 : dct port map(to_unsigned(a,3),"000",img_pixel,clock,dct_working_s,dct_finished,y,x,const_2,dct_coeff_block(a)(0));
    
        -- v = 0 , u  ranges 1 to 7 
    dct_v0 : dct port map("000",to_unsigned(a,3),img_pixel,clock,dct_working_s,dct_finished,y,x,const_2,dct_coeff_block(0)(a));
end generate;

dct_v_gen : for v_int in 1 to 7 generate
    dct_u_gen : for u_int in 1 to 7 generate
        -- u,v ranges 1 to 7
        dct_vu : dct port map(to_unsigned(v_int,3),to_unsigned(u_int,3),img_pixel,clock,dct_working_s,dct_finished,y,x,const_3,dct_coeff_block(v_int)(u_int));
    end generate dct_u_gen;
end generate dct_v_gen;

--dct_coeff <= dct_coeff_block(to_integer(v_in))(to_integer(u_in));
dct_working <= dct_working_s;
-- with y_x_index(3 downto 0) select hex_1 <=
-- 		"1000000" when "0000",	
-- 		"1111001" when "0001",	
-- 		"0100100" when "0010", 	 
-- 		"0110000" when "0011", 	
-- 		"0011001" when "0100", 	
-- 		"0010010" when "0101", 	
-- 		"0000010" when "0110", 	
-- 		"1111000" when "0111", 	
-- 		"0000000" when "1000", 	
-- 		"0011000" when "1001", 
--         "0001000" when "1010",    
-- 		"0000011" when "1011",    
-- 		"1000110" when "1100",    
-- 		"0100001" when "1101",
-- 		"0000110" when "1110",
-- 		"0001110" when "1111",
-- 		"1111111" when others;	
-- with y_x_index(5 downto 4) select hex_2 <=
-- 		"1000000" when "00",	
-- 		"1111001" when "01",	
-- 		"0100100" when "10",
--         "0110000" when "11",
--         "1111111" when others;
end arch ; -- arch