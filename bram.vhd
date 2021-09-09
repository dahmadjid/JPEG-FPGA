library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.jpeg_pkg.all;

entity bram is
  port (
    channel : in unsigned(1 downto 0);
    clock : in std_logic;
    index : in unsigned(5 downto 0);
    q : out std_logic_vector (7 downto 0)
  ) ;
end bram;
architecture arch of bram is 

    signal address : std_logic_vector (17 downto 0);
    signal address_mat : address_mat_t;
    signal i,j: natural range 0 to 7;
begin
    
    bram_comp : bram_ip port map (
		address	 => address,
		clock	 => clock,
		data	 => "00000000",
		wren	 => '0',
		q	 => q
	);
    bidc : block_index_decoder port map(0,0,256,192,to_integer(channel),address_mat);
    i <=  natural(to_integer(index(5 downto 3)));
    j <=  natural(to_integer(index(2 downto 0)));
   address <= std_logic_vector(to_unsigned(address_mat(i)(j),18));
end arch ; -- arch