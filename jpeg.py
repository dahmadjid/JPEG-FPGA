import numpy 
import cv2
import time

img = cv2.imread('img.bmp')
current = time.time()
img = cv2.imwrite('img.jpeg',img)
print((time.time()-current)*1000)