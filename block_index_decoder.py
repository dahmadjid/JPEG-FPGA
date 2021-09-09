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
