library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;



-- TODO: potential ZRL bug, ZRL may mean 16 zeros not 15 because its (F, 0), should be easy fix
entity encoder is
  port (    

    clock : in std_logic;
    clr : in std_logic;
    increment_block_count : in std_logic;
    channel : in integer range 0 to 3;
    dct_coeff_zz : in dct_coeff_zz_t;
    encoding_done : out std_logic;
    length_o : out integer range 0 to 512;
    encoded_block : out std_logic_vector(511 downto 0)
    
  ) ;
end encoder;        

architecture arch of encoder is
    signal y_dc_code : y_dc_code_t ;
    signal c_dc_code : c_dc_code_t ;
    signal y_ac_code : ac_code_t ;
    signal dc_huff_value,ac_huff_value : huff_value_t;
    signal huff_code, dc_huff_code, dc_huff_code_y ,dc_huff_code_c, eob : huff_code_t;
    signal dc_coeff_diff : sfixed(11 downto 0);
    signal code_ready,encoding_done_s,delay, table_load, manual,concat, concat_done, length_add, length_add_reset : std_logic;
    signal zrl_flag : std_logic_vector(2 downto 0) := "000";
    signal ac_huff_code,ac_huff_code_2, temp_reg : huff_code_t;
    signal run_length : integer range 0 to 63 := 0;
    signal huff_code_index : integer range 0 to 63 := 0;
    signal encoded_block_s : std_logic_vector(511 downto 0);
    signal length : integer range 0 to 512;
    signal prev_dc_y, prev_dc_cb, prev_dc_cr : sfixed(10 downto 0) := "00000000000";
    signal huff_value_zz : huff_value_zz_t;
    signal temp : std_logic_vector(511 downto 0);
    shared variable temp_y, temp_y2, temp_c, temp_c2 : std_logic_vector(511 downto 0);
begin
    length_o <= length;
    encoding_done <= encoding_done_s;
    encoded_block <= encoded_block_s;

    old_dc_reg_pr : process(clock )
    begin  
        
        if rising_edge(clock) and encoding_done_s = '1' then
            if channel = 0 then
                prev_dc_y <= dct_coeff_zz(0);
            elsif channel = 1 then
                prev_dc_cb <= dct_coeff_zz(0);
            elsif channel = 2 then
                prev_dc_cr <= dct_coeff_zz(0);
            end if;
        end if;
    end process ; -- old_dc_reg_pr
    
    mini_length_comp : mini_length_block port map(clock,increment_block_count ,channel , prev_dc_y, prev_dc_cb, prev_dc_cr, dct_coeff_zz, huff_value_zz);

    eob <= y_eob when channel = 0 else c_eob;

    y_dc_code <= y_dc_codes(huff_value_zz(0).code_length);
    c_dc_code <= c_dc_codes(huff_value_zz(0).code_length);
    
    dc_huff_value <= huff_value_zz(0);
    dc_huff_code_y <= y_dc_code + dc_huff_value;
    dc_huff_code_c <= c_dc_code + dc_huff_value;
    dc_huff_code <= dc_huff_code_y when channel = 0 else dc_huff_code_c;
    
    ac_huff_value <= huff_value_zz(huff_code_index);
    ac_table_comp : ac_huff_table port map(clock, clr, channel, run_length, ac_huff_value, table_load, ac_huff_code, code_ready);
    
    concatination_on_going : process( clock )
    begin
     
        if clr = '0' or encoding_done_s = '1' or concat_done = '1' then
            concat <= '0';
        elsif falling_edge(table_load) then
            concat <= '1';
        end if; 

    end process ; -- shifting_on_going

    huff_code_index_pr : process(clock)
    begin
        if clr = '0' then
            huff_code_index <= 0;
            encoding_done_s <= '0';
        elsif falling_edge(clock) and concat = '0' and table_load = '1' and code_ready = '0' then  
            if huff_code_index = 63 then
                encoding_done_s <= '1'; 
            else
                huff_code_index <= huff_code_index + 1;
                encoding_done_s <= '0';
            end if;
        end if; 
    end process ; 
    

    
    ac_encoding : process(clock,encoding_done_s)
    begin
        if clr = '0' or encoding_done_s = '1' then
            run_length <= 0;
            
            zrl_flag <= "000";
            table_load <= '1';

        elsif rising_edge(clock) and table_load = '0' and code_ready = '1' then
            
            table_load <= '1';  
            run_length <= 0;
 
        elsif rising_edge(clock) and concat = '0' then
            if huff_code_index = 0 then

                table_load <= '0';
                zrl_flag <= "000";

            elsif ac_huff_value.code_length = 0 and huff_code_index = 63 then

                table_load <= '0';
                zrl_flag <= "000";

            elsif ac_huff_value.code_length = 0 then
                run_length <= run_length + 1;

                table_load <= '1';
                zrl_flag <= "000";

            -- elsif run_length > 63 then

            --     zrl_flag <= "100";
            --     run_length <= run_length - 64';
            --     table_load <= '0';

            elsif run_length > 47 then

                zrl_flag <= "011";
                run_length <= run_length - 46;
                table_load <= '0';

            elsif run_length > 31 then

                zrl_flag <= "010";
                run_length <= run_length - 32;
                table_load <= '0';

            elsif run_length > 15 then

                zrl_flag <= "001";
                run_length <= run_length - 16;
                table_load <= '0';
            else 
                zrl_flag <= "000";
                run_length <= run_length;
                table_load <= '0';
            end if;
        end if; 
    end process ; -- ac_encoding

    huff_code_pro : process( clock )
    begin
        if rising_edge(clock) then
            if huff_code_index = 0 then
                huff_code <= dc_huff_code;    -- dc code
            elsif ac_huff_value.code_length = 0 and huff_code_index = 63 then
                huff_code <= eob;
            else
                huff_code <= ac_huff_code;
            end if;
        end if;

    end process ; -- huff_code_pro





    writing_pr_y  : process(clock)    
    begin
        if clr = '0' then
            temp_y := (others => '0');
            temp_y2 := (others => '0');
        else
            if zrl_flag = "000" then
                temp_y(511 downto 485) := huff_code.code;
                temp_y(484 downto 0) := (others => '0');
                
                -- length <= length + ac_huff_code.code_length;
            elsif zrl_flag = "001" then
                temp_y(511 downto 501) := y_zrl;
                temp_y(500 downto 474) := huff_code.code;
                temp_y(473 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 11;
            elsif zrl_flag = "010" then
                temp_y(511 downto 501) := y_zrl;
                temp_y(500 downto 490) := y_zrl;
                temp_y(489 downto 463) := huff_code.code;
                temp_y(462 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 22;
            else
                temp_y(511 downto 501) := y_zrl;
                temp_y(500 downto 490) := y_zrl;
                temp_y(489 downto 479) := y_zrl;
                temp_y(478 downto 452) := huff_code.code;
                temp_y(451 downto 0) := (others => '0');
            end if;
            temp_y2 := shiftr(temp_y, length);
        end if;
    end process ; -- identifier

    writing_pr_c  : process(clock)    
    begin
        if clr = '0' then
            temp_c := (others => '0');
            temp_c2 := (others => '0');
        else
            if zrl_flag = "000" then
                temp_c(511 downto 485) := huff_code.code;
                temp_c(484 downto 0) := (others => '0');
                
                -- length <= length + ac_huff_code.code_length;
            elsif zrl_flag = "001" then
                temp_c(511 downto 502) := c_zrl;
                temp_c(501 downto 475) := huff_code.code;
                temp_c(474 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 11;
            elsif zrl_flag = "010" then
                temp_c(511 downto 502) := c_zrl;
                temp_c(501 downto 492) := c_zrl;
                temp_c(491 downto 465) := huff_code.code;
                temp_c(464 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 22;
            else
                temp_c(511 downto 502) := c_zrl;
                temp_c(501 downto 492) := c_zrl;
                temp_c(491 downto 482) := c_zrl;
                temp_c(481 downto 455) := huff_code.code;
                temp_c(454 downto 0) := (others => '0');
            end if;
            temp_c2 := shiftr(temp_c, length);
        end if;
    end process ; -- identifier

    temp <= temp_y2 when channel = 0 else temp_c2;


    falling_edge_encoded_block_output : process(clock )
        variable delay_counter : integer range 0 to 3;
    begin
        if clr = '0'  then
            encoded_block_s <= (others => '0');
            length <= 0;
            delay_counter := 0;
            concat_done <= '0';
        elsif rising_edge(clock) and concat = '1' then
            if code_ready = '1' then
                delay_counter := 1;
                concat_done <= '0';
            elsif delay_counter = 1 then
                encoded_block_s <= encoded_block_s or temp;
                length <= length + huff_code.code_length + to_integer(unsigned(zrl_flag)) * 11 ;
                concat_done <= '0';
                delay_counter := 2;
            elsif delay_counter = 2 then
                delay_counter := 3;
                concat_done <= '0';
            elsif delay_counter = 3 then
                delay_counter := 0;
                concat_done <= '1';
            end if;
        elsif rising_edge(clock) then
            concat_done <= '0';
            delay_counter := 0;
        end if;
            
    end process ; -- falling_edge_encoded_block_output

end arch ; -- arch
