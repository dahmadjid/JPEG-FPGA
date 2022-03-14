import cv2
import numpy as np
import matplotlib.pyplot as plt
import math
import os
os.chdir("C:\Codes\JPEG FPGA")
img = cv2.imread('img_16x8.bmp')
#img = np.array([[[255 for i in range(3)] for j in range(8)] for k in range (8)],dtype = "uint8")
i = 0
j = 0
img_ycbcr = []
temp = []
img = np.array(img,dtype = "int32")
for i in range(len(img)):
    for j in range(len(img[0])):
        b,g,r = img[i,j]
 
        y = 0.299 * r + 0.587 * g + 0.114 * b - 128
        cb = -0.16873 * r  -0.33126 * g + 0.5 * b
        cr = 0.5 * r - 0.41868 * g - 0.08131 * b

        # y_ = ((r << 14)+(r << 11)+(r << 10)+(r << 7)+(r << 3)+(r << 2)+(r << 1)+(g << 15)+(g << 12)+(g << 10)+(g << 9)+(g << 6)+(g << 2)+(b << 12)+(b << 11)+(b << 10)+(b << 8)+(b << 5)+(b << 3)+(b << 2)+(b << 1)) >> 16
        # y_ -= 128
        # cb_ = ((b << 15)-(r << 13)-(r << 11)-(r << 9)-(r << 8)-(r << 5)-(r << 4)-(r << 1)-(g << 14)-(g << 12)-(g << 10)-(g << 7)-(g << 6)-(g << 2)) >> 16
        # cr_= ((r << 15)-(g << 14)-(g << 13)-(g << 11)-(g << 9)-(g << 8)-(g << 5)-(g << 3)-(g << 2)-(g << 1)-(b << 12)-(b << 10)-(b << 7)-(b << 6)-(b << 4)) >> 16

        img[i,j] = [int(y),int(cb),int(cr)]

        # if  y - y_ > 1 or y - y_ < -1 :
        #     print(int(y),y_)
        # if  cb - cb_ > 1 or cb - cb_ < -1 :
        #     print(int(cb),cb_)
        # if  cr - cr_ > 1 or cr - cr_ < -1 :
        #     print(int(cr),cr_)


I = int(img.shape[0]/8)
J = int(img.shape[1]/8)
i = 0
j = 0
img_y = img[:,:,0] 
img_cb = img[:,:,1]
img_cr = img[:,:,2] 
block_list_y = []
block_list_cb = []
block_list_cr = []
for i in range(I):
    for j in range(J):
        block_y = img_y[0+8*i:8+8*i,0+8*j:8+8*j]
        block_cb = img_cb[0+8*i:8+8*i,0+8*j:8+8*j]
        block_cr = img_cr[0+8*i:8+8*i,0+8*j:8+8*j]
        block_list_y.append(block_y)
        block_list_cb.append(block_cb)
        block_list_cr.append(block_cr)

# #print(block_list_y[0])
# string = "("
# i = 0
# for row in block_list_y[0]:
#     for val in row:
#         if i == 0:
#             string += '('
#         string += '"'+bin(int(val))[2:].zfill(8)+'",'
#         if i == 7:
#             string=string[:-1]+"),\n"
#             i = 0
#         else:
#             i += 1

# string = string[:-2] + ');'
# with open("block.txt","w") as f:
#     f.write(string)


def coscos(img,v,u,y,x):
    pix = img[y,x]
    return int(pix)*math.cos((2*y+1)*v*math.pi/16)*math.cos((2*x+1)*u*math.pi/16)

dct_coeff = np.zeros(block_list_y[-1].shape)

for v in range(8):
    for u in range(8):
        if v == 0:
            constant_v = 1 / math.sqrt(2)
        else:
            constant_v = 1
        if u == 0:
            constant_u = 1 / math.sqrt(2)
        else:
            constant_u = 1
        for y in range(8):
            for x in range(8): 
                
                dct_coeff[v,u] += 1/4 * constant_u*constant_v *coscos(block_list_y[0],v,u,y,x)
                # if v == 0 and u == 0:
                #     print(dct_coeff[0,0],bin(int(dct_coeff[0,0]))[2:].zfill(11))
        dct_coeff[v,u] = int(dct_coeff[v,u])
lumi_table = [16,11,10,	16,	24,	40,	51,	61,12,	12,	14,	19,	26,	58,	60,	55,14,	13,	16,	24,	40,	57,	69,	56,14,	17,	22,	29,	51,	87,	80,	62,18,	22,	37,	56,	68,	109,103,77,24,	35,	55,	64,	81,	104,113,92,49,	64,	78,	87,	103,121,120,101,72,	92,	95,	98,	112,100,103,99]

chromi_table = [17,	18,	24,	47,	99,	99,	99,	99, 18,	21,	26,	66,	99,	99,	99,	99, 24,	26,	56,	99,	99,	99,	99,	99, 47,	66,	99,	99,	99, 99,	99,	99, 99,	99	,99,99,	99,	99,	99,	99, 99,	99,	99,	99	,99	,99	,99,99 ,99	,99	,99,	99,	99,	99,	99,	99, 99,	99,	99,	99,	99,	99,	99,	99]

print(cv2.dct(np.array(block_list_y[0],dtype = "float32")))
print(cv2.dct(np.array(block_list_cb[0],dtype = "float32")))
print(cv2.dct(np.array(block_list_cr[0],dtype = "float32")))

# print(dct_coeff)
# def add_binary_nums(x, y):
#     max_len = max(len(x), len(y))

#     x = x.zfill(max_len)
#     y = y.zfill(max_len)
        
#     # initialize the result
#     result = ''
        
#     # initialize the carry
#     carry = 0

#     # Traverse the string
#     for i in range(max_len - 1, -1, -1):
#         r = carry
#         r += 1 if x[i] == '1' else 0
#         r += 1 if y[i] == '1' else 0
#         result = ('1' if r % 2 == 1 else '0') + result
#         carry = 0 if r < 2 else 1     # Compute the carry.
        
#     if carry !=0 : result = '1' + result

#     return result.zfill(max_len)
# def twosComp(bin_str):
#     new = ''
#     for i in range(len(bin_str)):
#         if bin_str[i] == '0':
#             new+= '1'
#         else:
#             new+= '0'
#     new = add_binary_nums(new,'1')
#     return new
# zigzag = np.array([
#     [0, 1, 5, 6, 14, 15, 27, 28],
# 	[2, 4, 7, 13, 16, 26, 29, 42],
# 	[3, 8, 12, 17, 25, 30, 41, 43],
# 	[9, 11, 18, 24, 31, 40, 44, 53],
# 	[10, 19, 23, 32, 39, 45, 52, 54],
# 	[20, 22, 33, 38, 46, 51, 55, 60],
# 	[21, 34, 37, 47, 50, 56, 59, 61],
# 	[35, 36, 48, 49, 57, 58, 62, 63]])
# zigzag = zigzag.reshape(64)
# new2 = [i for i in range(64)]
# new = [0 for i in range(64)]
# i = 0
# dct_coeff = dct_coeff.reshape(64)
# for index in zigzag:
#     new[index] = dct_coeff[i]
#     i += 1

# for i in range(64):
#     new[i] = new[i] /lumi_table[i]

# text = "dct_coeff_block_zz <= (" 
# for coeff in new:
#     coeff = int(coeff)
#     if coeff >= 0:
#         text += '"'+bin(int(coeff)).replace("0b","").zfill(11) + '", '
#     else:
#         text += '"'+twosComp(bin(int(coeff)).replace("-0b","").zfill(11)) + '", '

# with open("dct_coeff_zz","w") as f:
#     f.write(text)
