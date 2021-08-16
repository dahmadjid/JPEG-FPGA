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

end jpeg;

architecture arch of jpeg is
    signal img: image_block_t;
    signal dct_coeff_block: dct_coeff_block_t;
    
begin
img <= (("10000000","01111111","01111110","01111110","01111110","01111111","01111111","01111111"),
("01111111","01111111","01111111","01111111","01111111","01111111","01111111","01111110"),
("01111111","01111111","01111111","01111111","10000000","01111111","01111110","01111110"),
("01111111","01111111","01111111","01111111","01111111","01111111","01111110","01111110"),
("10000000","01111111","01111111","01111110","01111110","01111110","01111110","01111111"),
("10000000","01111111","01111111","01111110","01111101","01111101","01111110","01111111"),
("01111111","01111111","01111111","01111110","01111101","01111101","01111101","01111110"),
("01111110","01111110","01111111","01111110","01111110","01111101","01111101","01111101"));
genv: for v in 0 to 7 generate
    genu: for u in 0 to 7 generate
        dct_comp: dct port map(TO_UNSIGNED(u,3),TO_UNSIGNED(v,3),img,dct_coeff_block(v)(u));
    end generate genu;
end generate genv;

end arch ; 

