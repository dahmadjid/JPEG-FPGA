library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

-- tested on fpga (+- 2 accuracy)
entity rgb_ycbcr is
  port (
		clock : in std_logic;

    -- r,g,b : in unsigned(7 downto 0);
    -- y,cb,cr : out sfixed(7 downto 0)
    -- i : in std_logic_vector(1 downto 0);
    -- hex_1,hex_2 : out std_logic_vector(6 downto 0)
    hex_1,hex_2,hex_3,hex_4,hex_5 : out std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(7 downto 0)
  ) ;
end rgb_ycbcr;

architecture arch of rgb_ycbcr is
    -- signal r,g,b : unsigned(7 downto 0);
    signal y,cb,cr : sfixed(7 downto 0);

    signal y_temp2 : unsigned(7 downto 0);
    
    
begin
    -- r <= "11111111";
    -- b <= "11111111";
    -- g <= "11111111"; 
    rgb_ycbcr_conversion_pr :process(clock)   
    variable rs,gs,bs,y_temp,cb_temp,cr_temp: unsigned(23 downto 0);
    variable cb_temp2,cr_temp2,y_temp3 : unsigned(7 downto 0);
    begin
        
        if rising_edge(clock) then
            rs := x"0000"&x"ff";
            gs := x"0000"&x"00";
            bs := x"0000"&x"00";

            y_temp := (((rs sll 14)+(rs sll 11)+(rs sll 10)+(rs sll 7)+(rs sll 3)+(rs sll 2)+(rs sll 1)+(gs sll 15)+(gs sll 12)+(gs sll 10)+(gs sll 9)+(gs sll 6)+(gs sll 2)+(bs sll 12)+(bs sll 11)+(bs sll 10)+(bs sll 8)+(bs sll 5)+(bs sll 3)+(bs sll 2)+(bs sll 1)) srl 16) - "10000000" ;

            y_temp2 <= y_temp(7 downto 0);
    
            y  <= to_sfixed(std_logic_vector(y_temp2 ),7,0);
            
				data_out <= std_logic_vector(y);
        end if;
end process;

with y_temp2(3 downto 0) select hex_2 <=
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
with y_temp2(7 downto 4) select hex_3<=
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
    with y(3 downto 0) select hex_4 <=
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
with y(7 downto 4) select hex_5 <=
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
--     dct_coeff <= y when i = "00" else cb when i = "01" else cr when i = "10" else y;
--    with dct_coeff(3 downto 0) select hex_1 <=
--     "1000000" when "0000",	
--     "1111001" when "0001",	
--     "0100100" when "0010", 	 
--     "0110000" when "0011", 	
--     "0011001" when "0100", 	
--     "0010010" when "0101", 	
--     "0000010" when "0110", 	
--     "1111000" when "0111", 	
--     "0000000" when "1000", 	
--     "0011000" when "1001", 
--     "0001000" when "1010",    
--     "0000011" when "1011",    
--     "1000110" when "1100",    
--     "0100001" when "1101",
--     "0000110" when "1110",
--     "0001110" when "1111",
--     "1111111" when others;	
-- with dct_coeff(7 downto 4) select hex_2 <=
--     "1000000" when "0000",	
--     "1111001" when "0001",	
--     "0100100" when "0010", 	 
--     "0110000" when "0011", 	
--     "0011001" when "0100", 	
--     "0010010" when "0101", 	
--     "0000010" when "0110", 	
--     "1111000" when "0111", 	
--     "0000000" when "1000", 	
--     "0011000" when "1001", 
--     "0001000" when "1010",    
--     "0000011" when "1011",    
--     "1000110" when "1100",    
--     "0100001" when "1101",
--     "0000110" when "1110",
--     "0001110" when "1111",
--     "1111111" when others;

end arch ; -- arch