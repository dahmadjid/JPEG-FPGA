text = ''
im = 16
jm = 11

for i in range(1,im+1):
    linei = "    when " + str(i) + " =>\n    " 
    linei += "        case huff_value.code_length is \n    "
    text += linei
    for j in range(0,jm+1):
        length = i+j

        linej = "            when " + str(j) + " =>\n        "
        linej += "            huff_code.code(26 downto "+str(26 - length + 1)+") := ac_code.code(" + str(i-1) + " downto 0)&huff_value.code("+ str(j-1) + " downto 0);\n        " 
        linej += "            huff_code.code(" +str(26 - length)+" downto 0) := (others => '0');\n    "
        
        text += linej
    text+= "        end case;\n    "

with open("huff_code.txt" ,'w') as f:
    f.write(text)

