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
    r,g,b : in unsigned(7 downto 0);
    y,cb,cr : out sfixed(7 downto 0)
    -- i : in std_logic_vector(1 downto 0);
    -- hex_1,hex_2 : out std_logic_vector(6 downto 0)
  ) ;
end rgb_ycbcr;

architecture arch of rgb_ycbcr is
    -- signal r,g,b : unsigned(7 downto 0);
    -- signal y,cb,cr : sfixed(7 downto 0);
    signal rs,gs,bs,y_temp,cb_temp,cr_temp: unsigned(22 downto 0);
    signal y_temp2,cb_temp2,cr_temp2,y_temp3 : unsigned(7 downto 0);
    signal dct_coeff : sfixed(7 downto 0);
    
    
begin
    -- r <= "11111111";
    -- b <= "11111111";
    -- g <= "11111111"; 
    process(clock)
    begin

        if rising_edge(clock) then
            rs <= "000000000000000"&r;
            gs <= "000000000000000"&g;
            bs <= "000000000000000"&b;
            y_temp <= ((rs sll 14)+(rs sll 11)+(rs sll 10)+(rs sll 7)+(rs sll 3)+(rs sll 2)+(rs sll 1)+(gs sll 15)+(gs sll 12)+(gs sll 10)+(gs sll 9)+(gs sll 6)+(gs sll 2)+(bs sll 12)+(bs sll 11)+(bs sll 10)+(bs sll 8)+(bs sll 5)+(bs sll 3)+(bs sll 2)+(bs sll 1)) srl 16;
            cb_temp <= ((bs sll 15)-(rs sll 13)-(rs sll 11)-(rs sll 9)-(rs sll 8)-(rs sll 5)-(rs sll 4)-(rs sll 1)-(gs sll 14)-(gs sll 12)-(gs sll 10)-(gs sll 7)-(gs sll 6)-(gs sll 2)) srl 16;
            cr_temp <= ((rs sll 15)-(gs sll 14)-(gs sll 13)-(gs sll 11)-(gs sll 9)-(gs sll 8)-(gs sll 5)-(gs sll 3)-(gs sll 2)-(gs sll 1)-(bs sll 12)-(bs sll 10)-(bs sll 7)-(bs sll 6)-(bs sll 4)) srl 16;

            y_temp2 <= y_temp(7 downto 0);
            cb_temp2 <= cb_temp(7 downto 0);
            cr_temp2 <= cr_temp(7 downto 0);
            
            if y_temp2(7) = '1' then
                y_temp3 <= resize(y_temp2 - 256,8);
            else
                y_temp3 <=  y_temp2;
            end if;
            
            y  <=  to_sfixed(std_logic_vector(y_temp3),7,0);
            cb <= to_sfixed(std_logic_vector(cb_temp2),7,0);
            cr <= to_sfixed(std_logic_vector(cr_temp2),7,0);
        end if;
    end process;
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