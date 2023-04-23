def set_data(INPUT_file):
    all_lines = []
    flag = 0
    for line in open(INPUT_file):
        if (line.find(".data")!= -1):
            flag = 0
        elif (line.find(".text")!= -1):
            flag = 1
        elif flag == 0:
            if (line.find('#') > 0):
                line = line[0:line.find('#')-1]
            elif (line.find('#') == 0):
                line = '\n'
            if line != '\n':
                line = line[:-1]
                line = line.strip()
                all_lines.append(line)
    return all_lines
                



        
"""
SAMPLE OUTPUT
data_lines = ['FIB_START: .asciiz "fib("',
                'FIB_MID: .asciiz ") = "',
                'LINE_END: .asciiz "\\n"',
                '''.ascii "hello\" \\world"''',
                "label: .byte 1",
                "label2 :   ",
                "label3:",
                ".word 3",
"""
