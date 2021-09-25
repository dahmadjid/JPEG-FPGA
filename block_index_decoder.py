block_address_mat = [[f"temp1 + {row_offset}*width + temp2 + {col_offset} + channel_offset" for col_offset in range(8) ] for row_offset in range(8)]

table = ""
a = 0
for row in block_address_mat:
    for val in row:
        if a == 0:
            table += '('
        table += val+','
        if a == 7:
            table=table[:-1]+"),\n"
            a = 0
        else:
            a += 1
with open("block_index_decoder.txt","w") as f:
    f.write(table)
width = 256
height = 192

channel = 2
row_block_index = 0
col_block_index = 0
channel_offset = height*width*channel
temp1 = width*row_block_index*8
temp2 = col_block_index*8
address_mat = (
    (temp1 + temp2 + channel_offset,temp1 + temp2 + 1 + channel_offset,temp1 + temp2 + 2 + channel_offset,temp1 + temp2 + 3 + channel_offset,temp1 + temp2 + 4 + channel_offset,temp1 + temp2 + 5 + channel_offset,temp1 + temp2 + 6 + channel_offset,temp1 + temp2 + 7 + channel_offset),
    (temp1 + 1*width + temp2 + channel_offset,temp1 + 1*width + temp2 + 1 + channel_offset,temp1 + 1*width + temp2 + 2 + channel_offset,temp1 + 1*width + temp2 + 3 + channel_offset,temp1 + 1*width + temp2 + 4 + channel_offset,temp1 + 1*width + temp2 + 5 + channel_offset,temp1 + 1*width + temp2 + 6 + channel_offset,temp1 + 1*width + temp2 + 7 + channel_offset),
    (temp1 + 2*width + temp2 + channel_offset,temp1 + 2*width + temp2 + 1 + channel_offset,temp1 + 2*width + temp2 + 2 + channel_offset,temp1 + 2*width + temp2 + 3 + channel_offset,temp1 + 2*width + temp2 + 4 + channel_offset,temp1 + 2*width + temp2 + 5 + channel_offset,temp1 + 2*width + temp2 + 6 + channel_offset,temp1 + 2*width + temp2 + 7 + channel_offset),
    (temp1 + 3*width + temp2 + channel_offset,temp1 + 3*width + temp2 + 1 + channel_offset,temp1 + 3*width + temp2 + 2 + channel_offset,temp1 + 3*width + temp2 + 3 + channel_offset,temp1 + 3*width + temp2 + 4 + channel_offset,temp1 + 3*width + temp2 + 5 + channel_offset,temp1 + 3*width + temp2 + 6 + channel_offset,temp1 + 3*width + temp2 + 7 + channel_offset),
    (temp1 + 4*width + temp2 + channel_offset,temp1 + 4*width + temp2 + 1 + channel_offset,temp1 + 4*width + temp2 + 2 + channel_offset,temp1 + 4*width + temp2 + 3 + channel_offset,temp1 + 4*width + temp2 + 4 + channel_offset,temp1 + 4*width + temp2 + 5 + channel_offset,temp1 + 4*width + temp2 + 6 + channel_offset,temp1 + 4*width + temp2 + 7 + channel_offset),
    (temp1 + 5*width + temp2 + channel_offset,temp1 + 5*width + temp2 + 1 + channel_offset,temp1 + 5*width + temp2 + 2 + channel_offset,temp1 + 5*width + temp2 + 3 + channel_offset,temp1 + 5*width + temp2 + 4 + channel_offset,temp1 + 5*width + temp2 + 5 + channel_offset,temp1 + 5*width + temp2 + 6 + channel_offset,temp1 + 5*width + temp2 + 7 + channel_offset),
    (temp1 + 6*width + temp2 + channel_offset,temp1 + 6*width + temp2 + 1 + channel_offset,temp1 + 6*width + temp2 + 2 + channel_offset,temp1 + 6*width + temp2 + 3 + channel_offset,temp1 + 6*width + temp2 + 4 + channel_offset,temp1 + 6*width + temp2 + 5 + channel_offset,temp1 + 6*width + temp2 + 6 + channel_offset,temp1 + 6*width + temp2 + 7 + channel_offset),
    (temp1 + 7*width + temp2 + channel_offset,temp1 + 7*width + temp2 + 1 + channel_offset,temp1 + 7*width + temp2 + 2 + channel_offset,temp1 + 7*width + temp2 + 3 + channel_offset,temp1 + 7*width + temp2 + 4 + channel_offset,temp1 + 7*width + temp2 + 5 + channel_offset,temp1 + 7*width + temp2 + 6 + channel_offset,temp1 + 7*width + temp2 + 7 + channel_offset))
print(address_mat)
