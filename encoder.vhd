library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;



-- TODO: old_dc_reg, weird behavior, add handshake line
entity encoder is
  port (    
    clock : in std_logic;
    clr : in std_logic;
    old_dc_reg : in sfixed(10 downto 0);
    dct_coeff_zz : in dct_coeff_zz_t;
    encoding_done : out std_logic;
    length_o : out integer range 0 to 512;
    encoded_block : out std_logic_vector(511 downto 0)
    
  ) ;
end encoder;        

architecture arch of encoder is
    signal y_dc_code : y_dc_code_t ;
    signal y_ac_code : ac_code_t ;
    signal dc_huff_value,ac_huff_value : huff_value_t;
    signal huff_code, dc_huff_code : huff_code_t;

    signal code_ready,encoding_done_s,delay, table_load, manual,concat, concat_done, length_add, length_add_reset : std_logic;
    signal zrl_flag : std_logic_vector(2 downto 0) := "000";
    signal ac_huff_code,ac_huff_code_2 : huff_code_t;
    signal run_length : integer range 0 to 63 := 0;
    signal huff_code_index : integer range 0 to 63 := 0;
    signal encoded_block_s : std_logic_vector(511 downto 0);
    signal length : integer range 0 to 512;
    
    signal huff_value_zz : huff_value_zz_t;
    shared variable temp, temp2 : std_logic_vector(511 downto 0);
begin
    length_o <= length;
    encoding_done <= encoding_done_s;
    encoded_block <= encoded_block_s;
    
    mini_length_comp : mini_length_block port map(dct_coeff_zz(0) - "00000000000", dct_coeff_zz,huff_value_zz);

    y_dc_code <= y_dc_codes(huff_value_zz(0).code_length);
    dc_huff_value<= huff_value_zz(0);
    dc_huff_code <= y_dc_code + dc_huff_value;

    ac_huff_value <= huff_value_zz(huff_code_index);
    ac_table_comp : ac_huff_table port map(clock, clr, run_length, ac_huff_value, table_load, ac_huff_code, code_ready);
    
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

            elsif run_length > 60 then

                zrl_flag <= "100";
                run_length <= run_length - 60;
                table_load <= '0';

            elsif run_length > 45 then

                zrl_flag <= "011";
                run_length <= run_length - 45;
                table_load <= '0';

            elsif run_length > 30 then

                zrl_flag <= "010";
                run_length <= run_length - 30;
                table_load <= '0';

            elsif run_length > 15 then

                zrl_flag <= "001";
                run_length <= run_length - 15;
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
    
        if huff_code_index = 0 then
            huff_code <= dc_huff_code;    -- dc code
        elsif ac_huff_value.code_length = 0 and huff_code_index = 63 then
            huff_code <= y_eob;
        else
            huff_code <= ac_huff_code;
        end if;

    end process ; -- huff_code_pro

    writing_pr  : process(clock)
        
    begin
        
        if clr = '0' then
            temp := (others => '0');
            temp2 := (others => '0');
        else
            if zrl_flag = "000" then
                temp(511 downto 485) := huff_code.code;
                temp(484 downto 0) := (others => '0');
                
                -- length <= length + ac_huff_code.code_length;
            elsif zrl_flag = "001" then
                temp(511 downto 501) := y_zrl;
                temp(500 downto 474) := huff_code.code;
                temp(473 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 11;
            elsif zrl_flag = "010" then
                temp(511 downto 501) := y_zrl;
                temp(500 downto 490) := y_zrl;
                temp(489 downto 463) := huff_code.code;
                temp(462 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 22;
            elsif zrl_flag = "011" then
                temp(511 downto 501) := y_zrl;
                temp(500 downto 490) := y_zrl;
                temp(489 downto 479) := y_zrl;
                temp(478 downto 452) := huff_code.code;
                temp(451 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 33;
            else
                temp(511 downto 501) := y_zrl;
                temp(500 downto 490) := y_zrl;
                temp(489 downto 479) := y_zrl;
                temp(478 downto 468) := y_zrl;
                temp(467 downto 441) := huff_code.code;
                temp(440 downto 0) := (others => '0');

                
                -- length <= length + ac_huff_code.code_length + 44;
            end if;
            temp2 := shiftr(temp, length);
        end if;
    end process ; -- identifier
    
    falling_edge_encoded_block_output : process(clock )
        variable delay_counter : integer range 0 to 2;
        
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
                encoded_block_s <= encoded_block_s or temp2;
                length <= length + huff_code.code_length + to_integer(unsigned(zrl_flag)) * 11 ;
                concat_done <= '0';
                delay_counter := 2;
            elsif delay_counter = 2 then
                delay_counter := 0;
                concat_done <= '1';
            end if;
        elsif rising_edge(clock) then
            concat_done <= '0';
            delay_counter := 0;
        end if;
            
    end process ; -- falling_edge_encoded_block_output

end arch ; -- arch