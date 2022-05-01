text = ""
for i in range(64):
    text += f"when {i} =>\npixel <= sfixed(data({511-i*8} downto {504-8*i}));\n"

with open("img_pixel_index.txt", "w") as f:
    f.write(text)
text = ""
for i in range(64):
    text += f"dct_coeff_block({i})&"
text += ";"
print(text)