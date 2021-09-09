library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.jpeg_pkg.all;
-- Tested on FPGA, channel offset has to be double checked
entity block_index_decoder is
  port (
    row_block_index , col_block_index : in integer range 0 to 63;
    width,height : in integer range 0 to 256;
    channel : in integer range 0 to 2;
    address_mat : out address_mat_t

  ) ;
end block_index_decoder;

architecture arch of block_index_decoder is
    signal temp1,channel_offset : integer range 0 to 256*256*2;
    signal temp2 : integer range 0 to 512; 
begin
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
    
end arch ; -- arch