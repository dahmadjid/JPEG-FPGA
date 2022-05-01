library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;

entity ac_huff_table is
  port (
    clock: in std_logic;
    clr: in std_logic;
    channel : in integer range 0 to 3;
    run_length: in integer range 0 to 63;
    huff_value: in huff_value_t;
    load : in std_logic;
    huff_code: out huff_code_t;
    code_ready: out std_logic
    
  ) ;
end ac_huff_table;

architecture arch of ac_huff_table is

    signal delay_counter : integer range 0 to 2;
    signal ac_code, y_ac_code, c_ac_code : ac_code_t;
    signal start : std_logic;
begin
    start_pr : process( clock )
    begin
        if clr = '0' or delay_counter = 2 then
            start <= '0';
        elsif falling_edge(load) then
            start <= '1';
        end if;
    end process ; -- start_pr
    table : process( clock )
    begin
        if falling_edge(clock) then
            if clr = '0' or start = '0' then
                code_ready <= '0';
                delay_counter <= 0;
            elsif delay_counter = 0 and start = '1' then
                y_ac_code <= y_ac_codes(run_length)(huff_value.code_length);
                c_ac_code <= c_ac_codes(run_length)(huff_value.code_length);
                code_ready <= '0';
                delay_counter <= 1;
            elsif delay_counter = 1 and start = '1' then
                code_ready <= '1';
                delay_counter <= 2;
            end if;
        end if;
    end process ; -- table
    ac_code <= y_ac_code when channel = 0 else c_ac_code;
    huff_code <= ac_code + huff_value;
end arch ; -- arch