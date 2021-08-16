
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
library work;
use work.jpeg_pkg.all;


entity dct is
  port (
    u,v : in unsigned(2 downto 0);
    img_block : in image_block_t;
    dct_coeff : out sfixed(10 downto 0)
    
  ) ;
end dct;


architecture arch of dct is

    signal const: sfixed(1 downto -16);
    signal dct_coeff_temp: sfixed(31 downto -32);
    signal cos_mat_a: cos_mat_t;
    signal cos_mat_b: cos_mat_t;
   
begin

    cc: constant_v port map(u,v,const);
    
    geny: for y in 0 to 7 generate
        genx: for x in 0 to 7 generate
            ca: cos port map(u,to_unsigned(x,3),cos_mat_a(y)(x));
            cb: cos port map(v,to_unsigned(y,3),cos_mat_b(y)(x));
        end generate genx;
    end generate geny;
dct_coeff <= resize(const*const*cos_mat_a(0)(0) * cos_mat_b(0)(0) * to_integer(img_block(0)(0)) +const*const*cos_mat_a(0)(1) * cos_mat_b(0)(1) * to_integer(img_block(0)(1)) +const*const*cos_mat_a(0)(2) * cos_mat_b(0)(2) * to_integer(img_block(0)(2)) +const*const*cos_mat_a(0)(3) * cos_mat_b(0)(3) * to_integer(img_block(0)(3)) +const*const*cos_mat_a(0)(4) * cos_mat_b(0)(4) * to_integer(img_block(0)(4)) +const*const*cos_mat_a(0)(5) * cos_mat_b(0)(5) * to_integer(img_block(0)(5)) +const*const*cos_mat_a(0)(6) * cos_mat_b(0)(6) * to_integer(img_block(0)(6)) +const*const*cos_mat_a(0)(7) * cos_mat_b(0)(7) * to_integer(img_block(0)(7)) +const*const*cos_mat_a(1)(0) * cos_mat_b(1)(0) * to_integer(img_block(1)(0)) +const*const*cos_mat_a(1)(1) * cos_mat_b(1)(1) * to_integer(img_block(1)(1)) +const*const*cos_mat_a(1)(2) * cos_mat_b(1)(2) * to_integer(img_block(1)(2)) +const*const*cos_mat_a(1)(3) * cos_mat_b(1)(3) * to_integer(img_block(1)(3)) +const*const*cos_mat_a(1)(4) * cos_mat_b(1)(4) * to_integer(img_block(1)(4)) +const*const*cos_mat_a(1)(5) * cos_mat_b(1)(5) * to_integer(img_block(1)(5)) +const*const*cos_mat_a(1)(6) * cos_mat_b(1)(6) * to_integer(img_block(1)(6)) +const*const*cos_mat_a(1)(7) * cos_mat_b(1)(7) * to_integer(img_block(1)(7)) +const*const*cos_mat_a(2)(0) * cos_mat_b(2)(0) * to_integer(img_block(2)(0)) +const*const*cos_mat_a(2)(1) * cos_mat_b(2)(1) * to_integer(img_block(2)(1)) +const*const*cos_mat_a(2)(2) * cos_mat_b(2)(2) * to_integer(img_block(2)(2)) +const*const*cos_mat_a(2)(3) * cos_mat_b(2)(3) * to_integer(img_block(2)(3)) +const*const*cos_mat_a(2)(4) * cos_mat_b(2)(4) * to_integer(img_block(2)(4)) +const*const*cos_mat_a(2)(5) * cos_mat_b(2)(5) * to_integer(img_block(2)(5)) +const*const*cos_mat_a(2)(6) * cos_mat_b(2)(6) * to_integer(img_block(2)(6)) +const*const*cos_mat_a(2)(7) * cos_mat_b(2)(7) * to_integer(img_block(2)(7)) +const*const*cos_mat_a(3)(0) * cos_mat_b(3)(0) * to_integer(img_block(3)(0)) +const*const*cos_mat_a(3)(1) * cos_mat_b(3)(1) * to_integer(img_block(3)(1)) +const*const*cos_mat_a(3)(2) * cos_mat_b(3)(2) * to_integer(img_block(3)(2)) +const*const*cos_mat_a(3)(3) * cos_mat_b(3)(3) * to_integer(img_block(3)(3)) +const*const*cos_mat_a(3)(4) * cos_mat_b(3)(4) * to_integer(img_block(3)(4)) +const*const*cos_mat_a(3)(5) * cos_mat_b(3)(5) * to_integer(img_block(3)(5)) +const*const*cos_mat_a(3)(6) * cos_mat_b(3)(6) * to_integer(img_block(3)(6)) +const*const*cos_mat_a(3)(7) * cos_mat_b(3)(7) * to_integer(img_block(3)(7)) +const*const*cos_mat_a(4)(0) * cos_mat_b(4)(0) * to_integer(img_block(4)(0)) +const*const*cos_mat_a(4)(1) * cos_mat_b(4)(1) * to_integer(img_block(4)(1)) +const*const*cos_mat_a(4)(2) * cos_mat_b(4)(2) * to_integer(img_block(4)(2)) +const*const*cos_mat_a(4)(3) * cos_mat_b(4)(3) * to_integer(img_block(4)(3)) +const*const*cos_mat_a(4)(4) * cos_mat_b(4)(4) * to_integer(img_block(4)(4)) +const*const*cos_mat_a(4)(5) * cos_mat_b(4)(5) * to_integer(img_block(4)(5)) +const*const*cos_mat_a(4)(6) * cos_mat_b(4)(6) * to_integer(img_block(4)(6)) +const*const*cos_mat_a(4)(7) * cos_mat_b(4)(7) * to_integer(img_block(4)(7)) +const*const*cos_mat_a(5)(0) * cos_mat_b(5)(0) * to_integer(img_block(5)(0)) +const*const*cos_mat_a(5)(1) * cos_mat_b(5)(1) * to_integer(img_block(5)(1)) +const*const*cos_mat_a(5)(2) * cos_mat_b(5)(2) * to_integer(img_block(5)(2)) +const*const*cos_mat_a(5)(3) * cos_mat_b(5)(3) * to_integer(img_block(5)(3)) +const*const*cos_mat_a(5)(4) * cos_mat_b(5)(4) * to_integer(img_block(5)(4)) +const*const*cos_mat_a(5)(5) * cos_mat_b(5)(5) * to_integer(img_block(5)(5)) +const*const*cos_mat_a(5)(6) * cos_mat_b(5)(6) * to_integer(img_block(5)(6)) +const*const*cos_mat_a(5)(7) * cos_mat_b(5)(7) * to_integer(img_block(5)(7)) +const*const*cos_mat_a(6)(0) * cos_mat_b(6)(0) * to_integer(img_block(6)(0)) +const*const*cos_mat_a(6)(1) * cos_mat_b(6)(1) * to_integer(img_block(6)(1)) +const*const*cos_mat_a(6)(2) * cos_mat_b(6)(2) * to_integer(img_block(6)(2)) +const*const*cos_mat_a(6)(3) * cos_mat_b(6)(3) * to_integer(img_block(6)(3)) +const*const*cos_mat_a(6)(4) * cos_mat_b(6)(4) * to_integer(img_block(6)(4)) +const*const*cos_mat_a(6)(5) * cos_mat_b(6)(5) * to_integer(img_block(6)(5)) +const*const*cos_mat_a(6)(6) * cos_mat_b(6)(6) * to_integer(img_block(6)(6)) +const*const*cos_mat_a(6)(7) * cos_mat_b(6)(7) * to_integer(img_block(6)(7)) +const*const*cos_mat_a(7)(0) * cos_mat_b(7)(0) * to_integer(img_block(7)(0)) +const*const*cos_mat_a(7)(1) * cos_mat_b(7)(1) * to_integer(img_block(7)(1)) +const*const*cos_mat_a(7)(2) * cos_mat_b(7)(2) * to_integer(img_block(7)(2)) +const*const*cos_mat_a(7)(3) * cos_mat_b(7)(3) * to_integer(img_block(7)(3)) +const*const*cos_mat_a(7)(4) * cos_mat_b(7)(4) * to_integer(img_block(7)(4)) +const*const*cos_mat_a(7)(5) * cos_mat_b(7)(5) * to_integer(img_block(7)(5)) +const*const*cos_mat_a(7)(6) * cos_mat_b(7)(6) * to_integer(img_block(7)(6)) +const*const*cos_mat_a(7)(7) * cos_mat_b(7)(7) 
* to_integer(img_block(7)(7)),10,0);

end arch ; -- arch