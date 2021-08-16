library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
library work;
use work.jpeg_pkg.all;


entity c_quantizer is
  port (
    dct_coeff_block : in dct_coeff_block_t;
    dct_coeff_qz : out dct_coeff_block_t
  ) ;
end c_quantizer;

architecture arch of c_quantizer is

begin
genj: for j in 0 to 7 generate
    geni: for i in 0 to 7 generate
        dct_coeff_qz(j)(i) <= (dct_coeff_block(j)(i) * chrominance_qz_shift(j)(i))(26 downto 16);
    end generate geni;
end generate genj;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
end arch ; -- arch

