library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;


entity constant_v is
  port (
    u,x : in UNSIGNED(2 downto 0);
    const : out sfixed(1 downto -16)
  ) ;
end constant_v;

architecture arch of constant_v is

    signal ux : UNSIGNED(5 downto 0);

begin
    ux <= u&x;
    with ux select
    const <= "000101101010000010" when "000000",
             "000100000000000000" when others;
end arch ; -- arch
