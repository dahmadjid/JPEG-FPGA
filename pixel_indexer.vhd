library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;



entity pixel_indexer is
  port (
    data : in std_logic_vector(511 downto 0);
    index : in integer range 0 to 63;
    pixel : out sfixed(7 downto 0)
  ) ;
end pixel_indexer;


architecture arch of pixel_indexer is

    

begin
    pixel_pr : process( data )
    begin
        case index is
            when 0 =>
                pixel <= sfixed(data(511 downto 504));
            when 1 =>
                pixel <= sfixed(data(503 downto 496));
            when 2 =>
                pixel <= sfixed(data(495 downto 488));
            when 3 =>
                pixel <= sfixed(data(487 downto 480));
            when 4 =>
                pixel <= sfixed(data(479 downto 472));
            when 5 =>
                pixel <= sfixed(data(471 downto 464));
            when 6 =>
                pixel <= sfixed(data(463 downto 456));
            when 7 =>
                pixel <= sfixed(data(455 downto 448));
            when 8 =>
                pixel <= sfixed(data(447 downto 440));
            when 9 =>
                pixel <= sfixed(data(439 downto 432));
            when 10 =>
                pixel <= sfixed(data(431 downto 424));
            when 11 =>
                pixel <= sfixed(data(423 downto 416));
            when 12 =>
                pixel <= sfixed(data(415 downto 408));
            when 13 =>
                pixel <= sfixed(data(407 downto 400));
            when 14 =>
                pixel <= sfixed(data(399 downto 392));
            when 15 =>
                pixel <= sfixed(data(391 downto 384));
            when 16 =>
                pixel <= sfixed(data(383 downto 376));
            when 17 =>
                pixel <= sfixed(data(375 downto 368));
            when 18 =>
                pixel <= sfixed(data(367 downto 360));
            when 19 =>
                pixel <= sfixed(data(359 downto 352));
            when 20 =>
                pixel <= sfixed(data(351 downto 344));
            when 21 =>
                pixel <= sfixed(data(343 downto 336));
            when 22 =>
                pixel <= sfixed(data(335 downto 328));
            when 23 =>
                pixel <= sfixed(data(327 downto 320));
            when 24 =>
                pixel <= sfixed(data(319 downto 312));
            when 25 =>
                pixel <= sfixed(data(311 downto 304));
            when 26 =>
                pixel <= sfixed(data(303 downto 296));
            when 27 =>
                pixel <= sfixed(data(295 downto 288));
            when 28 =>
                pixel <= sfixed(data(287 downto 280));
            when 29 =>
                pixel <= sfixed(data(279 downto 272));
            when 30 =>
                pixel <= sfixed(data(271 downto 264));
            when 31 =>
                pixel <= sfixed(data(263 downto 256));
            when 32 =>
                pixel <= sfixed(data(255 downto 248));
            when 33 =>
                pixel <= sfixed(data(247 downto 240));
            when 34 =>
                pixel <= sfixed(data(239 downto 232));
            when 35 =>
                pixel <= sfixed(data(231 downto 224));
            when 36 =>
                pixel <= sfixed(data(223 downto 216));
            when 37 =>
                pixel <= sfixed(data(215 downto 208));
            when 38 =>
                pixel <= sfixed(data(207 downto 200));
            when 39 =>
                pixel <= sfixed(data(199 downto 192));
            when 40 =>
                pixel <= sfixed(data(191 downto 184));
            when 41 =>
                pixel <= sfixed(data(183 downto 176));
            when 42 =>
                pixel <= sfixed(data(175 downto 168));
            when 43 =>
                pixel <= sfixed(data(167 downto 160));
            when 44 =>
                pixel <= sfixed(data(159 downto 152));
            when 45 =>
                pixel <= sfixed(data(151 downto 144));
            when 46 =>
                pixel <= sfixed(data(143 downto 136));
            when 47 =>
                pixel <= sfixed(data(135 downto 128));
            when 48 =>
                pixel <= sfixed(data(127 downto 120));
            when 49 =>
                pixel <= sfixed(data(119 downto 112));
            when 50 =>
                pixel <= sfixed(data(111 downto 104));
            when 51 =>
                pixel <= sfixed(data(103 downto 96));
            when 52 =>
                pixel <= sfixed(data(95 downto 88));
            when 53 =>
                pixel <= sfixed(data(87 downto 80));
            when 54 =>
                pixel <= sfixed(data(79 downto 72));
            when 55 =>
                pixel <= sfixed(data(71 downto 64));
            when 56 =>
                pixel <= sfixed(data(63 downto 56));
            when 57 =>
                pixel <= sfixed(data(55 downto 48));
            when 58 =>
                pixel <= sfixed(data(47 downto 40));
            when 59 =>
                pixel <= sfixed(data(39 downto 32));
            when 60 =>
                pixel <= sfixed(data(31 downto 24));
            when 61 =>
                pixel <= sfixed(data(23 downto 16));
            when 62 =>
                pixel <= sfixed(data(15 downto 8));
            when 63 =>
                pixel <= sfixed(data(7 downto 0));

        end case;
    end process ; -- pixel

end arch ; -- arch


