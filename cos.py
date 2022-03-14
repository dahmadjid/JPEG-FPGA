import math
import numpy as np
import os

os.chdir("C:\\codes\\JPEG FPGA\\")
# def decimal_converter(num): 
    
#     while num > 1:
#         num /= 10
#     return num
    
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
# def float_bin(number, places = 3):
  
#     # split() seperates whole number and decimal 
#     # part and stores it in two seperate variables
#     whole, dec = str(number).split(".")

#     # Convert both whole number and decimal  
#     # part from string type to integer type
#     whole = int(whole)
    
#     dec = int (dec)

#     # Convert the whole number part to it's
#     # respective binary form and remove the
#     # "0b" from it.
#     res = bin(whole).lstrip("0b") + "."
   
#     # Iterate the number of times, we want
#     # the number of decimal places to be
#     for x in range(places):
  
#         # Multiply the decimal value by 2 
#         # and seperate the whole number part
#         # and decimal part
#         try:
#             whole, dec = str((decimal_converter(dec)) * 2).split(".")
#         except:
#             whole = '0'
#             dec = 0
#             #print(str((decimal_converter(dec)) * 2).split(".")) 
#         # Convert the decimal part
#         # to integer again
#         dec = int(dec)
  
#         # Keep adding the integer parts 
#         # receive to the result variable
#         res += whole
        
#     return res
def decToBin(number, base, precision):
	number = str(number)
	integerPart = int( number[ : number.index(".") ] )
	fractionalPart = float( number[ number.index(".") : ] )
	
	output = ""
	
	while integerPart != 0:
		output = str( integerPart % base ) + output
		integerPart //= base
	
	if fractionalPart == 0:
		return output
	
	output += "."
	
	while fractionalPart != 0 and precision != 0 :
		fractionalPart *= base
		fractionalPartString = str(fractionalPart)
		output += fractionalPartString[ : fractionalPartString.index(".") ]
		fractionalPart = float( fractionalPartString[ fractionalPartString.index(".") : ] )
		precision -= 1
	
	return output
def twosComp(bin_str):
    new = ''
    for i in range(len(bin_str)):
        if bin_str[i] == '0':
            new+= '1'
        else:
            new+= '0'
    new = add_binary_nums(new,'1')
    return new


countlist = ["000","001","010","011","100","101","110","111"]

code = "cos <="
i,j = 0,0
for v in range(8):
    for y in range(8):
        cos_y = math.cos((2*y+1)*v*math.pi/16)

        cos = cos_y
        if cos == 1.0:
            code += '"0100000000000000000000"' + ' when "'+countlist[v] + countlist[y] +'",\n'
        elif cos == -1.0:
            code += '"1100000000000000000000"' + ' when "'+countlist[v] + countlist[y] +'",\n'
        elif cos < 0:
            code += '"'+twosComp('00'+decToBin(cos,2,20)[1:]) + '" when "'+countlist[v] + countlist[y] +'",\n'
        else:
            code += '"00'+decToBin(cos,2,20)[1:] + '" when "'+countlist[v] + countlist[y] +'",\n'
        if cos< 0.1:
            print(cos)

            

with open("cos.txt","w") as f:
    f.write(code)
# 2 bit whole (2's comp),16bit decimal part (1 downto -16)




# table = ""
# lumi_table = [16,11,10,	16,	24,	40,	51,	61,12,	12,	14,	19,	26,	58,	60,	55,14,	13,	16,	24,	40,	57,	69,	56,14,	17,	22,	29,	51,	87,	80,	62,18,	22,	37,	56,	68,	109,103,77,24,	35,	55,	64,	81,	104,113,92,49,	64,	78,	87,	103,121,120,101,72,	92,	95,	98,	112,100,103,99]
# lumi_table = np.array(lumi_table).reshape(8,8)
# chromi_table = [17,	18,	24,	47,	99,	99,	99,	99, 18,	21,	26,	66,	99,	99,	99,	99, 24,	26,	56,	99,	99,	99,	99,	99, 47,	66,	99,	99,	99, 99,	99,	99, 99,	99	,99,99,	99,	99,	99,	99, 99,	99,	99,	99	,99	,99	,99,99 ,99	,99	,99,	99,	99,	99,	99,	99, 99,	99,	99,	99,	99,	99,	99,	99]
# chromi_table = np.array(chromi_table).reshape(8,8)
# i = 0
# for row in lumi_table:
#     for val in row:
        
#         if i == 0:
#             table += '('
#         table += '"00'+decToBin(1/val,2,16)[1:].ljust(16,'0')+'",'
#         if i == 7:
#             table=table[:-1]+"),\n"
#             i = 0
#         else:
#             i += 1

# with open("luminance_table.txt",'w') as f:
#     f.write(table)
# table = ""

# i = 0
# for row in chromi_table:
#     for val in row:
        
#         if i == 0:
#             table += '('
#         table += '"00'+decToBin(1/val,2,16)[1:].ljust(16,'0')+'",'
#         if i == 7:
#             table=table[:-1]+"),\n"
#             i = 0
#         else:
#             i += 1

# with open("chrominance_table.txt",'w') as f:
#     f.write(table)

print(decToBin((1/4)*1/math.sqrt(2),2,32))
print(decToBin(1/8,2,32)[1:].ljust(32,'0'))
print(len("0000101101010000010011110011001100"))