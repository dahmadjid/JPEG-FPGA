import numpy
import cv2


mif = "DEPTH = 262144;\nWIDTH = 8;\nADDRESS_RADIX = UNS;\nDATA_RADIX = BIN;\nCONTENT BEGIN\n"
img = cv2.imread("img.bmp")
r,g,b = img[:,:,2],img[:,:,1],img[:,:,0]
for i in range(len(r)):
    for j in range(len(r[0])):

        address = str(i*256+j)
        data = bin(r[i,j])[2:].zfill(8)
        line = address+' : '+data+";\n"
        mif+= line

last = i*256+j
for i in range(len(g)):
    for j in range(len(g[0])):

        address = str(i*256+j+last+1)
        data = bin(r[i,j])[2:].zfill(8)
        line = address+' : '+data+";\n"
        mif+= line

for i in range(len(b)):
    for j in range(len(b[0])):

        address = str(i*256+j+last*2+2)
        data = bin(r[i,j])[2:].zfill(8)
        line = address+' : '+data+";\n"
        mif+= line

mif += "END;"
with open("img.mif",'w') as f:
    f.write(mif)