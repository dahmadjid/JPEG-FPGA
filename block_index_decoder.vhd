library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.jpeg_pkg.all;
-- Tested on FPGA, channel offset has to be double checked
entity block_index_decoder is
  port (
    y_x_index: in unsigned(5 downto 0);
    row_block_index , col_block_index : in integer range 0 to 63;
    width,height : in integer range 0 to 256;
    channel : in integer range 0 to 2;
    address : out integer range 0 to 262144

  ) ;
end block_index_decoder;

architecture arch of block_index_decoder is
    signal temp1,channel_offset : integer range 0 to 256*256*2;
    signal temp2 : integer range 0 to 512; 
    signal address_mat : address_mat_t;
    signal y,x : integer range 0 to 7;
begin

y <= to_integer(y_x_index(5 downto 3));
x <= to_integer(y_x_index(2 downto 0));


channel_offset <= height*width*channel;
temp1 <= width*row_block_index*8;
temp2 <= col_block_index*8;
address_mat <= (
    (temp1 + temp2 + channel_offset,temp1 + temp2 + 1 + channel_offset,temp1 + temp2 + 2 + channel_offset,temp1 + temp2 + 3 + channel_offset,temp1 + temp2 + 4 + channel_offset,temp1 + temp2 + 5 + channel_offset,temp1 + temp2 + 6 + channel_offset,temp1 + temp2 + 7 + channel_offset),
    (temp1 + 1*width + temp2 + channel_offset,temp1 + 1*width + temp2 + 1 + channel_offset,temp1 + 1*width + temp2 + 2 + channel_offset,temp1 + 1*width + temp2 + 3 + channel_offset,temp1 + 1*width + temp2 + 4 + channel_offset,temp1 + 1*width + temp2 + 5 + channel_offset,temp1 + 1*width + temp2 + 6 + channel_offset,temp1 + 1*width + temp2 + 7 + channel_offset),
    (temp1 + 2*width + temp2 + channel_offset,temp1 + 2*width + temp2 + 1 + channel_offset,temp1 + 2*width + temp2 + 2 + channel_offset,temp1 + 2*width + temp2 + 3 + channel_offset,temp1 + 2*width + temp2 + 4 + channel_offset,temp1 + 2*width + temp2 + 5 + channel_offset,temp1 + 2*width + temp2 + 6 + channel_offset,temp1 + 2*width + temp2 + 7 + channel_offset),
    (temp1 + 3*width + temp2 + channel_offset,temp1 + 3*width + temp2 + 1 + channel_offset,temp1 + 3*width + temp2 + 2 + channel_offset,temp1 + 3*width + temp2 + 3 + channel_offset,temp1 + 3*width + temp2 + 4 + channel_offset,temp1 + 3*width + temp2 + 5 + channel_offset,temp1 + 3*width + temp2 + 6 + channel_offset,temp1 + 3*width + temp2 + 7 + channel_offset),
    (temp1 + 4*width + temp2 + channel_offset,temp1 + 4*width + temp2 + 1 + channel_offset,temp1 + 4*width + temp2 + 2 + channel_offset,temp1 + 4*width + temp2 + 3 + channel_offset,temp1 + 4*width + temp2 + 4 + channel_offset,temp1 + 4*width + temp2 + 5 + channel_offset,temp1 + 4*width + temp2 + 6 + channel_offset,temp1 + 4*width + temp2 + 7 + channel_offset),
    (temp1 + 5*width + temp2 + channel_offset,temp1 + 5*width + temp2 + 1 + channel_offset,temp1 + 5*width + temp2 + 2 + channel_offset,temp1 + 5*width + temp2 + 3 + channel_offset,temp1 + 5*width + temp2 + 4 + channel_offset,temp1 + 5*width + temp2 + 5 + channel_offset,temp1 + 5*width + temp2 + 6 + channel_offset,temp1 + 5*width + temp2 + 7 + channel_offset),
    (temp1 + 6*width + temp2 + channel_offset,temp1 + 6*width + temp2 + 1 + channel_offset,temp1 + 6*width + temp2 + 2 + channel_offset,temp1 + 6*width + temp2 + 3 + channel_offset,temp1 + 6*width + temp2 + 4 + channel_offset,temp1 + 6*width + temp2 + 5 + channel_offset,temp1 + 6*width + temp2 + 6 + channel_offset,temp1 + 6*width + temp2 + 7 + channel_offset),
    (temp1 + 7*width + temp2 + channel_offset,temp1 + 7*width + temp2 + 1 + channel_offset,temp1 + 7*width + temp2 + 2 + channel_offset,temp1 + 7*width + temp2 + 3 + channel_offset,temp1 + 7*width + temp2 + 4 + channel_offset,temp1 + 7*width + temp2 + 5 + channel_offset,temp1 + 7*width + temp2 + 6 + channel_offset,temp1 + 7*width + temp2 + 7 + channel_offset));
address <= address_mat(y)(x);

end arch ; -- arch