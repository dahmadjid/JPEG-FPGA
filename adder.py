string = "dct_coeff <= "
for y in range(8):
    for x in range(8):
        y = str(y)
        x = str(x)
        string += f"const*const*cos_mat_a({y})({x}) * cos_mat_b({y})({x}) * to_integer(img_block({y})({x})) +"
with open("adder.txt","w") as f:
    f.write(string)

print("0"*99+"1"+"0"*100)