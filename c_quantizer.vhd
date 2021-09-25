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

type temp_t_t is array(7 downto 0) of sfixed(12 downto -16);
type temp_t is array(7 downto 0) of temp_t_t;
signal temp : temp_t;
begin
    
genj: for j in 0 to 7 generate
    geni: for i in 0 to 7 generate
        temp(j)(i) <= dct_coeff_block(j)(i) * chrominance_qz_fixed(j)(i);
        dct_coeff_qz(j)(i) <= temp(j)(i)(10 downto 0);
    end generate geni;
end generate genj;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
end arch ; -- arch

