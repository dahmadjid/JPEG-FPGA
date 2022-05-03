library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;



package jpeg_pkg is 
    
    type image_row_t is array (0 to 7) of sfixed(7 downto 0);
    type image_block_t is array (0 to 7) of image_row_t; --8 by 8 block of image
    type qz_row_t is array (0 to 7) of sfixed(1 downto -32);
    type qz_table_t is array (0 to 7) of qz_row_t;
    type dct_coeff_row_t is array(0 to 7) of sfixed(10 downto 0);
    type dct_coeff_block_t is array(0 to 7) of dct_coeff_row_t; --8 by 8 dct coeff array
    -- type dct_coeff_yx_row_t is array(0 to 7) of sfixed(13 downto -32);
    -- type dct_coeff_yx_mat_t is array(0 to 7) of dct_coeff_yx_row_t;
    type cos_row_t is array(0 to 7) of sfixed(1 downto -16);
    type cos_mat_t is array(0 to 7) of cos_row_t;
    type address_row_t is array(0 to 7) of integer range 0 to 262144;
    type address_mat_t is array(0 to 7) of address_row_t;
    type dct_coeff_zz_t is array(0 to 63) of sfixed(10 downto 0);
    type length_zz_t is array(0 to 63) of unsigned(3 downto 0);
    type pixel_array_t is array(0 to 255) of sfixed(7 downto 0);
    type huff_value_t is record  
        code : std_logic_vector(10 downto 0);
        code_length : integer range 0 to 11;
    end record;

    type y_dc_code_t is record
        code : std_logic_vector(8 downto 0);
        code_length : integer range 1 to 9;
    end record;

    type c_dc_code_t is record  
        code : std_logic_vector(10 downto 0);
        code_length : integer range 1 to 11;
    end record;

    type ac_code_t is record
        code : std_logic_vector(15 downto 0);
        code_length : integer range 1 to 16;
    end record;

    type huff_value_zz_t is array(0 to 63) of huff_value_t; --

    type y_dc_code_table_t is array(0 to 11) of y_dc_code_t;
    type c_dc_code_table_t is array(0 to 11) of c_dc_code_t;
    
    type ac_code_row_t is array(1 to 10) of ac_code_t;
    type ac_code_table_t is array(0 to 15) of ac_code_row_t;
    
    type huff_code_t is record
        code : std_logic_vector(26 downto 0);
        code_length : integer range 1 to 27;
    end record;
    type huff_code_table_t is array(0 to 63) of huff_code_t;
    
    -- constant luminance_qz: image_block_t := (
    -- ("00010000","00001011","00001010","00010000","00011000","00101000","00110011","00111101"),
    -- ("00001100","00001100","00001110","00010011","00011010","00111010","00111100","00110111"),
    -- ("00001110","00001101","00010000","00011000","00101000","00111001","01000101","00111000"),
    -- ("00001110","00010001","00010110","00011101","00110011","01010111","01010000","00111110"),
    -- ("00010010","00010110","00100101","00111000","01000100","01101101","01100111","01001101"),
    -- ("00011000","00100011","00110111","01000000","01010001","01101000","01110001","01011100"),
    -- ("00110001","01000000","01001110","01010111","01100111","01111001","01111000","01100101"),
    -- ("01001000","01011100","01011111","01100010","01110000","01100100","01100111","01100011"));
    
    -- constant chrominance_qz: image_block_t := (
    -- ("00010001","00010010","00011000","00101111","01100011","01100011","01100011","01100011"),
    -- ("00010010","00010101","00011010","01000010","01100011","01100011","01100011","01100011"),
    -- ("00011000","00011010","00111000","01100011","01100011","01100011","01100011","01100011"),
    -- ("00101111","01000010","01100011","01100011","01100011","01100011","01100011","01100011"),
    -- ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"),
    -- ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"),
    -- ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"),
    -- ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"));
    
    constant luminance_qz_fixed: qz_table_t := (
    ("0000010000000000000000000000000000","0000010111010001011101000101110100","0000011001100110011001100110011001","0000010000000000000000000000000000","0000001010101010101010101010101010","0000000110011001100110011001100110","0000000101000001010000010100000101","0000000100001100100101110001010011"),
    ("0000010101010101010101010101010101","0000010101010101010101010101010101","0000010010010010010010010010010010","0000001101011110010100001101011110","0000001001110110001001110110001001","0000000100011010011110111001011000","0000000100010001000100010001000100","0000000100101001111001000001001010"),
    ("0000010010010010010010010010010010","0000010011101100010011101100010011","0000010000000000000000000000000000","0000001010101010101010101010101010","0000000110011001100110011001100110","0000000100011111011100000100011111","0000000011101101011100110000001110","0000000100100100100100100100100100"),
    ("0000010010010010010010010010010010","0000001111000011110000111100001111","0000001011101000101110100010111010","0000001000110100111101110010110000","0000000101000001010000010100000101","0000000010111100010100100110010000","0000000011001100110011001100110011","0000000100001000010000100001000010"),
    ("0000001110001110001110001110001110","0000001011101000101110100010111010","0000000110111010110011111001000101","0000000100100100100100100100100100","0000000011110000111100001111000011","0000000010010110010011111101101001","0000000010011111000100010110010111","0000000011010100110001110111101100"),
    ("0000001010101010101010101010101010","0000000111010100000111010100000111","0000000100101001111001000001001010","0000000100000000000000000000000000","0000000011001010010001011000011111","0000000010011101100010011101100010","0000000010010000111111011011110000","0000000010110010000101100100001011"),
    ("0000000101001110010111100000101001","0000000100000000000000000000000000","0000000011010010000011010010000011","0000000010111100010100100110010000","0000000010011111000100010110010111","0000000010000111011001111010101101","0000000010001000100010001000100010","0000000010100010001101111100001100"),
    ("0000000011100011100011100011100011","0000000010110010000101100100001011","0000000010101100011101101001000110","0000000010100111001011110000010100","0000000010010010010010010010010010","0000000010100011110101110000101000","0000000010011111000100010110010111","0000000010100101011111101011010100"));
    constant chrominance_qz_fixed: qz_table_t := (
    ("0000001111000011110000111100001111","0000001110001110001110001110001110","0000001010101010101010101010101010","0000000101011100100110001000001010","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000001110001110001110001110001110","0000001100001100001100001100001100","0000001001110110001001110110001001","0000000011111000001111100000111110","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000001010101010101010101010101010","0000001001110110001001110110001001","0000000100100100100100100100100100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000000101011100100110001000001010","0000000011111000001111100000111110","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"),
    ("0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100","0000000010100101011111101011010100"));

    constant y_dc_codes : y_dc_code_table_t := (("000000000",2),("000000010",3),("000000011",3),("000000100",3),("000000101",3),("000000110",3),("000001110",4),("000011110",5),("000111110",6),("001111110",7),("011111110",8),("111111110",9));

    constant c_dc_codes : c_dc_code_table_t := (("00000000000",2),("00000000001",2),("00000000010",2),("00000000110",3),("00000001110",4),("00000011110",5),("00000111110",6),("00001111110",7),("00011111110",8),("00111111110",9),("01111111110",10),("11111111110",11));
    
    constant y_ac_codes : ac_code_table_t :=
    ((("0000000000000000",2),("0000000000000001",2),("0000000000000100",3),("0000000000001011",4),("0000000000011010",5),("0000000001111000",7),("0000000011111000",8),("0000001111110110",10),("1111111110000010",16),("1111111110000011",16)),
    (("0000000000001100",4),("0000000000011011",5),("0000000001111001",7),("0000000111110110",9),("0000011111110110",11),("1111111110000100",16),("1111111110000101",16),("1111111110000110",16),("1111111110000111",16),("1111111110001000",16)),
    (("0000000000011100",5),("0000000011111001",8),("0000001111110111",10),("0000111111110100",12),("1111111110001001",16),("1111111110001010",16),("1111111110001011",16),("1111111110001100",16),("1111111110001101",16),("1111111110001110",16)),
    (("0000000000111010",6),("0000000111110111",9),("0000111111110101",12),("1111111110001111",16),("1111111110010000",16),("1111111110010001",16),("1111111110010010",16),("1111111110010011",16),("1111111110010100",16),("1111111110010101",16)),
    (("0000000000111011",6),("0000001111111000",10),("1111111110010110",16),("1111111110010111",16),("1111111110011000",16),("1111111110011001",16),("1111111110011010",16),("1111111110011011",16),("1111111110011100",16),("1111111110011101",16)),
    (("0000000001111010",7),("0000011111110111",11),("1111111110011110",16),("1111111110011111",16),("1111111110100000",16),("1111111110100001",16),("1111111110100010",16),("1111111110100011",16),("1111111110100100",16),("1111111110100101",16)),
    (("0000000001111011",7),("0000111111110110",12),("1111111110100110",16),("1111111110100111",16),("1111111110101000",16),("1111111110101001",16),("1111111110101010",16),("1111111110101011",16),("1111111110101100",16),("1111111110101101",16)),
    (("0000000011111010",8),("0000111111110111",12),("1111111110101110",16),("1111111110101111",16),("1111111110110000",16),("1111111110110001",16),("1111111110110010",16),("1111111110110011",16),("1111111110110100",16),("1111111110110101",16)),
    (("0000000111111000",9),("0111111111000000",15),("1111111110110110",16),("1111111110110111",16),("1111111110111000",16),("1111111110111001",16),("1111111110111010",16),("1111111110111011",16),("1111111110111100",16),("1111111110111101",16)),
    (("0000000111111001",9),("1111111110111110",16),("1111111110111111",16),("1111111111000000",16),("1111111111000001",16),("1111111111000010",16),("1111111111000011",16),("1111111111000100",16),("1111111111000101",16),("1111111111000110",16)),
    (("0000000111111010",9),("1111111111000111",16),("1111111111001000",16),("1111111111001001",16),("1111111111001010",16),("1111111111001011",16),("1111111111001100",16),("1111111111001101",16),("1111111111001110",16),("1111111111001111",16)),
    (("0000001111111001",10),("1111111111010000",16),("1111111111010001",16),("1111111111010010",16),("1111111111010011",16),("1111111111010100",16),("1111111111010101",16),("1111111111010110",16),("1111111111010111",16),("1111111111011000",16)),
    (("0000001111111010",10),("1111111111011001",16),("1111111111011010",16),("1111111111011011",16),("1111111111011100",16),("1111111111011101",16),("1111111111011110",16),("1111111111011111",16),("1111111111100000",16),("1111111111100001",16)),
    (("0000011111111000",11),("1111111111100010",16),("1111111111100011",16),("1111111111100100",16),("1111111111100101",16),("1111111111100110",16),("1111111111100111",16),("1111111111101000",16),("1111111111101001",16),("1111111111101010",16)),
    (("1111111111101011",16),("1111111111101100",16),("1111111111101101",16),("1111111111101110",16),("1111111111101111",16),("1111111111110000",16),("1111111111110001",16),("1111111111110010",16),("1111111111110011",16),("1111111111110100",16)),
    (("1111111111110101",16),("1111111111110110",16),("1111111111110111",16),("1111111111111000",16),("1111111111111001",16),("1111111111111010",16),("1111111111111011",16),("1111111111111100",16),("1111111111111101",16),("1111111111111110",16)));
    
    constant c_ac_codes : ac_code_table_t := 
    ((("0000000000000001",2),("0000000000000100",3),("0000000000001010",4),("0000000000011000",5),("0000000000011001",5),("0000000000111000",6),("0000000001111000",7),("0000000111110100",9),("0000001111110110",10),("0000111111110100",12)),
    (("0000000000001011",4),("0000000000111001",6),("0000000011110110",8),("0000000111110101",9),("0000011111110110",11),("0000111111110101",12),("1111111110001000",16),("1111111110001001",16),("1111111110001010",16),("1111111110001011",16)),
    (("0000000000011010",5),("0000000011110111",8),("0000001111110111",10),("0000111111110110",12),("0111111111000010",15),("1111111110001100",16),("1111111110001101",16),("1111111110001110",16),("1111111110001111",16),("1111111110010000",16)),
    (("0000000000011011",5),("0000000011111000",8),("0000001111111000",10),("0000111111110111",12),("1111111110010001",16),("1111111110010010",16),("1111111110010011",16),("1111111110010100",16),("1111111110010101",16),("1111111110010110",16)),
    (("0000000000111010",6),("0000000111110110",9),("1111111110010111",16),("1111111110011000",16),("1111111110011001",16),("1111111110011010",16),("1111111110011011",16),("1111111110011100",16),("1111111110011101",16),("1111111110011110",16)),
    (("0000000000111011",6),("0000001111111001",10),("1111111110011111",16),("1111111110100000",16),("1111111110100001",16),("1111111110100010",16),("1111111110100011",16),("1111111110100100",16),("1111111110100101",16),("1111111110100110",16)),
    (("0000000001111001",7),("0000011111110111",11),("1111111110100111",16),("1111111110101000",16),("1111111110101001",16),("1111111110101010",16),("1111111110101011",16),("1111111110101100",16),("1111111110101101",16),("1111111110101110",16)),
    (("0000000001111010",7),("0000111111110000",12),("1111111110101111",16),("1111111110110000",16),("1111111110110001",16),("1111111110110010",16),("1111111110110011",16),("1111111110110100",16),("1111111110110101",16),("1111111110110110",16)),
    (("0000000011111001",8),("1111111110110111",16),("1111111110111000",16),("1111111110111001",16),("1111111110111010",16),("1111111110111011",16),("1111111110111100",16),("1111111110111101",16),("1111111110111110",16),("1111111110111111",16)),
    (("0000000111110111",9),("1111111111000000",16),("1111111111000001",16),("1111111111000010",16),("1111111111000011",16),("1111111111000100",16),("1111111111000101",16),("1111111111000110",16),("1111111111000111",16),("1111111111001000",16)),
    (("0000000111111000",9),("1111111111001001",16),("1111111111001010",16),("1111111111001011",16),("1111111111001100",16),("1111111111001101",16),("1111111111001110",16),("1111111111001111",16),("1111111111010000",16),("1111111111010001",16)),
    (("0000000111111001",9),("1111111111010010",16),("1111111111010011",16),("1111111111010100",16),("1111111111010101",16),("1111111111010110",16),("1111111111010111",16),("1111111111011000",16),("1111111111011001",16),("1111111111011010",16)),
    (("0000000111111010",9),("1111111111011011",16),("1111111111011100",16),("1111111111011101",16),("1111111111011110",16),("1111111111011111",16),("1111111111100000",16),("1111111111100001",16),("1111111111100010",16),("1111111111100011",16)),
    (("0000011111111001",11),("1111111111100100",16),("1111111111100101",16),("1111111111100110",16),("1111111111100111",16),("1111111111101000",16),("1111111111101001",16),("1111111111101010",16),("1111111111101011",16),("1111111111101100",16)),
    (("0011111111100000",14),("1111111111101101",16),("1111111111101110",16),("1111111111101111",16),("1111111111110000",16),("1111111111110001",16),("1111111111110010",16),("1111111111110011",16),("1111111111110100",16),("1111111111110101",16)),
    (("0111111111000011",15),("1111111111110110",16),("1111111111110111",16),("1111111111111000",16),("1111111111111001",16),("1111111111111010",16),("1111111111111011",16),("1111111111111100",16),("1111111111111101",16),("1111111111111110",16)));
    
    constant y_zrl : std_logic_vector(10 downto 0) := "11111111001";
    constant y_eob : huff_code_t := ("101000000000000000000000000",4);

    constant c_eob : huff_code_t := ("000000000000000000000000000",2);
    constant c_zrl : std_logic_vector(9 downto 0) := "1111111010";

    function "+"( y_dc_code : y_dc_code_t; huff_value : huff_value_t) return huff_code_t;
    function "+" ( c_dc_code : c_dc_code_t; huff_value : huff_value_t) return huff_code_t;
    function "+" ( ac_code : ac_code_t;  huff_value : huff_value_t) return huff_code_t;
    function shiftl (arg : std_logic_vector;count : integer) return std_logic_vector;
    function shiftr (arg : std_logic_vector;count : integer) return std_logic_vector;
    
    component cos is   
        port 
        (
        u,x : in unsigned(2 downto 0);     -- or v,y
        c : out sfixed(1 downto -16)       --c is cos in signed fixed point
        );
    end component;
   
    component dct is
        port (
            v,u: in unsigned(2 downto 0);
            img_pixel : in sfixed(7 downto 0);
            clock,dct_working,dct_finished : in std_logic;
            --v_u_index : in unsigned(5 downto 0);
            --y_x_index : in unsigned(5 downto 0);
            y,x : in integer range 0 to 7;
            const : in sfixed(1 downto -16);
            dct_coeff : out sfixed(10 downto 0)
        ) ;
    end component;

    component dct_block is
        port (
        clock,dct_start : in std_logic;
        dct_working : out std_logic;
        img_pixel : in sfixed(7 downto 0);
        y_x_index : out integer range 0 to 63;
        dct_coeff_block : out dct_coeff_block_t
            -- v_in,u_in : in unsigned(2 downto 0);
            -- -- hex_1,hex_2 : out std_logic_vector(6 downto 0);
            -- dct_coeff : out sfixed(10 downto 0)     
        ) ;
    end component ;
    component mini_length is
        port 
        (
            dct_coeff : in sfixed(10 downto 0);  
            huff_value : out huff_value_t
        ) ;
    end component;
    component mini_length_block is
        port (
            clock : in std_logic;
            increment_block_count : in std_logic;
            
            channel : in integer range 0 to 2;
            old_dc_reg_y : in sfixed(10 downto 0);
            old_dc_reg_cb : in sfixed(10 downto 0);
            old_dc_reg_cr : in sfixed(10 downto 0);
            dct_coeff_zz : in dct_coeff_zz_t;
            huff_value_zz : out huff_value_zz_t
        ) ;
      end component;
    component quantizer is
    port (
        dct_coeff_block : in dct_coeff_block_t;
        channel : in integer range 0 to 2;
        dct_coeff_qz : out dct_coeff_block_t
    ) ;
    end component;

    component bram_ip
	port
	(
        address : in std_logic_vector (17 downto 0);
        clock : in std_logic;
        data : in std_logic_vector (7 downto 0);
        wren : in std_logic;
        q : out std_logic_vector (7 downto 0)
	);
    end component;
    component rgb_ycbcr is
        port (

        r,g,b : in unsigned(7 downto 0);
        
         -- i : in std_logic_vector(1 downto 0);
        y,cb,cr : out sfixed(7 downto 0)
          --dct_coeff : out sfixed(7 downto 0)
        ) ;
      end component;
    component block_index_decoder is
        port (
            y_x_index: in unsigned(5 downto 0);
            row_block_index , col_block_index : in integer range 0 to 63;
            width,height : in integer range 0 to 256;
            channel : in integer range 0 to 2;
            address : out integer range 0 to 262144
        
        ) ;
    end component;
    component zigzag is
        port (
          dct_coeff_block_qz : in dct_coeff_block_t;
          dct_coeff_zz : out dct_coeff_zz_t
        ) ;
    end component;

    component spi_master is
        generic (
            transaction_length : natural := 8 * 8);
        port (
            clock :in std_logic;
            clr : in std_logic;
    
            data_tx : in std_logic_vector(transaction_length - 1 downto 0);  -- data to be sent
            data_tx_rdy : in std_logic; -- data ready to be written from data_tx register and starts the transimision in the next clock cycle
    
            --data_reg : out std_logic_vector(transaction_length - 1 downto 0);
    
            data_rx : out std_logic_vector(transaction_length - 1 downto 0);  -- data recieved from slave
            data_rx_rdy : out std_logic; -- data ready to be read from data_rx register
    
            sck : out std_logic;
            mosi :out std_logic;
            miso :in std_logic;
            cs :out std_logic
    
      ) ;
    end component;

    component spi_slave is
        Port (
                clk : in STD_LOGIC;
                reset : in STD_LOGIC;
                spi_clk : in STD_LOGIC;
                spi_mosi : in STD_LOGIC;
                spi_miso : out STD_LOGIC;
                spi_cs : in STD_LOGIC;
                rx_data : out STD_LOGIC_VECTOR (511 downto 0);
                rx_valid : out STD_LOGIC;                       -- Data received and ready to be read from rx_data
                tx_data : in STD_LOGIC_VECTOR (511 downto 0);
                tx_load : in STD_LOGIC;
                tx_ready : out STD_LOGIC
              );
    end component;
    
    
    component fifo is
        generic (
        width : natural := 8;
        depth : integer := 64);
    port (
        reset : in std_logic;
        clock      : in std_logic;

        -- FIFO Write Interface
        write_en   : in  std_logic;
        write_data : in  std_logic_vector(width-1 downto 0);
        o_full    : out std_logic;

        -- FIFO Read Interface
        read_en   : in  std_logic;
        read_data : out std_logic_vector(width-1 downto 0);
        o_empty   : out std_logic);
    end component;
    component encoder is
        port (    
            clock : in std_logic;
            clr : in std_logic;
            increment_block_count : in std_logic;

            channel : in integer range 0 to 2;
            dct_coeff_zz : in dct_coeff_zz_t;
            encoding_done : out std_logic;
            length_o : out integer range 0 to 512;
            encoded_block : out std_logic_vector(511 downto 0)
        ) ;
    end component;   
    component ac_huff_table is
        port (
          clock: in std_logic;
          clr: in std_logic;
          channel : in integer range 0 to 2;
          run_length: in integer range 0 to 63;
          huff_value: in huff_value_t;
          load : in std_logic;
          huff_code: out huff_code_t;
          code_ready: out std_logic
          
        ) ;
      end component;
    

    component pixel_indexer is
        port (
        data : in std_logic_vector(511 downto 0);
        index : in integer range 0 to 63;
        pixel : out sfixed(7 downto 0)
        ) ;
    end component;
    
  
end package;

package body jpeg_pkg is 
function shiftl (arg : std_logic_vector;count : integer) return std_logic_vector is
    variable fixed,fixed_shifted : ufixed(arg'length - 1 downto 0);
    variable ret : std_logic_vector(arg'length - 1 downto 0);
begin 
    fixed := to_ufixed(arg,arg'length-1,0);
    fixed_shifted := fixed sll count;
    ret := std_logic_vector(fixed_shifted);
    return ret;
end function; 
function shiftr (arg : std_logic_vector;count : integer) return std_logic_vector is
    variable fixed,fixed_shifted : ufixed(arg'length - 1 downto 0);
    variable ret : std_logic_vector(arg'length - 1 downto 0);
begin 
    fixed := to_ufixed(arg,arg'length-1,0);
    fixed_shifted := fixed srl count;
    ret := std_logic_vector(fixed_shifted);
    return ret;
end function; 
     
function "+" (y_dc_code : y_dc_code_t;huff_value : huff_value_t) return huff_code_t is
        variable huff_code : huff_code_t;
        begin
        huff_code.code_length := y_dc_code.code_length + huff_value.code_length;
        case y_dc_code.code_length is 
        when 1 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26) := y_dc_code.code(0);
                huff_code.code(25 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 25) := y_dc_code.code(0)&huff_value.code(0);
                huff_code.code(24 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 24) := y_dc_code.code(0)&huff_value.code(1 downto 0);
                huff_code.code(23 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 23) := y_dc_code.code(0)&huff_value.code(2 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 22) := y_dc_code.code(0)&huff_value.code(3 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 21) := y_dc_code.code(0)&huff_value.code(4 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 20) := y_dc_code.code(0)&huff_value.code(5 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 19) := y_dc_code.code(0)&huff_value.code(6 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 18) := y_dc_code.code(0)&huff_value.code(7 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 17) := y_dc_code.code(0)&huff_value.code(8 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 16) := y_dc_code.code(0)&huff_value.code(9 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 15) := y_dc_code.code(0)&huff_value.code(10 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
        end case;
    when 2 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 25) := y_dc_code.code(1 downto 0);
                huff_code.code(24 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 24) := y_dc_code.code(1 downto 0)&huff_value.code(0);
                huff_code.code(23 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 23) := y_dc_code.code(1 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 22) := y_dc_code.code(1 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 21) := y_dc_code.code(1 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 20) := y_dc_code.code(1 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 19) := y_dc_code.code(1 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 18) := y_dc_code.code(1 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 17) := y_dc_code.code(1 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 16) := y_dc_code.code(1 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 15) := y_dc_code.code(1 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 14) := y_dc_code.code(1 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
        end case;
    when 3 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 24) := y_dc_code.code(2 downto 0);
                huff_code.code(23 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 23) := y_dc_code.code(2 downto 0)&huff_value.code(0);
                huff_code.code(22 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 22) := y_dc_code.code(2 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 21) := y_dc_code.code(2 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 20) := y_dc_code.code(2 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 19) := y_dc_code.code(2 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 18) := y_dc_code.code(2 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 17) := y_dc_code.code(2 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 16) := y_dc_code.code(2 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 15) := y_dc_code.code(2 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 14) := y_dc_code.code(2 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 13) := y_dc_code.code(2 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
        end case;
    when 4 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 23) := y_dc_code.code(3 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 22) := y_dc_code.code(3 downto 0)&huff_value.code(0);
                huff_code.code(21 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 21) := y_dc_code.code(3 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 20) := y_dc_code.code(3 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 19) := y_dc_code.code(3 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 18) := y_dc_code.code(3 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 17) := y_dc_code.code(3 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 16) := y_dc_code.code(3 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 15) := y_dc_code.code(3 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 14) := y_dc_code.code(3 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 13) := y_dc_code.code(3 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 12) := y_dc_code.code(3 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
        end case;
    when 5 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 22) := y_dc_code.code(4 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 21) := y_dc_code.code(4 downto 0)&huff_value.code(0);
                huff_code.code(20 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 20) := y_dc_code.code(4 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 19) := y_dc_code.code(4 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 18) := y_dc_code.code(4 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 17) := y_dc_code.code(4 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 16) := y_dc_code.code(4 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 15) := y_dc_code.code(4 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 14) := y_dc_code.code(4 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 13) := y_dc_code.code(4 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 12) := y_dc_code.code(4 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 11) := y_dc_code.code(4 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
        end case;
    when 6 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 21) := y_dc_code.code(5 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 20) := y_dc_code.code(5 downto 0)&huff_value.code(0);
                huff_code.code(19 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 19) := y_dc_code.code(5 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 18) := y_dc_code.code(5 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 17) := y_dc_code.code(5 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 16) := y_dc_code.code(5 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 15) := y_dc_code.code(5 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 14) := y_dc_code.code(5 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 13) := y_dc_code.code(5 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 12) := y_dc_code.code(5 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 11) := y_dc_code.code(5 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 10) := y_dc_code.code(5 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
        end case;
    when 7 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 20) := y_dc_code.code(6 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 19) := y_dc_code.code(6 downto 0)&huff_value.code(0);
                huff_code.code(18 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 18) := y_dc_code.code(6 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 17) := y_dc_code.code(6 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 16) := y_dc_code.code(6 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 15) := y_dc_code.code(6 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 14) := y_dc_code.code(6 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 13) := y_dc_code.code(6 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 12) := y_dc_code.code(6 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 11) := y_dc_code.code(6 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 10) := y_dc_code.code(6 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 9) := y_dc_code.code(6 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
        end case;
    when 8 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 19) := y_dc_code.code(7 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 18) := y_dc_code.code(7 downto 0)&huff_value.code(0);
                huff_code.code(17 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 17) := y_dc_code.code(7 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 16) := y_dc_code.code(7 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 15) := y_dc_code.code(7 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 14) := y_dc_code.code(7 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 13) := y_dc_code.code(7 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 12) := y_dc_code.code(7 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 11) := y_dc_code.code(7 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 10) := y_dc_code.code(7 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 9) := y_dc_code.code(7 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 8) := y_dc_code.code(7 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
        end case;
    when 9 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 18) := y_dc_code.code(8 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 17) := y_dc_code.code(8 downto 0)&huff_value.code(0);
                huff_code.code(16 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 16) := y_dc_code.code(8 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 15) := y_dc_code.code(8 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 14) := y_dc_code.code(8 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 13) := y_dc_code.code(8 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 12) := y_dc_code.code(8 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 11) := y_dc_code.code(8 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 10) := y_dc_code.code(8 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 9) := y_dc_code.code(8 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 8) := y_dc_code.code(8 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 7) := y_dc_code.code(8 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
        end case;
    end case;
    return huff_code;
    end function;



function "+" (c_dc_code : c_dc_code_t;huff_value : huff_value_t) return huff_code_t is
    variable huff_code : huff_code_t;
    begin
    huff_code.code_length := c_dc_code.code_length + huff_value.code_length;
    case c_dc_code.code_length is 


    when 1 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26) := c_dc_code.code(0);
                huff_code.code(25 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 25) := c_dc_code.code(0)&huff_value.code(0);
                huff_code.code(24 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 24) := c_dc_code.code(0)&huff_value.code(1 downto 0);
                huff_code.code(23 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 23) := c_dc_code.code(0)&huff_value.code(2 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 22) := c_dc_code.code(0)&huff_value.code(3 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 21) := c_dc_code.code(0)&huff_value.code(4 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 20) := c_dc_code.code(0)&huff_value.code(5 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 19) := c_dc_code.code(0)&huff_value.code(6 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 18) := c_dc_code.code(0)&huff_value.code(7 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 17) := c_dc_code.code(0)&huff_value.code(8 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 16) := c_dc_code.code(0)&huff_value.code(9 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 15) := c_dc_code.code(0)&huff_value.code(10 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
        end case;
    when 2 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 25) := c_dc_code.code(1 downto 0);
                huff_code.code(24 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 24) := c_dc_code.code(1 downto 0)&huff_value.code(0);
                huff_code.code(23 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 23) := c_dc_code.code(1 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 22) := c_dc_code.code(1 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 21) := c_dc_code.code(1 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 20) := c_dc_code.code(1 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 19) := c_dc_code.code(1 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 18) := c_dc_code.code(1 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 17) := c_dc_code.code(1 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 16) := c_dc_code.code(1 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 15) := c_dc_code.code(1 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 14) := c_dc_code.code(1 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
        end case;
    when 3 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 24) := c_dc_code.code(2 downto 0);
                huff_code.code(23 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 23) := c_dc_code.code(2 downto 0)&huff_value.code(0);
                huff_code.code(22 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 22) := c_dc_code.code(2 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 21) := c_dc_code.code(2 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 20) := c_dc_code.code(2 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 19) := c_dc_code.code(2 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 18) := c_dc_code.code(2 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 17) := c_dc_code.code(2 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 16) := c_dc_code.code(2 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 15) := c_dc_code.code(2 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 14) := c_dc_code.code(2 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 13) := c_dc_code.code(2 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
        end case;
    when 4 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 23) := c_dc_code.code(3 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 22) := c_dc_code.code(3 downto 0)&huff_value.code(0);
                huff_code.code(21 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 21) := c_dc_code.code(3 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 20) := c_dc_code.code(3 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 19) := c_dc_code.code(3 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 18) := c_dc_code.code(3 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 17) := c_dc_code.code(3 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 16) := c_dc_code.code(3 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 15) := c_dc_code.code(3 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 14) := c_dc_code.code(3 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 13) := c_dc_code.code(3 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 12) := c_dc_code.code(3 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
        end case;
    when 5 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 22) := c_dc_code.code(4 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 21) := c_dc_code.code(4 downto 0)&huff_value.code(0);
                huff_code.code(20 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 20) := c_dc_code.code(4 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 19) := c_dc_code.code(4 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 18) := c_dc_code.code(4 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 17) := c_dc_code.code(4 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 16) := c_dc_code.code(4 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 15) := c_dc_code.code(4 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 14) := c_dc_code.code(4 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 13) := c_dc_code.code(4 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 12) := c_dc_code.code(4 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 11) := c_dc_code.code(4 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
        end case;
    when 6 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 21) := c_dc_code.code(5 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 20) := c_dc_code.code(5 downto 0)&huff_value.code(0);
                huff_code.code(19 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 19) := c_dc_code.code(5 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 18) := c_dc_code.code(5 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 17) := c_dc_code.code(5 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 16) := c_dc_code.code(5 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 15) := c_dc_code.code(5 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 14) := c_dc_code.code(5 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 13) := c_dc_code.code(5 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 12) := c_dc_code.code(5 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 11) := c_dc_code.code(5 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 10) := c_dc_code.code(5 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
        end case;
    when 7 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 20) := c_dc_code.code(6 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 19) := c_dc_code.code(6 downto 0)&huff_value.code(0);
                huff_code.code(18 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 18) := c_dc_code.code(6 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 17) := c_dc_code.code(6 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 16) := c_dc_code.code(6 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 15) := c_dc_code.code(6 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 14) := c_dc_code.code(6 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 13) := c_dc_code.code(6 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 12) := c_dc_code.code(6 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 11) := c_dc_code.code(6 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 10) := c_dc_code.code(6 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 9) := c_dc_code.code(6 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
        end case;
    when 8 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 19) := c_dc_code.code(7 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 18) := c_dc_code.code(7 downto 0)&huff_value.code(0);
                huff_code.code(17 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 17) := c_dc_code.code(7 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 16) := c_dc_code.code(7 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 15) := c_dc_code.code(7 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 14) := c_dc_code.code(7 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 13) := c_dc_code.code(7 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 12) := c_dc_code.code(7 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 11) := c_dc_code.code(7 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 10) := c_dc_code.code(7 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 9) := c_dc_code.code(7 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 8) := c_dc_code.code(7 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
        end case;
    when 9 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 18) := c_dc_code.code(8 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 17) := c_dc_code.code(8 downto 0)&huff_value.code(0);
                huff_code.code(16 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 16) := c_dc_code.code(8 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 15) := c_dc_code.code(8 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 14) := c_dc_code.code(8 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 13) := c_dc_code.code(8 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 12) := c_dc_code.code(8 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 11) := c_dc_code.code(8 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 10) := c_dc_code.code(8 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 9) := c_dc_code.code(8 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 8) := c_dc_code.code(8 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 7) := c_dc_code.code(8 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
        end case;
    when 10 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 17) := c_dc_code.code(9 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 16) := c_dc_code.code(9 downto 0)&huff_value.code(0);
                huff_code.code(15 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 15) := c_dc_code.code(9 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 14) := c_dc_code.code(9 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 13) := c_dc_code.code(9 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 12) := c_dc_code.code(9 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 11) := c_dc_code.code(9 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 10) := c_dc_code.code(9 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 9) := c_dc_code.code(9 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 8) := c_dc_code.code(9 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 7) := c_dc_code.code(9 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 6) := c_dc_code.code(9 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
        end case;
    when 11 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 16) := c_dc_code.code(10 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 15) := c_dc_code.code(10 downto 0)&huff_value.code(0);
                huff_code.code(14 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 14) := c_dc_code.code(10 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 13) := c_dc_code.code(10 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 12) := c_dc_code.code(10 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 11) := c_dc_code.code(10 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 10) := c_dc_code.code(10 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 9) := c_dc_code.code(10 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 8) := c_dc_code.code(10 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 7) := c_dc_code.code(10 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 6) := c_dc_code.code(10 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 5) := c_dc_code.code(10 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
        end case;
    end case;
    return huff_code;
    end function;


function "+" (ac_code : ac_code_t;huff_value : huff_value_t) return huff_code_t is



        variable huff_code : huff_code_t;
        begin
        huff_code.code_length := ac_code.code_length + huff_value.code_length;
        case ac_code.code_length is 
        when 1 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26) := ac_code.code(0);
                huff_code.code(25 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 25) := ac_code.code(0)&huff_value.code(0);
                huff_code.code(24 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 24) := ac_code.code(0)&huff_value.code(1 downto 0);
                huff_code.code(23 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 23) := ac_code.code(0)&huff_value.code(2 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 22) := ac_code.code(0)&huff_value.code(3 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 21) := ac_code.code(0)&huff_value.code(4 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 20) := ac_code.code(0)&huff_value.code(5 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 19) := ac_code.code(0)&huff_value.code(6 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 18) := ac_code.code(0)&huff_value.code(7 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 17) := ac_code.code(0)&huff_value.code(8 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 16) := ac_code.code(0)&huff_value.code(9 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 15) := ac_code.code(0)&huff_value.code(10 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
        end case;
    when 2 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 25) := ac_code.code(1 downto 0);
                huff_code.code(24 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 24) := ac_code.code(1 downto 0)&huff_value.code(0);
                huff_code.code(23 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 23) := ac_code.code(1 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 22) := ac_code.code(1 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 21) := ac_code.code(1 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 20) := ac_code.code(1 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 19) := ac_code.code(1 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 18) := ac_code.code(1 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 17) := ac_code.code(1 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 16) := ac_code.code(1 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 15) := ac_code.code(1 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 14) := ac_code.code(1 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
        end case;
    when 3 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 24) := ac_code.code(2 downto 0);
                huff_code.code(23 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 23) := ac_code.code(2 downto 0)&huff_value.code(0);
                huff_code.code(22 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 22) := ac_code.code(2 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 21) := ac_code.code(2 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 20) := ac_code.code(2 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 19) := ac_code.code(2 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 18) := ac_code.code(2 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 17) := ac_code.code(2 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 16) := ac_code.code(2 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 15) := ac_code.code(2 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 14) := ac_code.code(2 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 13) := ac_code.code(2 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
        end case;
    when 4 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 23) := ac_code.code(3 downto 0);
                huff_code.code(22 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 22) := ac_code.code(3 downto 0)&huff_value.code(0);
                huff_code.code(21 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 21) := ac_code.code(3 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 20) := ac_code.code(3 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 19) := ac_code.code(3 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 18) := ac_code.code(3 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 17) := ac_code.code(3 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 16) := ac_code.code(3 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 15) := ac_code.code(3 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 14) := ac_code.code(3 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 13) := ac_code.code(3 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 12) := ac_code.code(3 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
        end case;
    when 5 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 22) := ac_code.code(4 downto 0);
                huff_code.code(21 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 21) := ac_code.code(4 downto 0)&huff_value.code(0);
                huff_code.code(20 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 20) := ac_code.code(4 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 19) := ac_code.code(4 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 18) := ac_code.code(4 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 17) := ac_code.code(4 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 16) := ac_code.code(4 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 15) := ac_code.code(4 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 14) := ac_code.code(4 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 13) := ac_code.code(4 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 12) := ac_code.code(4 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 11) := ac_code.code(4 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
        end case;
    when 6 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 21) := ac_code.code(5 downto 0);
                huff_code.code(20 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 20) := ac_code.code(5 downto 0)&huff_value.code(0);
                huff_code.code(19 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 19) := ac_code.code(5 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 18) := ac_code.code(5 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 17) := ac_code.code(5 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 16) := ac_code.code(5 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 15) := ac_code.code(5 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 14) := ac_code.code(5 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 13) := ac_code.code(5 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 12) := ac_code.code(5 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 11) := ac_code.code(5 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 10) := ac_code.code(5 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
        end case;
    when 7 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 20) := ac_code.code(6 downto 0);
                huff_code.code(19 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 19) := ac_code.code(6 downto 0)&huff_value.code(0);
                huff_code.code(18 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 18) := ac_code.code(6 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 17) := ac_code.code(6 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 16) := ac_code.code(6 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 15) := ac_code.code(6 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 14) := ac_code.code(6 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 13) := ac_code.code(6 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 12) := ac_code.code(6 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 11) := ac_code.code(6 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 10) := ac_code.code(6 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 9) := ac_code.code(6 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
        end case;
    when 8 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 19) := ac_code.code(7 downto 0);
                huff_code.code(18 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 18) := ac_code.code(7 downto 0)&huff_value.code(0);
                huff_code.code(17 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 17) := ac_code.code(7 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 16) := ac_code.code(7 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 15) := ac_code.code(7 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 14) := ac_code.code(7 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 13) := ac_code.code(7 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 12) := ac_code.code(7 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 11) := ac_code.code(7 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 10) := ac_code.code(7 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 9) := ac_code.code(7 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 8) := ac_code.code(7 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
        end case;
    when 9 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 18) := ac_code.code(8 downto 0);
                huff_code.code(17 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 17) := ac_code.code(8 downto 0)&huff_value.code(0);
                huff_code.code(16 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 16) := ac_code.code(8 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 15) := ac_code.code(8 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 14) := ac_code.code(8 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 13) := ac_code.code(8 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 12) := ac_code.code(8 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 11) := ac_code.code(8 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 10) := ac_code.code(8 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 9) := ac_code.code(8 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 8) := ac_code.code(8 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 7) := ac_code.code(8 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
        end case;
    when 10 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 17) := ac_code.code(9 downto 0);
                huff_code.code(16 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 16) := ac_code.code(9 downto 0)&huff_value.code(0);
                huff_code.code(15 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 15) := ac_code.code(9 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 14) := ac_code.code(9 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 13) := ac_code.code(9 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 12) := ac_code.code(9 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 11) := ac_code.code(9 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 10) := ac_code.code(9 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 9) := ac_code.code(9 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 8) := ac_code.code(9 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 7) := ac_code.code(9 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 6) := ac_code.code(9 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
        end case;
    when 11 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 16) := ac_code.code(10 downto 0);
                huff_code.code(15 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 15) := ac_code.code(10 downto 0)&huff_value.code(0);
                huff_code.code(14 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 14) := ac_code.code(10 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 13) := ac_code.code(10 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 12) := ac_code.code(10 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 11) := ac_code.code(10 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 10) := ac_code.code(10 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 9) := ac_code.code(10 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 8) := ac_code.code(10 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 7) := ac_code.code(10 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 6) := ac_code.code(10 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 5) := ac_code.code(10 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
        end case;
    when 12 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 15) := ac_code.code(11 downto 0);
                huff_code.code(14 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 14) := ac_code.code(11 downto 0)&huff_value.code(0);
                huff_code.code(13 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 13) := ac_code.code(11 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 12) := ac_code.code(11 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 11) := ac_code.code(11 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 10) := ac_code.code(11 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 9) := ac_code.code(11 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 8) := ac_code.code(11 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 7) := ac_code.code(11 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 6) := ac_code.code(11 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 5) := ac_code.code(11 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 4) := ac_code.code(11 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(3 downto 0) := (others => '0');
        end case;
    when 13 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 14) := ac_code.code(12 downto 0);
                huff_code.code(13 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 13) := ac_code.code(12 downto 0)&huff_value.code(0);
                huff_code.code(12 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 12) := ac_code.code(12 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 11) := ac_code.code(12 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 10) := ac_code.code(12 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 9) := ac_code.code(12 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 8) := ac_code.code(12 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 7) := ac_code.code(12 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 6) := ac_code.code(12 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 5) := ac_code.code(12 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 4) := ac_code.code(12 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(3 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 3) := ac_code.code(12 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(2 downto 0) := (others => '0');
        end case;
    when 14 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 13) := ac_code.code(13 downto 0);
                huff_code.code(12 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 12) := ac_code.code(13 downto 0)&huff_value.code(0);
                huff_code.code(11 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 11) := ac_code.code(13 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 10) := ac_code.code(13 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 9) := ac_code.code(13 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 8) := ac_code.code(13 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 7) := ac_code.code(13 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 6) := ac_code.code(13 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 5) := ac_code.code(13 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 4) := ac_code.code(13 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(3 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 3) := ac_code.code(13 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(2 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 2) := ac_code.code(13 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(1 downto 0) := (others => '0');
        end case;
    when 15 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 12) := ac_code.code(14 downto 0);
                huff_code.code(11 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 11) := ac_code.code(14 downto 0)&huff_value.code(0);
                huff_code.code(10 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 10) := ac_code.code(14 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(9 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 9) := ac_code.code(14 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 8) := ac_code.code(14 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 7) := ac_code.code(14 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 6) := ac_code.code(14 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 5) := ac_code.code(14 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 4) := ac_code.code(14 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(3 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 3) := ac_code.code(14 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(2 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 2) := ac_code.code(14 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(1 downto 0) := (others => '0');
            when 11 =>
                huff_code.code(26 downto 1) := ac_code.code(14 downto 0)&huff_value.code(10 downto 0);
                huff_code.code(0) := '0';
        end case;
    when 16 =>
        case huff_value.code_length is 
            when 0 =>
                huff_code.code(26 downto 11) := ac_code.code(15 downto 0);
                huff_code.code(10 downto 0) := (others => '0');
            when 1 =>
                huff_code.code(26 downto 10) := ac_code.code(15 downto 0)&huff_value.code(0);
                huff_code.code(9 downto 0) := (others => '0');
            when 2 =>
                huff_code.code(26 downto 9) := ac_code.code(15 downto 0)&huff_value.code(1 downto 0);
                huff_code.code(8 downto 0) := (others => '0');
            when 3 =>
                huff_code.code(26 downto 8) := ac_code.code(15 downto 0)&huff_value.code(2 downto 0);
                huff_code.code(7 downto 0) := (others => '0');
            when 4 =>
                huff_code.code(26 downto 7) := ac_code.code(15 downto 0)&huff_value.code(3 downto 0);
                huff_code.code(6 downto 0) := (others => '0');
            when 5 =>
                huff_code.code(26 downto 6) := ac_code.code(15 downto 0)&huff_value.code(4 downto 0);
                huff_code.code(5 downto 0) := (others => '0');
            when 6 =>
                huff_code.code(26 downto 5) := ac_code.code(15 downto 0)&huff_value.code(5 downto 0);
                huff_code.code(4 downto 0) := (others => '0');
            when 7 =>
                huff_code.code(26 downto 4) := ac_code.code(15 downto 0)&huff_value.code(6 downto 0);
                huff_code.code(3 downto 0) := (others => '0');
            when 8 =>
                huff_code.code(26 downto 3) := ac_code.code(15 downto 0)&huff_value.code(7 downto 0);
                huff_code.code(2 downto 0) := (others => '0');
            when 9 =>
                huff_code.code(26 downto 2) := ac_code.code(15 downto 0)&huff_value.code(8 downto 0);
                huff_code.code(1 downto 0) := (others => '0');
            when 10 =>
                huff_code.code(26 downto 1) := ac_code.code(15 downto 0)&huff_value.code(9 downto 0);
                huff_code.code(0) := '0';
            when 11 =>
                huff_code.code(26 downto 0) := ac_code.code(15 downto 0)&huff_value.code(10 downto 0);
                
        end case;
    end case;
    return huff_code;
    end function;
-------------------

end jpeg_pkg;
        