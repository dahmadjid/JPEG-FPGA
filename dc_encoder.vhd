library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dc_encoder is
    port 
    (
        dct_coeff : in signed(10 downto 0);
        length : out unsigned(3 downto 0);
        huff_value : out unsigned(9 downto 0)

    ) ;
end dc_encoder;
architecture arch of dc_encoder is
    
    begin
    len: mini_length port map(dct_coeff,length_temp);

    end arch;