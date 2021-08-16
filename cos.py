import math
def decimal_converter(num): 
    while num > 1:
        num /= 10
    return num
    
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
def float_bin(number, places = 3):
  
    # split() seperates whole number and decimal 
    # part and stores it in two seperate variables
    
    whole, dec = str(number).split(".")

    # Convert both whole number and decimal  
    # part from string type to integer type
    whole = int(whole)
    
    dec = int (dec)
  
    # Convert the whole number part to it's
    # respective binary form and remove the
    # "0b" from it.
    res = bin(whole).lstrip("0b") + "."
    
    # Iterate the number of times, we want
    # the number of decimal places to be
    for x in range(places):
  
        # Multiply the decimal value by 2 
        # and seperate the whole number part
        # and decimal part
        whole, dec = str((decimal_converter(dec)) * 2).split(".")
  
        # Convert the decimal part
        # to integer again
        dec = int(dec)
  
        # Keep adding the integer parts 
        # receive to the result variable
        res += whole
   
    return res

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
for u in countlist:
    for x in countlist:
        
        cos = round(math.cos((2*i+1)*j*math.pi/16),3)
        if cos == 1.0:
            code += '"010000000000000000"' + ' when "'+u+x+'",\n'
        elif cos == -1.0:
            code += '"110000000000000000"' + ' when "'+u+x+'",\n'
        elif cos < 0:
            code += '"'+twosComp('00'+float_bin(cos,places=16)[1:]) + '" when "'+u+x+'",\n'
        else:
            code += '"00'+float_bin(cos,places=16)[1:] + '" when "'+u+x+'",\n'
        i += 1
    j += 1
print(code)
with open("cos.txt","w") as f:
    f.write(code)
# 2 bit whole (2's comp),16bit decimal part (1 downto -16)