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



for i in range(7):
    a = i + 1
    print(f'dct_u{a} : dct port map(to_unsigned({a},3),"000",img_pixel,clock,dct_working_s,dct_finished,y,x,const_2,dct_coeff_block({a})(0));')
    print(f'dct_v{a} : dct port map("000",to_unsigned({a},3),img_pixel,clock,dct_working_s,dct_finished,y,x,const_2,dct_coeff_block(0)({a}));')
for i in range(7):
    for j in range(7):
        v_int = i + 1
        u_int = j + 1
        print(f'dct_{v_int}{u_int} : dct port map(to_unsigned({v_int},3),to_unsigned({u_int},3),img_pixel,clock,dct_working_s,dct_finished,y,x,const_3,dct_coeff_block({v_int})({u_int}));')
        

    
