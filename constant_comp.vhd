library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

-- TESTED IN FPGA. WORKS GOOD
entity constant_comp is
  port (
    u,v : in UNSIGNED(2 downto 0);
    const : out sfixed(1 downto -16)
  ) ;
end constant_comp;

architecture arch of constant_comp is
begin

    const <="000010000000000000" when (u = "000" and v = "000") else
            "000010110101000001" when (u = "000" and v /= "000") or (u /= "000" and v = "000") else
            "000100000000000000";
end arch ; -- arch
