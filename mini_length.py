signal_size = 11 #bit

length = ['"'+bin(signal_size-i)[2:].zfill(4)+'"' for i in range(signal_size+1)]
text = "\n"
for i in range(signal_size+1):
    text+= length[i] + ' when dct_coeff('+(str(signal_size - 1 - i)) + ") = '1'" +' else\n'

with open("mini_length.txt" ,"w") as f:
    f.write(text)
