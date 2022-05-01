library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;
entity mini_length_block is
  port (
    clock : in std_logic;
    increment_block_count : in std_logic;
    channel : in integer range 0 to 3;
    old_dc_reg_y : in sfixed(10 downto 0);
    old_dc_reg_cb : in sfixed(10 downto 0);
    old_dc_reg_cr : in sfixed(10 downto 0);
    dct_coeff_zz : in dct_coeff_zz_t;
    huff_value_zz : out huff_value_zz_t
  ) ;
end mini_length_block;

architecture arch of mini_length_block is
    signal length_temp : unsigned(3 downto 0);
    signal temp: sfixed(11 downto 0);
    signal huff_value_temp : sfixed(10 downto 0);
    signal temp2: sfixed(11 downto 0);
    signal dc_diff : sfixed(11 downto 0);
    signal y_dc_diff, cb_dc_diff, cr_dc_diff: sfixed(11 downto 0);
    signal khra : integer;
begin

    -- dc_diff <= dct_coeff_zz(0) - old_dc_reg;
    khraazeaea : process( clock )
    begin
        if channel = 3 then
            khra <= 0;
        elsif rising_edge(increment_block_count) then
            khra <= 1;
        end if ;
    end process ; -- khra
    pro_ta3_khra : process( clock )
    variable tempaze, tempaze2, tempaze3, tempaze4 : integer;
    begin
        if rising_edge(clock) and khra = 0 then
            y_dc_diff <= '0'&dct_coeff_zz(0);
            cb_dc_diff <= '0'&dct_coeff_zz(0);
            cr_dc_diff <= '0'&dct_coeff_zz(0);


        elsif rising_edge(clock) and khra = 1 then
            tempaze := to_integer(dct_coeff_zz(0)); 
            tempaze2 := to_integer(old_dc_reg_y); 
            tempaze3 := to_integer(old_dc_reg_cb); 
            tempaze4 := to_integer(old_dc_reg_cr); 

            y_dc_diff <= to_sfixed(tempaze - tempaze2, 11, 0);
            cb_dc_diff <= to_sfixed(tempaze - tempaze3, 11, 0);
            cr_dc_diff <= to_sfixed(tempaze - tempaze4, 11, 0);



        end if ; 
    end process ; -- pro_ta3_khra
    -- cb_dc_diff <= '0'&dct_coeff_zz(0);
    -- cr_dc_diff <= '0'&dct_coeff_zz(0);

    dc_diff <= y_dc_diff when channel = 0 else cb_dc_diff when channel = 1 else cr_dc_diff when channel = 2 else y_dc_diff;
    --dc_diff <= y_dc_diff;
    with dc_diff(11) select
    temp <= resize(not dc_diff + 1,11,0) when '1', dc_diff when others;
    
    temp2 <= not temp when dc_diff(11) = '1' else temp;

    length_temp <= 
    "1011" when temp(11) = '1' else
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
    "0000";

process(dc_diff,temp2,length_temp)
begin
if dc_diff = "100000000000" then
    huff_value_temp <= "00000000000";
elsif length_temp = "0000" then
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


huff_value_zz(0) <= (std_logic_vector(huff_value_temp),to_integer(length_temp));




mini_length_gen :for i in 1 to 63 generate  --AC
    huff_value_zz(i) <= ("00000000000", 0);
    -- mini_length_comp : mini_length port map (dct_coeff_zz(i), huff_value_zz(i));
end generate;


end arch ; -- arch