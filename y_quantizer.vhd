library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
library work;
use work.jpeg_pkg.all;


entity y_quantizer is
  port (
    dct_coeff_block : in dct_coeff_block_t;
    dct_coeff_qz : out dct_coeff_block_t
  ) ;
end y_quantizer;

architecture arch of y_quantizer is
    type temp_t_t is array(7 downto 0) of sfixed(12 downto -16);
    type temp_t is array(7 downto 0) of temp_t_t;
    signal temp : temp_t;
begin
    
genj: for j in 0 to 7 generate
    geni: for i in 0 to 7 generate
        temp(j)(i) <= dct_coeff_block(j)(i) * luminance_qz_fixed(j)(i);
        dct_coeff_qz(j)(i) <= temp(j)(i)(10 downto 0) when (dct_coeff_block(j)(i) > 5 or dct_coeff_block(j)(i) < -5)  else "000"&x"00";
    end generate geni;
end generate genj;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
end arch ; -- arch

