import numpy as np
import cv2
import os
os.chdir("/home/madjid/Codes/JPEG FPGA/")

def add_binary_nums(x, y):
        max_len = max(len(x), len(y))
 
        x = x.zfill(max_len)
        y = y.zfill(max_len)
         
        # initialize the result
        result = ''
         
        # initialize the carry
        carry = 0
 
        # Traverse the string
        for i in range(max_len - 1, -1, -1):
            r = carry
            r += 1 if x[i] == '1' else 0
            r += 1 if y[i] == '1' else 0
            result = ('1' if r % 2 == 1 else '0') + result
            carry = 0 if r < 2 else 1     # Compute the carry.
         
        if carry !=0 : result = '1' + result
 
        return result.zfill(max_len)

        
def twosComp(bin_str):
    new = ''
    for i in range(len(bin_str)):
        if bin_str[i] == '0':
            new+= '1'
        else:
            new+= '0'
    new = add_binary_nums(new,'1')
    return new
lumi_table = [16,11,10,	16,	24,	40,	51,	61,12,	12,	14,	19,	26,	58,	60,	55,14,	13,	16,	24,	40,	57,	69,	56,14,	17,	22,	29,	51,	87,	80,	62,18,	22,	37,	56,	68,	109,103,77,24,	35,	55,	64,	81,	104,113,92,49,	64,	78,	87,	103,121,120,101,72,	92,	95,	98,	112,100,103,99]

chromi_table = [17,	18,	24,	47,	99,	99,	99,	99, 18,	21,	26,	66,	99,	99,	99,	99, 24,	26,	56,	99,	99,	99,	99,	99, 47,	66,	99,	99,	99, 99,	99,	99, 99,	99	,99,99,	99,	99,	99,	99, 99,	99,	99,	99	,99	,99	,99,99 ,99	,99	,99,	99,	99,	99,	99,	99, 99,	99,	99,	99,	99,	99,	99,	99]

img = cv2.imread("img_16x16.bmp")
width = img.shape[1]
height = img.shape[0]
img = np.array(img,dtype = "int32")
for i in range(len(img)):
    for j in range(len(img[0])):
        b,g,r = img[i,j]
        y = 0.299 * r + 0.587 * g + 0.114 * b - 128
        cb = -0.16873 * r  -0.33126 * g + 0.5 * b
        cr = 0.5 * r - 0.41868 * g - 0.08131 * b
        img[i,j] = [int(y),int(cb),int(cr)]
        if int(y) > 128 or int(cb)  > 128 or int(cr)  > 128 :
            print("FUCK")
r,g,b = img[:,:,0],img[:,:,1],img[:,:,2]  

text = ""
count = 0
for row_block_index in range(int(height/8)):
    for col_block_index in range(int(width/8)):
        blocks = [r[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index], g[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index] ,b[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index]]
        
        
        
        for channel in range(3): 
            text += f"-- channel = {channel}\ndct_coeff_zz_{count} <= ("
            block = blocks[channel]
            
            dct_block = cv2.dct(np.array(block, dtype = "float32"))
            for i in range(8):
                text += "("
                for j in range(8):
                    
                    # if channel == 0:
                    #     dct_block[i,j] /= lumi_table[i*8 + j]
                    # else:
                    #     dct_block[i,j] /= chromi_table[i*8 + j]
                    data = bin(abs(int(dct_block[i,j])))[2:].zfill(11)
                    if dct_block[i,j] < 0:
                        data = twosComp(data)
                    # print(channel , ":", i*8 + j , " : ", dct_block[i,j], " : ",data)
                    text += f'"{data}", '
                text = text[:-2] + " ), "
            text = text[:-2] + ");\n" 
            count += 1

with open("img_to_vhd_array.txt", "w") as f:
    f.write(text)

text = "dct_coeff_zz <= "

for i in range(12):
    text += f"dct_coeff_zz_{i} when block_sent = {i} else "
print(text)



img = cv2.imread("/home/madjid/Desktop/jpeg_file_from_fpga.jpg")
width = img.shape[1]
height = img.shape[0]
img = np.array(img,dtype = "int32")
for i in range(len(img)):
    for j in range(len(img[0])):
        b,g,r = img[i,j]
        y = 0.299 * r + 0.587 * g + 0.114 * b - 128
        cb = -0.16873 * r  -0.33126 * g + 0.5 * b
        cr = 0.5 * r - 0.41868 * g - 0.08131 * b
        img[i,j] = [int(y),int(cb),int(cr)]
        if int(y) > 128 or int(cb)  > 128 or int(cr)  > 128 :
            print("FUCK")


print(img[:,:,0])

print(img[:,:,1])

print(img[:,:,2])
print(cv2.dct(np.array(img[0:8,0:8,0], dtype = "float32"))[0,0]/16)
print(cv2.dct(np.array(img[0:8,0:8,1], dtype = "float32"))[0,0]/17)
print(cv2.dct(np.array(img[0:8,0:8,2], dtype = "float32"))[0,0]/17)

print(cv2.dct(np.array(img[0:8,8:,0], dtype = "float32"))[0,0]/16)
print(cv2.dct(np.array(img[0:8,8:,1], dtype = "float32"))[0,0]/17)
print(cv2.dct(np.array(img[0:8,8:,2], dtype = "float32"))[0,0]/17)


