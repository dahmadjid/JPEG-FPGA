library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
--Tested on FPGA
entity mini_length is
    port 
    (
        dct_coeff : in sfixed(10 downto 0);  
        huff_value : out sfixed(10 downto 0);
        length : out unsigned(3 downto 0) --number between 0 and 11
    ) ;
end mini_length;

architecture arch of mini_length is
    signal length_temp : unsigned(3 downto 0);
    signal temp: sfixed(10 downto 0);
    signal huff_value_temp : sfixed(10 downto 0);
    signal temp2: sfixed(10 downto 0);
begin
    with dct_coeff(10) select
        temp <= resize(not dct_coeff + 1,10,0) when '1', dct_coeff when others;
    temp2 <= not temp when dct_coeff(10) = '1' else temp;
    length_temp <=   
        "1011" when temp(10) = '1' else
        "1010" when temp(9) = '1' else
        "1001" when temp(8) = '1' else
        "1000" when temp(7) = '1' else
        "0111" when temp(6) = '1' else
        "0110" when temp(5) = '1' else
        "0101" when temp(4) = '1' else
        "0100" when temp(3) = '1' else
        "0011" when temp(2) = '1' else
        "0010" when temp(1) = '1' else
        "0001" when temp(0) = '1' else
        "0000" when temp(0) = '0';
   
process(dct_coeff,temp2,length_temp)
begin
    if length_temp = "0000" then
        huff_value_temp <= "00000000000";
    elsif length_temp = "0001" then
        huff_value_temp(0) <= temp2(0);
        huff_value_temp(10 downto 1) <= "0000000000";
    elsif length_temp = "0010" then
        huff_value_temp(1 downto 0) <= temp2(1 downto 0);
        huff_value_temp(10 downto 2) <= "000000000";
    elsif length_temp = "0011" then 
        huff_value_temp(2 downto 0) <= temp2(2 downto 0);
        huff_value_temp(10 downto 3) <= "00000000";
    elsif length_temp = "0100" then
        huff_value_temp(3 downto 0) <= temp2(3 downto 0);
        huff_value_temp(10 downto 4) <= "0000000";
    elsif length_temp = "0101" then
        huff_value_temp(4 downto 0) <= temp2(4 downto 0);
        huff_value_temp(10 downto 5) <= "000000";
    elsif length_temp = "0110" then
        huff_value_temp(5 downto 0) <= temp2(5 downto 0);
        huff_value_temp(10 downto 6) <= "00000";
    elsif length_temp = "0111" then 
        huff_value_temp(6 downto 0) <= temp2(6 downto 0);
        huff_value_temp(10 downto 7) <= "0000";
    elsif length_temp = "1000" then
        huff_value_temp(7 downto 0) <= temp2(7 downto 0);
        huff_value_temp(10 downto 8) <= "000";
    elsif length_temp = "1001" then  
        huff_value_temp(8 downto 0) <= temp2(8 downto 0);
        huff_value_temp(10 downto 9) <= "00";
    elsif length_temp = "1010" then
        huff_value_temp(9 downto 0) <= temp2(9 downto 0);
        huff_value_temp(10) <= '0';
    elsif length_temp = "1011" then
        huff_value_temp(10 downto 0) <= temp2(10 downto 0);  
    else 
        huff_value_temp <= "00000000000";      
    end if;
end process;
huff_value <= huff_value_temp;
length <= length_temp;
end arch;


-- 5 bit test for fpga
--architecture arch of mini_length is
    --     signal length_temp : unsigned(3 downto 0);
    --     signal temp: sfixed(4 downto 0);
    --     signal huff_value_temp : sfixed(4 downto 0);
    --     signal temp2: sfixed(4 downto 0);
    -- begin
    --     with dct_coeff(4) select
    --         temp <= resize(not dct_coeff + 1,4,0) when '1', dct_coeff when others;
    
    --     length_temp <=   
    --         "0101" when temp(4) = '1' else
    --         "0100" when temp(3) = '1' else
    --         "0011" when temp(2) = '1' else
    --         "0010" when temp(1) = '1' else
    --         "0001" when temp(0) = '1' else
    --         "0000" when temp(0) = '0';
    --     temp2 <= not temp when dct_coeff(4) = '1' else temp;
    -- process(dct_coeff,temp2,length_temp)
    -- begin
    --     if length_temp = "0000" then
    --         huff_value_temp <= "00000";
    --     elsif length_temp = "0001" then
    --         huff_value_temp(0) <= temp2(0);
    --         huff_value_temp(4 downto 1) <= "0000";
    --     elsif length_temp = "0010" then
    --         huff_value_temp(1 downto 0) <= temp2(1 downto 0);
    --         huff_value_temp(4 downto 2) <= "000";
    --     elsif length_temp = "0011" then 
    --         huff_value_temp(2 downto 0) <= temp2(2 downto 0);
    --         huff_value_temp(4 downto 3) <= "00";
    --     elsif length_temp = "0100" then
    --         huff_value_temp(3 downto 0) <= temp2(3 downto 0);
    --         huff_value_temp(4) <= '0';
    --     elsif length_temp = "0101" then
    --         huff_value_temp(4 downto 0) <= temp2(4 downto 0);
    --     else 
    --         huff_value_temp <= "00000";      
    --     end if;
    -- end process;
    -- huff_value <= huff_value_temp;
    -- length <= length_temp;
    -- end arch;    

