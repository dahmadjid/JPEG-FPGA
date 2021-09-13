print(int(round(0.299 * 256  )) -  2**6-2**3)
print(int(round(0.587 * 256  )) -  2**7-2**4)
print(int(round(0.114 * 256  )) -  2**4-2**3)
print(int(round(0.16873 * 256)) -  2**5-2**3)
print(int(round(0.33126 * 256)) -  2**6-2**4)
print(int(round(0.5 * 256    )) -  2**7)
print(int(round(0.5 * 256    )) -  2**7)
print(int(round(0.41868 * 256)) -  2**6-2**5)
print(int(round(0.08131 * 256)) -  2**4-2**2)

r = 0
g = 255
b = 255
y = 0.299 * r + 0.587 * g + 0.114 * b - 128
cb = -0.168736 * r  -0.331264 * g + 0.5 * b
cr = 0.5 * r - 0.418688 * g - 0.081312 * b
print(y,cb,cr)
# def shift(x,right_shift,shift_list):
#     y = 0
#     for shift in shift_list:
#         y += x << shift
#     y = y >> right_shift
#     return y

# r= 0xff
# g= 0xff
# b= 0xff
# y_shifters = [[14,11,10,7,3,2,1],[15,12,10,9,6,2],[12,11,10,8,5,3,2,1]]
# cb_shifters = [[13,11,9,8,5,4,1],[14,12,10,7,6,2],[15]]
# cr_shifters = [[15],[14,13,11,9,8,5,3,2,1],[12,10,7,6,4]]

# y  = (((r << 6) + (r << 3) + (r << 2) + (g << 7) + (g << 4) + (g << 2) + (b << 4) + (b << 3) + (b << 2)) >> 8 )- 128
# cb = ((b << 7) - (r << 5) - (r << 3) - (g << 6) - (g << 4)) >> 8 
# cr = ((r << 7) - (g << 6) - (g << 5) - (g << 3) - (b << 4) - (b << 2)) >> 8 

# print(shift(r,16,[12,10,7,6,4]),0.081312 * r)
# chan=("rs","gs","bs")
# text = ""
# line = "y_temp <= ("
# i = 0
# for coeff in y_shifters:
#     for shift in coeff:
#         operation = "(" + chan[i] +" sll " + str(shift) +")+"
#         line += operation
    
#     i+=1

# text += line + ") srl 16\n"

# line = "cb_temp <= ("
# i = 0
# for coeff in cb_shifters:
#     for shift in coeff:
#         operation = "(" + chan[i] +" sll " + str(shift) +")+"
#         line += operation
    
#     i+=1

# text += line + ") srl 16\n"

# line = "cr_temp <= ("
# i = 0
# for coeff in cr_shifters:
#     for shift in coeff:
#         operation = "(" + chan[i] +" sll " + str(shift) +")+"
#         line += operation
    
#     i+=1

# text += line + ") srl 16\n"
# with open("rgb_ycbcr.txt" , 'w') as f:
#     f.write(text)
# # print(y,cb,cr)
# # print(bin(165))