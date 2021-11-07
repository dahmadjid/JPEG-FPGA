text = ''
im = 135
jm = 27

for i in range(1,im+1):
    linei = "        when " + str(i) + " =>\n    " 
    linei += "        case huff_code.code_length is \n    "
    text += linei
    for j in range(1,jm+1):
        length = i+j

        linej = "            when " + str(j) + " =>\n        "
        linej += "            mcu_code_ret.code(161 downto "+str(161 - length + 1)+") := mcu_code.code(161 downto "+str(161 - i + 1) + ")&huff_code.code(26 downto " + str(26-j+1) +");\n        " 
        linej += "            mcu_code_ret.code(" +str(161 - length)+" downto 0) := (others => '0');\n    "
        
        text += linej
    text+= "        end case;\n    "

with open("huff_code.txt" ,'w') as f:
    f.write(text)

