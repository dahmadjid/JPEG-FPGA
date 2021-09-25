import cv2
import numpy as np
import matplotlib.pyplot as plt
import math
import os

img = cv2.imread('img.bmp')
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

        y_ = ((r << 14)+(r << 11)+(r << 10)+(r << 7)+(r << 3)+(r << 2)+(r << 1)+(g << 15)+(g << 12)+(g << 10)+(g << 9)+(g << 6)+(g << 2)+(b << 12)+(b << 11)+(b << 10)+(b << 8)+(b << 5)+(b << 3)+(b << 2)+(b << 1)) >> 16
        y_ -= 128
        if i == 0 and j == 0:
            print(y,y_)
            print(r,g,b)
        cb_ = ((b << 15)-(r << 13)-(r << 11)-(r << 9)-(r << 8)-(r << 5)-(r << 4)-(r << 1)-(g << 14)-(g << 12)-(g << 10)-(g << 7)-(g << 6)-(g << 2)) >> 16
        cr_= ((r << 15)-(g << 14)-(g << 13)-(g << 11)-(g << 9)-(g << 8)-(g << 5)-(g << 3)-(g << 2)-(g << 1)-(b << 12)-(b << 10)-(b << 7)-(b << 6)-(b << 4)) >> 16

        img[i,j] = [int(y),int(cb),int(cr)]


        if int(y) > 128 or int(cb)  > 128 or int(cr)  > 128 :
            print("FUCK")
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

#print(block_list_y[0])
string = "("
i = 0
for row in block_list_y[0]:
    for val in row:
        if i == 0:
            string += '('
        string += '"'+bin(int(val))[2:].zfill(8)+'",'
        if i == 7:
            string=string[:-1]+"),\n"
            i = 0
        else:
            i += 1

string = string[:-2] + ');'
with open("block.txt","w") as f:
    f.write(string)


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

print(dct_coeff)