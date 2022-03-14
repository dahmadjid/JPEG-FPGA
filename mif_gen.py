import numpy as np
import cv2
import os
os.chdir("C:\\Codes\\JPEG FPGA")
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


mif = "DEPTH = 262144;\nWIDTH = 8;\nADDRESS_RADIX = UNS;\nDATA_RADIX = BIN;\nCONTENT BEGIN\n"
img = cv2.imread("img_16x16.bmp")
width = img.shape[1]
height = img.shape[0]

r,g,b = img[:,:,2],img[:,:,1],img[:,:,0]
for channel in range(3):     
    for row_block_index in range(int(height/8)):
        for col_block_index in range(int(width/8)):
            blocks = [r[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index], g[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index] ,b[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index]]
            block = blocks[channel]
            for i in range(8):
                for j in range(8):
                    address = str(i*8+j + row_block_index*8*width + col_block_index*64 + width*height*channel )
                    data = bin(block[i,j])[2:].zfill(8)
                    line = address+' : '+data+";\n"
                    # print(line)
                    mif+= line
mif += "END;"
with open("img_16x16.mif",'w') as f:
    f.write(mif)
# for i in range(len(r)):
#     for j in range(len(r[0])):

#         address = str(i*width+j)
#         data = bin(r[i,j])[2:].zfill(8)
#         line = address+' : '+data+";\n"
#         mif+= line

# last = i*width+j

# for i in range(len(g)):
#     for j in range(len(g[0])):

#         address = str(i*width+j+last+1)
#         data = bin(g[i,j])[2:].zfill(8)
#         line = address+' : '+data+";\n"
#         mif+= line

# for i in range(len(b)):
#     for j in range(len(b[0])):

#         address = str(i*width+j+last*2+2)
#         data = bin(b[i,j])[2:].zfill(8)
#         line = address+' : '+data+";\n"
#         mif+= line

# mif += "END;"
# with open("img_16x8.mif",'w') as f:
#     f.write(mif)

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

mif = "DEPTH = 262144;\nWIDTH = 8;\nADDRESS_RADIX = UNS;\nDATA_RADIX = BIN;\nCONTENT BEGIN\n"
r,g,b = img[:,:,0],img[:,:,1],img[:,:,2]  
print(g)
for channel in range(3):     
    for row_block_index in range(int(height/8)):
        for col_block_index in range(int(width/8)):
            blocks = [r[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index], g[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index] ,b[0+8*row_block_index:8+8*row_block_index,  0+8*col_block_index: 8+8*col_block_index]]
            block = blocks[channel]
            for i in range(8):
                for j in range(8):
                    address = str(i*8+j + row_block_index*8*width + col_block_index*64 + width*height*channel )
                    data = bin(abs(block[i,j]))[2:].zfill(8)
                    if r[i,j] < 0:
                        data = twosComp(data)
                    line = address+' : '+data +";\n"
                    # print(line)
                    mif+= line
mif += "END;"
with open("img_ycbcr.mif",'w') as f:
    f.write(mif)
# for i in range(len(r)):
#     for j in range(len(r[0])):

#         address = str(i*width+j)
#         data = bin(abs(r[i,j]))[2:].zfill(8)
#         if r[i,j] < 0:
#             data = twosComp(data)
#         line = address+' : '+data+" "+str(r[i,j])+";\n"
#         mif+= line

# last = i*width+j
# for i in range(len(g)):
#     for j in range(len(g[0])):

#         address = str(i*width+j+last+1)
#         data = bin(abs(g[i,j]))[2:].zfill(8)
#         if g[i,j] < 0:
#             data = twosComp(data)
#         line = address+' : '+data+" "+str(g[i,j])+";\n"
#         mif+= line

# for i in range(len(b)):
#     for j in range(len(b[0])):

#         address = str(i*width+j+last*2+2)
#         data = bin(abs(b[i,j]))[2:].zfill(8)
#         if b[i,j] < 0:
#             data = twosComp(data)
#         line = address+' : '+data+" "+str(b[i,j])+";\n"
#         mif+= line

# mif += "END;"
# with open("img_ycbcr.mif",'w') as f:
#     f.write(mif)
