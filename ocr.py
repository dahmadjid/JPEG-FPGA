print(int(round(0.299 * 256  )) -  2**6-2**3)
print(int(round(0.587 * 256  )) -  2**7-2**4)
print(int(round(0.114 * 256  )) -  2**4-2**3)
print(int(round(0.16873 * 256)) -  2**5-2**3)
print(int(round(0.33126 * 256)) -  2**6-2**4)
print(int(round(0.5 * 256    )) -  2**7)
print(int(round(0.5 * 256    )) -  2**7)
print(int(round(0.41868 * 256)) -  2**6-2**5)
print(int(round(0.08131 * 256)) -  2**4-2**2)

r = 255
g = 255
b = 255
y = 0.299 * r + 0.587 * g + 0.114 * b - 128
cb = -0.16873 * r  -0.33126 * g + 0.5 * b
cr = 0.5 * r - 0.41868 * g - 0.08131 * b

print(y,cb,cr)
print(bin(165))