library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;



package jpeg_pkg is 
    
    type image_row_t is array (0 to 7) of sfixed(7 downto 0);
    type image_block_t is array (0 to 7) of image_row_t; --8 by 8 block of image
    type qz_row_t is array (0 to 7) of sfixed(1 downto -16);
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

    type y_dc_code_table_t is array(0 to 11) of y_dc_code_t;
    type c_dc_code_table_t is array(0 to 11) of c_dc_code_t;
    
    type ac_code_row_t is array(1 to 10) of ac_code_t;
    type ac_code_table_t is array(0 to 15) of ac_code_row_t; 


    constant luminance_qz: image_block_t := (
    ("00010000","00001011","00001010","00010000","00011000","00101000","00110011","00111101"),
    ("00001100","00001100","00001110","00010011","00011010","00111010","00111100","00110111"),
    ("00001110","00001101","00010000","00011000","00101000","00111001","01000101","00111000"),
    ("00001110","00010001","00010110","00011101","00110011","01010111","01010000","00111110"),
    ("00010010","00010110","00100101","00111000","01000100","01101101","01100111","01001101"),
    ("00011000","00100011","00110111","01000000","01010001","01101000","01110001","01011100"),
    ("00110001","01000000","01001110","01010111","01100111","01111001","01111000","01100101"),
    ("01001000","01011100","01011111","01100010","01110000","01100100","01100111","01100011"));
    
    constant chrominance_qz: image_block_t := (
    ("00010001","00010010","00011000","00101111","01100011","01100011","01100011","01100011"),
    ("00010010","00010101","00011010","01000010","01100011","01100011","01100011","01100011"),
    ("00011000","00011010","00111000","01100011","01100011","01100011","01100011","01100011"),
    ("00101111","01000010","01100011","01100011","01100011","01100011","01100011","01100011"),
    ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"),
    ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"),
    ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"),
    ("01100011","01100011","01100011","01100011","01100011","01100011","01100011","01100011"));
    
    constant luminance_qz_fixed: qz_table_t := (
    ("000001000000000000","000001011101000101","000001100110011001","000001000000000000","000000101010101010","000000011001100110","000000010100000101","000000010000110010"),
    ("000001010101010101","000001010101010101","000001001001001001","000000110101111001","000000100111011000","000000010001101001","000000010001000100","000000010010100111"),
    ("000001001001001001","000001001110110001","000001000000000000","000000101010101010","000000011001100110","000000010001111101","000000001110110101","000000010010010010"),
    ("000001001001001001","000000111100001111","000000101110100010","000000100011010011","000000010100000101","000000001011110001","000000001100110011","000000010000100001"),
    ("000000111000111000","000000101110100010","000000011011101011","000000010010010010","000000001111000011","000000001001011001","000000001001111100","000000001101010011"),
    ("000000101010101010","000000011101010000","000000010010100111","000000010000000000","000000001100101001","000000001001110110","000000001001000011","000000001011001000"),
    ("000000010100111001","000000010000000000","000000001101001000","000000001011110001","000000001001111100","000000001000011101","000000001000100010","000000001010001000"),
    ("000000001110001110","000000001011001000","000000001010110001","000000001010011100","000000001001001001","000000001010001111","000000001001111100","000000001010010101"));
    constant chrominance_qz_fixed: qz_table_t := (
    ("000000111100001111","000000111000111000","000000101010101010","000000010101110010","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000111000111000","000000110000110000","000000100111011000","000000001111100000","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000101010101010","000000100111011000","000000010010010010","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000010101110010","000000001111100000","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101"),
    ("000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101","000000001010010101"));
    
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
    
    



    component cos is   
        port 
        (
        u,x : in unsigned(2 downto 0);     -- or v,y
        c : out sfixed(1 downto -16)       --c is cos in signed fixed point
        );
    end component;
    component constant_comp is  
        port (
        u,v : in unsigned(2 downto 0);
        const : out sfixed(1 downto -16)
        ) ;
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
        clock,dct_start,dct_finished : in std_logic;
        dct_working : out std_logic;
        y_x_index : in unsigned(5 downto 0);
        img_pixel : in sfixed(7 downto 0);
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
            huff_value : out sfixed(10 downto 0);
            length : out unsigned(3 downto 0) --number between 0 and 11
        ) ;
    end component;
    component mini_length_block is
        port (
            dc_diff : in sfixed(11 downto 0);
            dct_coeff_zz : in dct_coeff_zz_t;
            huff_value_zz : out dct_coeff_zz_t;
            length_zz : out length_zz_t
        ) ;
      end component;
    component y_quantizer is
    port (
      dct_coeff_block : in dct_coeff_block_t;
      dct_coeff_qz : out dct_coeff_block_t
    ) ;
    end component;

    component c_quantizer is
    port (
      dct_coeff_block : in dct_coeff_block_t;
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
end package;