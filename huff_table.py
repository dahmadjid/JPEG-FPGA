# import numpy as np

# test =[[(j,i) for i in range(8) ] for j in range(8)]
# zigzag = np.array([
#     [0, 1, 5, 6, 14, 15, 27, 28],
# 	[2, 4, 7, 13, 16, 26, 29, 42],
# 	[3, 8, 12, 17, 25, 30, 41, 43],
# 	[9, 11, 18, 24, 31, 40, 44, 53],
# 	[10, 19, 23, 32, 39, 45, 52, 54],
# 	[20, 22, 33, 38, 46, 51, 55, 60],
# 	[21, 34, 37, 47, 50, 56, 59, 61],
# 	[35, 36, 48, 49, 57, 58, 62, 63]])
# print(test)
# zigzag = zigzag.reshape(64)

# print(zigzag)
# new2 = [i for i in range(64)]
# new = [0 for i in range(64)]
# i = 0
# test = np.array(test).reshape(64,2).tolist()
# for index in zigzag:
#     new[index] = new2[i]
#     i += 1
# print(new)

# text = "dct_coeff_zz <= ("
# for j,i in new:
#     line = f"dct_coeff_block_qz({j})({i}),"
#     text += line
# with open("zigzag.txt" ,"w") as f:
#     f.write(text)
# print(new)




 




from operator import mod
from numpy import byte


HUFFMAN_CATEGORIES = (
    (0, ),
    (-1, 1),
    (-3, -2, 2, 3),
    (*range(-7, -4 + 1), *range(4, 7 + 1)),
    (*range(-15, -8 + 1), *range(8, 15 + 1)),
    (*range(-31, -16 + 1), *range(16, 31 + 1)),
    (*range(-63, -32 + 1), *range(32, 63 + 1)),
    (*range(-127, -64 + 1), *range(64, 127 + 1)),
    (*range(-255, -128 + 1), *range(128, 255 + 1)),
    (*range(-511, -256 + 1), *range(256, 511 + 1)),
    (*range(-1023, -512 + 1), *range(512, 1023 + 1)),
    (*range(-2047, -1024 + 1), *range(1024, 2047 + 1)),
    (*range(-4095, -2048 + 1), *range(2048, 4095 + 1)),
    (*range(-8191, -4096 + 1), *range(4096, 8191 + 1)),
    (*range(-16383, -8192 + 1), *range(8192, 16383 + 1)),
    (*range(-32767, -16384 + 1), *range(16384, 32767 + 1))
)

dc_y_huff = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
dc_c_huff = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
ac_y_huff = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
ac_c_huff = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]

HUFFMAN_CATEGORY_CODEWORD = {
    "DC": {
        "LUMINANCE":{   # 9 bit code length
            0:  '00',
            1:  '010',
            2:  '011',
            3:  '100',
            4:  '101',
            5:  '110',
            6:  '1110',
            7:  '11110',
            8:  '111110',
            9:  '1111110',
            10: '11111110',
            11: '111111110'     
        },
        # 1110111111
        "CHROMINANCE":{  # 11bit code length
            0:  '00',
            1:  '01',
            2:  '10',
            3:  '110',
            4:  '1110',
            5:  '11110',
            6:  '111110',
            7:  '1111110',
            8:  '11111110',
            9:  '111111110',
            10: '1111111110',
            11: '11111111110'   
        }
    },

    "AC": { # 16 bit code length 
        "LUMINANCE":{
            "EOB": '1010',  # (0, 0)
            "ZRL": '11111111001',  # (F, 0)

            (0, 1):  '00',
            (0, 2):  '01',
            (0, 3):  '100', 
            (0, 4):  '1011',
            (0, 5):  '11010',
            (0, 6):  '1111000',
            (0, 7):  '11111000',
            (0, 8):  '1111110110',
            (0, 9):  '1111111110000010',
            (0, 10): '1111111110000011',

            (1, 1):  '1100',
            (1, 2):  '11011',
            (1, 3):  '1111001',
            (1, 4):  '111110110',
            (1, 5):  '11111110110',
            (1, 6):  '1111111110000100',
            (1, 7):  '1111111110000101',
            (1, 8):  '1111111110000110',
            (1, 9):  '1111111110000111',
            (1, 10): '1111111110001000',

            (2, 1):  '11100',
            (2, 2):  '11111001',
            (2, 3):  '1111110111',
            (2, 4):  '111111110100',
            (2, 5):  '1111111110001001',
            (2, 6):  '1111111110001010',
            (2, 7):  '1111111110001011',
            (2, 8):  '1111111110001100',
            (2, 9):  '1111111110001101',
            (2, 10): '1111111110001110',

            (3, 1):  '111010',
            (3, 2):  '111110111',
            (3, 3):  '111111110101',
            (3, 4):  '1111111110001111',
            (3, 5):  '1111111110010000',
            (3, 6):  '1111111110010001',
            (3, 7):  '1111111110010010',
            (3, 8):  '1111111110010011',
            (3, 9):  '1111111110010100',
            (3, 10): '1111111110010101',

            (4, 1):  '111011',
            (4, 2):  '1111111000',
            (4, 3):  '1111111110010110',
            (4, 4):  '1111111110010111',
            (4, 5):  '1111111110011000',
            (4, 6):  '1111111110011001',
            (4, 7):  '1111111110011010',
            (4, 8):  '1111111110011011',
            (4, 9):  '1111111110011100',
            (4, 10): '1111111110011101',

            (5, 1):  '1111010',
            (5, 2):  '11111110111',
            (5, 3):  '1111111110011110',
            (5, 4):  '1111111110011111',
            (5, 5):  '1111111110100000',
            (5, 6):  '1111111110100001',
            (5, 7):  '1111111110100010',
            (5, 8):  '1111111110100011',
            (5, 9):  '1111111110100100',
            (5, 10): '1111111110100101',

            (6, 1):  '1111011',
            (6, 2):  '111111110110',
            (6, 3):  '1111111110100110',
            (6, 4):  '1111111110100111',
            (6, 5):  '1111111110101000',
            (6, 6):  '1111111110101001',
            (6, 7):  '1111111110101010',
            (6, 8):  '1111111110101011',
            (6, 9):  '1111111110101100',
            (6, 10): '1111111110101101',

            (7, 1):  '11111010',
            (7, 2):  '111111110111',
            (7, 3):  '1111111110101110',
            (7, 4):  '1111111110101111',
            (7, 5):  '1111111110110000',
            (7, 6):  '1111111110110001',
            (7, 7):  '1111111110110010',
            (7, 8):  '1111111110110011',
            (7, 9):  '1111111110110100',
            (7, 10): '1111111110110101',

            (8, 1):  '111111000',
            (8, 2):  '111111111000000',
            (8, 3):  '1111111110110110',
            (8, 4):  '1111111110110111',
            (8, 5):  '1111111110111000',
            (8, 6):  '1111111110111001',
            (8, 7):  '1111111110111010',
            (8, 8):  '1111111110111011',
            (8, 9):  '1111111110111100',
            (8, 10): '1111111110111101',

            (9, 1):  '111111001',
            (9, 2):  '1111111110111110',
            (9, 3):  '1111111110111111',
            (9, 4):  '1111111111000000',
            (9, 5):  '1111111111000001',
            (9, 6):  '1111111111000010',
            (9, 7):  '1111111111000011',
            (9, 8):  '1111111111000100',
            (9, 9):  '1111111111000101',
            (9, 10): '1111111111000110',
            # A
            (10, 1):  '111111010',
            (10, 2):  '1111111111000111',
            (10, 3):  '1111111111001000',
            (10, 4):  '1111111111001001',
            (10, 5):  '1111111111001010',
            (10, 6):  '1111111111001011',
            (10, 7):  '1111111111001100',
            (10, 8):  '1111111111001101',
            (10, 9):  '1111111111001110',
            (10, 10): '1111111111001111',
            # B
            (11, 1):  '1111111001',
            (11, 2):  '1111111111010000',
            (11, 3):  '1111111111010001',
            (11, 4):  '1111111111010010',
            (11, 5):  '1111111111010011',
            (11, 6):  '1111111111010100',
            (11, 7):  '1111111111010101',
            (11, 8):  '1111111111010110',
            (11, 9):  '1111111111010111',
            (11, 10): '1111111111011000',
            # C
            (12, 1):  '1111111010',
            (12, 2):  '1111111111011001',
            (12, 3):  '1111111111011010',
            (12, 4):  '1111111111011011',
            (12, 5):  '1111111111011100',
            (12, 6):  '1111111111011101',
            (12, 7):  '1111111111011110',
            (12, 8):  '1111111111011111',
            (12, 9):  '1111111111100000',
            (12, 10): '1111111111100001',
            # D
            (13, 1):  '11111111000',
            (13, 2):  '1111111111100010',
            (13, 3):  '1111111111100011',
            (13, 4):  '1111111111100100',
            (13, 5):  '1111111111100101',
            (13, 6):  '1111111111100110',
            (13, 7):  '1111111111100111',
            (13, 8):  '1111111111101000',
            (13, 9):  '1111111111101001',
            (13, 10): '1111111111101010',
            # E
            (14, 1):  '1111111111101011',
            (14, 2):  '1111111111101100',
            (14, 3):  '1111111111101101',
            (14, 4):  '1111111111101110',
            (14, 5):  '1111111111101111',
            (14, 6):  '1111111111110000',
            (14, 7):  '1111111111110001',
            (14, 8):  '1111111111110010',
            (14, 9):  '1111111111110011',
            (14, 10): '1111111111110100',
            # F
            (15, 1):  '1111111111110101',
            (15, 2):  '1111111111110110',
            (15, 3):  '1111111111110111',
            (15, 4):  '1111111111111000',
            (15, 5):  '1111111111111001',
            (15, 6):  '1111111111111010',
            (15, 7):  '1111111111111011',
            (15, 8):  '1111111111111100',
            (15, 9):  '1111111111111101',
            (15, 10): '1111111111111110'
            },
        "CHROMINANCE":
            {
            "EOB": '00',  # (0, 0)
            "ZRL": '1111111010',  # (F, 0)

            (0, 1):  '01',
            (0, 2):  '100',
            (0, 3):  '1010',
            (0, 4):  '11000',
            (0, 5):  '11001',
            (0, 6):  '111000',
            (0, 7):  '1111000',
            (0, 8):  '111110100',
            (0, 9):  '1111110110',
            (0, 10): '111111110100',

            (1, 1):  '1011',
            (1, 2):  '111001',
            (1, 3):  '11110110',
            (1, 4):  '111110101',
            (1, 5):  '11111110110',
            (1, 6):  '111111110101',
            (1, 7):  '1111111110001000',
            (1, 8):  '1111111110001001',
            (1, 9):  '1111111110001010',
            (1, 10): '1111111110001011',

            (2, 1):  '11010',
            (2, 2):  '11110111',
            (2, 3):  '1111110111',
            (2, 4):  '111111110110',
            (2, 5):  '111111111000010',
            (2, 6):  '1111111110001100',
            (2, 7):  '1111111110001101',
            (2, 8):  '1111111110001110',
            (2, 9):  '1111111110001111',
            (2, 10): '1111111110010000',

            (3, 1):  '11011',
            (3, 2):  '11111000',
            (3, 3):  '1111111000',
            (3, 4):  '111111110111',
            (3, 5):  '1111111110010001',
            (3, 6):  '1111111110010010',
            (3, 7):  '1111111110010011',
            (3, 8):  '1111111110010100',
            (3, 9):  '1111111110010101',
            (3, 10): '1111111110010110',

            (4, 1):  '111010',
            (4, 2):  '111110110',
            (4, 3):  '1111111110010111',
            (4, 4):  '1111111110011000',
            (4, 5):  '1111111110011001',
            (4, 6):  '1111111110011010',
            (4, 7):  '1111111110011011',
            (4, 8):  '1111111110011100',
            (4, 9):  '1111111110011101',
            (4, 10): '1111111110011110',

            (5, 1):  '111011',
            (5, 2):  '1111111001',
            (5, 3):  '1111111110011111',
            (5, 4):  '1111111110100000',
            (5, 5):  '1111111110100001',
            (5, 6):  '1111111110100010',
            (5, 7):  '1111111110100011',
            (5, 8):  '1111111110100100',
            (5, 9):  '1111111110100101',
            (5, 10): '1111111110100110',

            (6, 1):  '1111001',
            (6, 2):  '11111110111',
            (6, 3):  '1111111110100111',
            (6, 4):  '1111111110101000',
            (6, 5):  '1111111110101001',
            (6, 6):  '1111111110101010',
            (6, 7):  '1111111110101011',
            (6, 8):  '1111111110101100',
            (6, 9):  '1111111110101101',
            (6, 10): '1111111110101110',

            (7, 1):  '1111010',
            (7, 2):  '111111110000',
            (7, 3):  '1111111110101111',
            (7, 4):  '1111111110110000',
            (7, 5):  '1111111110110001',
            (7, 6):  '1111111110110010',
            (7, 7):  '1111111110110011',
            (7, 8):  '1111111110110100',
            (7, 9):  '1111111110110101',
            (7, 10): '1111111110110110',

            (8, 1):  '11111001',
            (8, 2):  '1111111110110111',
            (8, 3):  '1111111110111000',
            (8, 4):  '1111111110111001',
            (8, 5):  '1111111110111010',
            (8, 6):  '1111111110111011',
            (8, 7):  '1111111110111100',
            (8, 8):  '1111111110111101',
            (8, 9):  '1111111110111110',
            (8, 10): '1111111110111111',

            (9, 1):  '111110111',
            (9, 2):  '1111111111000000',
            (9, 3):  '1111111111000001',
            (9, 4):  '1111111111000010',
            (9, 5):  '1111111111000011',
            (9, 6):  '1111111111000100',
            (9, 7):  '1111111111000101',
            (9, 8):  '1111111111000110',
            (9, 9):  '1111111111000111',
            (9, 10): '1111111111001000',
            # A
            (10, 1):  '111111000',
            (10, 2):  '1111111111001001',
            (10, 3):  '1111111111001010',
            (10, 4):  '1111111111001011',
            (10, 5):  '1111111111001100',
            (10, 6):  '1111111111001101',
            (10, 7):  '1111111111001110',
            (10, 8):  '1111111111001111',
            (10, 9):  '1111111111010000',
            (10, 10): '1111111111010001',
            # B
            (11, 1):  '111111001',
            (11, 2):  '1111111111010010',
            (11, 3):  '1111111111010011',
            (11, 4):  '1111111111010100',
            (11, 5):  '1111111111010101',
            (11, 6):  '1111111111010110',
            (11, 7):  '1111111111010111',
            (11, 8):  '1111111111011000',
            (11, 9):  '1111111111011001',
            (11, 10): '1111111111011010',
            # C
            (12, 1):  '111111010',
            (12, 2):  '1111111111011011',
            (12, 3):  '1111111111011100',
            (12, 4):  '1111111111011101',
            (12, 5):  '1111111111011110',
            (12, 6):  '1111111111011111',
            (12, 7):  '1111111111100000',
            (12, 8):  '1111111111100001',
            (12, 9):  '1111111111100010',
            (12, 10): '1111111111100011',
            # D
            (13, 1):  '11111111001',
            (13, 2):  '1111111111100100',
            (13, 3):  '1111111111100101',
            (13, 4):  '1111111111100110',
            (13, 5):  '1111111111100111',
            (13, 6):  '1111111111101000',
            (13, 7):  '1111111111101001',
            (13, 8):  '1111111111101010',
            (13, 9):  '1111111111101011',
            (13, 10): '1111111111101100',
            # E
            (14, 1):  '11111111100000',
            (14, 2):  '1111111111101101',
            (14, 3):  '1111111111101110',
            (14, 4):  '1111111111101111',
            (14, 5):  '1111111111110000',
            (14, 6):  '1111111111110001',
            (14, 7):  '1111111111110010',
            (14, 8):  '1111111111110011',
            (14, 9):  '1111111111110100',
            (14, 10): '1111111111110101',
            # F
            (15, 1):  '111111111000011',
            (15, 2):  '1111111111110110',
            (15, 3):  '1111111111110111',
            (15, 4):  '1111111111111000',
            (15, 5):  '1111111111111001',
            (15, 6):  '1111111111111010',
            (15, 7):  '1111111111111011',
            (15, 8):  '1111111111111100',
            (15, 9):  '1111111111111101',
            (15, 10): '1111111111111110'
        }
    }
}

# ------------------------------------------------------------
# HUFFMAN TABLE LOOKUP TABLE GENERATOR FOR VHDL
# text = "("
# for length,code in HUFFMAN_CATEGORY_CODEWORD['DC']['LUMINANCE'].items():
#     pair = '("' + code.zfill(9) + '",' + str(len(code)) + "),"
#     text += pair
# text = text[:-1]  + ');\n\n('
# for length,code in HUFFMAN_CATEGORY_CODEWORD['DC']['CHROMINANCE'].items():
#     pair = '("' + code.zfill(11) + '",' + str(len(code)) + "),"
#     text += pair
# text = text[:-1]  + ');\n\n(('
# i = 0
# for length,code in HUFFMAN_CATEGORY_CODEWORD['AC']['LUMINANCE'].items():
#     if str(length) in "EOBZRL":
#         continue
#     pair = '("' + code.zfill(16) + '",' + str(len(code)) + "),"
#     text += pair
#     if i == 9: 
#         text = text[:-1] + "),\n("
#         i = 0
#     else:
#         i += 1
# i = 0
# text = text[:-3] + ');\n\n((' 
# for length,code in HUFFMAN_CATEGORY_CODEWORD['AC']['CHROMINANCE'].items():
#     if str(length) in "EOBZRL":
#         continue
#     pair = '("' + code.zfill(16) + '",' + str(len(code)) + "),"
#     text += pair
#     if i == 9: 
#         text = text[:-1] + "),\n("
#         i = 0
#     else:
#         i += 1
# text = text[:-3] + ');\n\n'
# with open("huff_table.txt" ,'w') as f:
#     f.write(text)
# ------------------------------------------------------------------------------

for key,value in HUFFMAN_CATEGORY_CODEWORD["DC"]["LUMINANCE"].items():
    dc_y_huff[len(value)-1].append((value, key))
    dc_y_huff[len(value)-1] = sorted(dc_y_huff[len(value)-1], key=lambda tup: int(tup[0]))

for key,value in HUFFMAN_CATEGORY_CODEWORD["DC"]["CHROMINANCE"].items():
    dc_c_huff[len(value)-1].append((value, key))
    dc_c_huff[len(value)-1] = sorted(dc_c_huff[len(value)-1], key=lambda tup: int(tup[0]))
for key,value in HUFFMAN_CATEGORY_CODEWORD["AC"]["LUMINANCE"].items():
    if key == "EOB":
        key = (0,0)
    elif key == "ZRL":
        key = (15,0)
    ac_y_huff[len(value)-1].append((value, key[0]*16+key[1]))
    ac_y_huff[len(value)-1] = sorted(ac_y_huff[len(value)-1], key=lambda tup: int(tup[0]))
for key,value in HUFFMAN_CATEGORY_CODEWORD["AC"]["CHROMINANCE"].items():
    if key == "EOB":
        key = (0,0)
    elif key == "ZRL":
        key = (15,0)
    ac_c_huff[len(value)-1].append((value, key[0]*16+key[1]))
    ac_c_huff[len(value)-1] = sorted(ac_c_huff[len(value)-1], key=lambda tup: int(tup[0]))

for i in range(len(dc_y_huff)):
    for j in range(len(dc_y_huff[i])):
        dc_y_huff[i][j] = dc_y_huff[i][j][1]
for i in range(len(dc_c_huff)):
    for j in range(len(dc_c_huff[i])):
        dc_c_huff[i][j] = dc_c_huff[i][j][1]
for i in range(len(ac_y_huff)):
    for j in range(len(ac_y_huff[i])):
        ac_y_huff[i][j] = ac_y_huff[i][j][1]
for i in range(len(ac_c_huff)):
    for j in range(len(ac_c_huff[i])):
        ac_c_huff[i][j] = ac_c_huff[i][j][1]


dc_y_bytes = bytearray()
dc_y_len = []
for cat in dc_y_huff:
    num_in_cat = len(cat)
    dc_y_len.append(num_in_cat)
    temp_dc_y_bytes = bytearray(cat)
    # temp_dc_y_bytes.extend(cat)
    dc_y_bytes.extend(temp_dc_y_bytes)
temp = bytearray(dc_y_len)
temp.extend(dc_y_bytes)
dc_y_bytes = temp

dc_c_bytes = bytearray()
dc_c_len = []
for cat in dc_c_huff:
    num_in_cat = len(cat)
    dc_c_len.append(num_in_cat)
    temp_dc_c_bytes = bytearray(cat)
    # temp_dc_c_bytes.extend(cat)
    dc_c_bytes.extend(temp_dc_c_bytes)
temp = bytearray(dc_c_len)
temp.extend(dc_c_bytes)
dc_c_bytes = temp

ac_y_bytes = bytearray()
ac_y_len = []
for cat in ac_y_huff:

    num_in_cat = len(cat)
    ac_y_len.append(num_in_cat)
    temp_ac_y_bytes = bytearray(cat)
    # temp_ac_y_bytes.extend(cat)
    ac_y_bytes.extend(temp_ac_y_bytes)
temp = bytearray(ac_y_len)
temp.extend(ac_y_bytes)
ac_y_bytes = temp

ac_c_bytes = bytearray()
ac_c_len = []
for cat in ac_c_huff:
    num_in_cat = len(cat)
    ac_c_len.append(num_in_cat)
    temp_ac_c_bytes = bytearray(cat)
    # temp_ac_c_bytes.extend(cat)
    ac_c_bytes.extend(temp_ac_c_bytes)
temp = bytearray(ac_c_len)
temp.extend(ac_c_bytes)
ac_c_bytes = temp

lumi_table = bytearray([16,11,10,	16,	24,	40,	51,	61,12,	12,	14,	19,	26,	58,	60,	55,14,	13,	16,	24,	40,	57,	69,	56,14,	17,	22,	29,	51,	87,	80,	62,18,	22,	37,	56,	68,	109,103,77,24,	35,	55,	64,	81,	104,113,92,49,	64,	78,	87,	103,121,120,101,72,	92,	95,	98,	112,100,103,99])

chromi_table = bytearray([17,	18,	24,	47,	99,	99,	99,	99, 18,	21,	26,	66,	99,	99,	99,	99, 24,	26,	56,	99,	99,	99,	99,	99, 47,	66,	99,	99,	99, 99,	99,	99, 99,	99	,99,99,	99,	99,	99,	99, 99,	99,	99,	99	,99	,99	,99,99 ,99	,99	,99,	99,	99,	99,	99,	99, 99,	99,	99,	99,	99,	99,	99,	99])

jpeg_header = bytearray()
app_header = bytearray([0xFF,0xD8,0xFF,0xE0,0x00,0x10,0x4A, 0x46, 0x49 ,0x46 ,0x00,0x01,0x01,0x01,0x00,0x78,0x00,0x78,0x00,0x00])
quant_lumi_header = bytearray([0xFF, 0xDB, 0x00 ,0x43, 0x00])

quant_chromi_header = bytearray([0xFF, 0xDB, 0x00 ,0x43, 0x01])
quant_lumi_header.extend(lumi_table)
quant_chromi_header.extend(chromi_table)
width = 16
height = 16
frame_header = bytearray([0xFF,0xC0,0x00,0x11,0x08, 0x00,height,0x00,width,0x03,0x01,0x11,0x00,0x02,0x11,0x01,0x03,0x11,0x01])

dc_y_header = bytearray([0xFF,0xC4,0x00,0x00,0x00])
dc_y_header.extend(dc_y_bytes)
# print(len(dc_y_header))
dc_y_header[2] = (len(dc_y_header) - 2) - (len(dc_y_header) - 2) % 256
dc_y_header[3] = (len(dc_y_header) - 2) % 256

dc_c_header = bytearray([0xFF,0xC4,0x00,0x00,0x01])
dc_c_header.extend(dc_c_bytes)
# print(len(dc_c_header))
dc_c_header[2] = (len(dc_c_header) - 2) - (len(dc_c_header) - 2) % 256
dc_c_header[3] = (len(dc_c_header) - 2) % 256

ac_y_header = bytearray([0xFF,0xC4,0x00,0x00,0x10])
ac_y_header.extend(ac_y_bytes)
# print(len(ac_y_header))
ac_y_header[2] = (len(ac_y_header) - 2) - (len(ac_y_header) - 2) % 256
ac_y_header[3] = (len(ac_y_header) - 2) % 256

ac_c_header = bytearray([0xFF,0xC4,0x00,0x00,0x11])
ac_c_header.extend(ac_c_bytes)
# print(len(ac_c_header))
ac_c_header[2] = (len(ac_c_header) - 2) - (len(ac_c_header) - 2) % 256
ac_c_header[3] = (len(ac_c_header) - 2) % 256

# print(ac_c_header)
scan_header = bytearray([0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F,0x00])
# scan_data = bytearray([0xDD,0xA0,0x00])


jpeg_header.extend(app_header)
jpeg_header.extend(quant_lumi_header)
jpeg_header.extend(quant_chromi_header)
jpeg_header.extend(frame_header)
jpeg_header.extend(dc_y_header)
jpeg_header.extend(dc_c_header)
jpeg_header.extend(ac_y_header)
jpeg_header.extend(ac_c_header)
jpeg_header.extend(scan_header)
# jpeg_header.extend(scan_data)
# jpeg_header.extend([0xFF,0xD9]) 





bitwise_masks = [0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F, 0xFF]

def shiftbybits(b_array, bits):
    if bits == 0:
        return b_array
    modulo_bits = bits % 8
    bytes_num = int(bits / 8)
    print(bytes_num, modulo_bits)
    output_array = bytearray([0 for i in range(bytes_num)])  # bytes shifting
    output_array.extend(b_array)
    if modulo_bits != 0: 
        output_array.append(0)
        prev = 0
        for i in range(len(b_array)+1):
            if i < len(b_array):
                output_array[i+bytes_num] = (b_array[i] >> modulo_bits) + prev
                prev = (b_array[i] & bitwise_masks[modulo_bits]) << (8 - modulo_bits)
            else:
                output_array[i+bytes_num] = prev

    return output_array

def add_arrays(arr1, arr2):

    if len(arr1) > len(arr2):
        length = len(arr1)
    else:
        length = len(arr2)
    output_array = bytearray([0 for i in range(length)])
    for i in range(length):
        if i < len(arr1) and i < len(arr2):
            output_array[i] = arr1[i] + arr2[i]
        elif i >= len(arr2) and i < len(arr1):
            output_array[i] = arr1[i]
        elif i >= len(arr1) and i < len(arr2):
            output_array[i] = arr2[i]

    return output_array

def concat(arr1, length1, arr2, length2): #length in bits
    output = add_arrays(arr1, shiftbybits(arr2, length1))
    
    length = length1 + length2
    return output, length


length = 12
scan_data = bytearray([240, 160])
length_2 = 6
scan_data2 = bytearray([40])

#output = concat(scan_data,length,scan_data2,length_2)
# output = shiftbybits(scan_data2, 4)
# for element in output:
#     print(element, end = ', ')

import serial
    
esp = serial.Serial("/dev/ttyUSB0", 115200 , timeout = None)
data = []
scan_data = bytearray([0])
scan_data_length = 0
i = 0
while True:
    if esp.in_waiting:
        data = esp.readline()
    else:
        break
i = 0
k = 0
import time
while True:
    if esp.in_waiting:
        
        data = esp.readline().decode()
        data = data.split(" ")[:-1]
        
        length = int(data[0]) * 256 + int(data[1])
        data = data[2:]
        new_data = bytearray()
        
        for b in data:
            if int(b) == 0xff:
                new_data.append(int(b))
                new_data.append(0)
                length += 8
            else:
                new_data.append(int(b))
        
        scan_data, scan_data_length = concat(scan_data, scan_data_length, new_data, length)
        print(scan_data, scan_data_length)
        i = 0
    else:
        if i == 5:
            break
        else:
            i+= 1
            
            time.sleep(1)
# scan_data, length = concat(bytearray([239,255,0, 200, 160]), 40, bytearray([0]), 4)
# print(scan_data, length)
# scan_data, length = concat(scan_data, length, bytearray([240, 10, 0]), 24)
# print(scan_data, length)

jpeg_header.extend(scan_data)
jpeg_header.extend(bytearray([0xFF, 0xD9]))
# print(jpeg_header)

with open("/home/madjid/Desktop/jpeg_file_from_fpga.jpg","wb") as f:
    f.write(jpeg_header)
