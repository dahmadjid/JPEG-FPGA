library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
library work;
use work.jpeg_pkg.all;


entity quantizer is
  port (
    dct_coeff_block : in dct_coeff_block_t;
    channel : in integer range 0 to 2;
    dct_coeff_qz : out dct_coeff_block_t
  ) ;
end quantizer;

architecture arch of quantizer is
    type temp_t_t is array(7 downto 0) of sfixed(12 downto -32);
    type temp_t is array(7 downto 0) of temp_t_t;
    signal temp : temp_t;
    signal temp2 : temp_t;
    signal dct_coeff_qz_y, dct_coeff_qz_c : dct_coeff_block_t;
begin
    
genj: for j in 0 to 7 generate
    geni: for i in 0 to 7 generate
        temp(j)(i) <= dct_coeff_block(j)(i) * luminance_qz_fixed(j)(i);
        --dct_coeff_qz_y(j)(i) <= temp(j)(i)(10 downto 0) when (dct_coeff_block(j)(i) > 32 or dct_coeff_block(j)(i) < -32)  else "000"&x"00";
        dct_coeff_qz_y(j)(i) <= "000"&x"00" when (dct_coeff_block(j)(i)(10 downto 0) > -8 and dct_coeff_block(j)(i)(10 downto 0) < 8) else temp(j)(i)(10 downto 0);
        temp2(j)(i) <= dct_coeff_block(j)(i) * chrominance_qz_fixed(j)(i);
        
        --dct_coeff_qz_c(j)(i) <= dct_coeff_block2(j)(i)(10 downto 0) when (dct_coeff_block(j)(i) > 32 or dct_coeff_block(j)(i) < -32)  else "000"&x"00";
        dct_coeff_qz_c(j)(i) <= "000"&x"00" when (dct_coeff_block(j)(i)(10 downto 0) > -8 and dct_coeff_block(j)(i)(10 downto 0) < 8) else temp2(j)(i)(10 downto 0);
        end generate geni;
end generate genj;         

dct_coeff_qz <= dct_coeff_qz_y when channel = 0 else dct_coeff_qz_c;
end arch ; -- arch

