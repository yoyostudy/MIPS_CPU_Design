import data_parser as dp
import os

def bin2int(str_bin):
    value = 0
    for str in str_bin:
        if str == '1':
            value = value * 2 + 1
        else:
            value = value * 2
    return value

def to_unsigned(signed_int):
    if signed_int >= 0:
        value = signed_int
    else:
        value = signed_int + (2**32)
    return value

class ComputerExit(Exception):
    pass

class Computer:

    #####################################################
    ## 0. Computer Simulator
    ##   0.1. Memory
    ##   0.2. Registors:  32 general registers, PC, HI, LO
    ######################################################

    def __init__(self):
    
        ## 0.1. Memory        
        self.memory = [0]* 0x600000
        
        ## 0.1.1. load .data in memory
        data_lines = dp.set_data(INPUT_file)
        self.data_idx = 0x100000
        self.load_data(data_lines)
        
        ## 0.1.2. load .text in memory
        self.text_idx = 0x000000
        self.load_text(text_file)
        
        #self.start_of_text_segment = 0x400000
        #self.start_of_dynamic_memory = 0
        #self.start_of_data = 0x500000

        ## 0.2. Registors
        self.registers = [0]*32   ## all registers store 32-bit value
        self.pc = 0x000000
        self.hi = 0
        self.lo = 0
        self.registers[28] = 0x108000  ## $gp = 0x508000
        self.registers[29] = 0x600000  ## $sp = 0xA00000
        self.registers[30] = 0x600000  ## $fp = 0xA00000
        
        
        ## 0.3. dump checkpts
        self.checkpts = []
        f = open(checkpts_file,'r')
        while True:
            line = f.readline()[:-1]
            if not line:
                break
            self.checkpts.append(int(line))
        f.close()
            
        ## 0.4. .in file read_in_list
        self.listin = []
        f_in = open(in_file,'r')
        while True:
            e_in = f_in.readline()
            if not e_in:
                break
            self.listin.append(e_in)
        f_in.close()
        self.listin = self.listin[::-1]
            
    def parse_line(self, line):
        tokens = line.split()
        if tokens[0] == ".byte":
            values = tokens[1].split(",")
            values =  [int(value) for value in values]
            for value in values:
                self.memory[self.data_idx] = value
                self.data_idx += 1
        elif tokens[0] == ".half":
            values = tokens[1].split(",")
            values =  [int(value) for value in values]
            for value in values:
                if self.data_idx % 2 != 0:
                    self.data_idx += 2 - self.data_idx% 2
                self.memory[self.data_idx] = value & (2**8 - 1)
                self.memory[self.data_idx+1]= value >> 8
                self.data_idx += 2
        elif tokens[0] == ".word":
            value = int(tokens[1])
            if self.data_idx % 4 != 0:
                self.data_idx += 4 - self.data_idx % 4
            self.memory[self.data_idx]= value & (2**8 - 1)
            self.memory[self.data_idx+1] = (value >> 8) & (2**8 - 1)
            self.memory[self.data_idx+2] = (value >> 16) & (2**8 - 1)
            self.memory[self.data_idx+3] = (value >> 24) & (2**8 - 1)
            self.data_idx += 4
        elif tokens[0] == ".ascii":
            quotation_index = line.index('"')
            result = ''
            backslash = False
            for i in range(quotation_index + 1, len(line)):
                c = line[i]
                if backslash:
                    if c == '"':
                        result += '"'
                    elif c == '\\':
                        result += '\\'
                    elif c == 'n':
                        result += '\n'
                    backslash = False
                else:
                    if c == '"':
                        break
                    elif c == '\\':
                        backslash = True
                    else:
                        result += c
            for c in result:
                self.memory[self.data_idx] = ord(c)
                self.data_idx += 1
            while self.data_idx % 4 != 0:
                self.data_idx +=1
        elif tokens[0] == ".asciiz":
            quotation_index = line.index('"')
            result = ''
            backslash = False
            for i in range(quotation_index + 1, len(line)):
                c = line[i]
                if backslash:
                    if c == '"':
                        result += '"'
                    elif c == '\\':
                        result += '\\'
                    elif c == 'n':
                        result += '\n'
                    backslash = False
                else:
                    if c == '"':
                        break
                    elif c == '\\':
                        backslash = True
                    else:
                        result += c
            result += '\0'
            for c in result:
                self.memory[self.data_idx] = ord(c)
                self.data_idx += 1
            while self.data_idx % 4 != 0:
                self.data_idx +=1
        else:
            colon_index = line.index(':')
            new_line = line[colon_index + 1 : ]
            new_tokens = new_line.split()
            if len(new_tokens) == 0:
                pass
            else:
                self.parse_line(new_line)

    def load_data(self, data_lines):
        '''
            load the .data
            store in the memory
            data_types:
                '.ascii'             Big-Endian
                '.asciiz'            Big-Endian
                '.word'    4 byte    Little-Endian
                '.byte'    1 byte    Little-Endian
                '.half'    2 byte    Little-Endian
        '''
        for line in data_lines:
            self.parse_line(line)
                    
    def load_text(self, text_file):
        '''
            load the machine code of .text file obtained from project1
            Little-Endian
        '''
        f = open(text_file,'r')
        instr = f.readline()
        instr = instr[:-1]
        while instr:
            if instr != '':
                int_instr = bin2int(instr)
                self.memory[self.text_idx]   = (int_instr)       & ( 2**8 -1)
                self.memory[self.text_idx+1] = (int_instr >> 8)  & ( 2**8 -1)
                self.memory[self.text_idx+2] = (int_instr >> 16) & ( 2**8 -1)
                self.memory[self.text_idx+3] = (int_instr >> 24) & ( 2**8 -1)
                self.text_idx += 4
            else:
                pass
            instr = f.readline()
            instr = instr[:-1]
        f.close()
        
    def dump(self,x):
        file_memory = open(f'memory{x}.bin','wb')
        file_registers = open(f'registers{x}.bin','wb')
        for reg in self.registers:
            file_registers.write(reg.to_bytes(4, byteorder="little") )
        file_registers.write(self.pc.to_bytes(4, byteorder="little") )
        file_registers.write(self.hi.to_bytes(4, byteorder="little") )
        file_registers.write(self.lo.to_bytes(4, byteorder="little") )
        for num in self.memory:
            file_memory.write(num.to_bytes(1, byteorder="little") )
        file_memory.close()
        file_registers.close()
        
    def run(self):
        i = 0
        while True:
            if i in self.checkpts:
                self.dump(i)
            i += 1
            pc = self.pc
            #print(pc)
            print(self.registers[31])
            self.pc += 4
            instr = self.memory[pc]+ self.memory[pc+1]*(2**8) + self.memory[pc+2]*(2**16) + self.memory[pc+3]* (2**24)
            opcode = instr >> 26
            rs = (instr >> 21) & (2**5 -1)
            rt = (instr >> 16) & (2**5 -1)
            rd = (instr >> 11) & (2**5 -1)
            sa = (instr >> 6)  & (2**5 -1)
            func = instr & (2**6-1)
            imm = instr & (2**16-1)
            if (imm >> 15):
                imm = imm - (2**16)
            target = instr & (2**26-1)
            ## address = sign_extended(offset) + registers[base]

            ## I-type
            if opcode == 0b001000:
                self.addi(rs,rt,imm)
            elif opcode == 0b001001:
                self.addiu(rs,rt,imm)
            elif opcode == 0b001100:
                self.andi(rs,rt,imm)
            elif opcode == 0b000100:
                self.beq(rs,rt,imm)   ##?? label
            elif opcode == 0b000001:
                if rt == 0b00001:
                    self.bgez(rs,imm)
                elif rt == 0b00000:
                    self.bltz(rs,imm)
            elif opcode == 0b000111:
                self.bgtz(rs,imm)
            elif opcode == 0b000110:
                self.blez(rs,imm)
            elif opcode == 0b000101:
                self.bne(rs,rt,imm)
            elif opcode == 0b100000:
                self.lb(rs,rt,imm)
            elif opcode == 0b100100:
                self.lbu(rs,rt,imm)
            elif opcode == 0b100001:
                self.lh(rs,rt,imm)
            elif opcode == 0b100101:
                self.lhu(rs,rt,imm)
            elif opcode == 0b001111:
                self.lui(rt,imm)
            elif opcode == 0b100011:
                self.lw(rs,rt,imm)
            elif opcode == 0b001101:
                self.ori(rs,rt,imm)
            elif opcode == 0b101000:
                self.sb(rs,rt,imm)
            elif opcode == 0b001010:
                self.slti(rs,rt,imm)
            elif opcode == 0b001011:
                self.sltiu(rs,rt,imm)
            elif opcode == 0b101001:
                self.sh(rs,rt,imm)
            elif opcode == 0b101011:
                self.sw(rs,rt,imm)
            elif opcode == 0b001110:
                self.xori(rs,rt,imm)
            elif opcode == 0b100010:
                self.lwl(rs,rt,imm)
            elif opcode == 0b100110:
                self.lwr(rs,rt,imm)
            elif opcode == 0b101010:
                self.swl(rs,rt,imm)
            elif opcode == 0b101110:
                self.swr(rs,rt,imm)
            ## J-type
            elif opcode == 0b000010:
                self.j(target)
            elif opcode == 0b000011:
                self.jal(target)
            ## R-type
            elif opcode == 0b000000:
                if func == 0b100000:
                    self.add(rs,rt,rd)
                elif func == 0b100001:
                    self.addu(rs,rt,rd)
                elif func == 0b100100:
                    self.and_(rs,rt,rd)  ## and_
                elif func == 0b011010:
                    self.div(rs,rt)
                elif func == 0b011011:
                    self.divu(rs,rt)
                elif func == 0b001001:
                    self.jalr(rs,rd)
                elif func == 0b001000:
                    self.jr(rs)
                elif func == 0b010000:
                    self.mfhi(rd)
                elif func == 0b010010:
                    self.mflo(rd)
                elif func == 0b010001:
                    self.mthi(rd)
                elif func == 0b010011:
                    self.mtlo(rd)
                elif func == 0b011000:
                    self.mult(rd)
                elif func == 0b011001:
                    self.multu(rd)
                elif func == 0b100111:
                    self.nor(rs,rt,rd)
                elif func == 0b100101:  # or_
                    self.or_(rs,rt,rd)
                elif func == 0b000000:
                    self.sll(rt,rd,sa)
                elif func == 0b000100:
                    self.sllv(rs,rt,rd)
                elif func == 0b101010:
                    self.slt(rs,rt,rd)
                elif func == 0b101011:
                    self.sltu(rs,rt,rd)
                elif func == 0b000011:
                    self.sra(rt,rd,sa)
                elif func == 0b000111:
                    self.srav(rs,rt,rd)
                elif func == 0b000010:
                    self.srl(rt,rd,sa)
                elif func == 0b000110:
                    self.srlv(rs,rt,rd)
                elif func == 0b100010:
                    self.sub(rs,rt,rd)
                elif func == 0b100011:
                    self.subu(rs,rt,rd) 
                elif func == 0b001100:  ## syscall
                    self.syscall()
                elif func == 0b100110:  
                    self.xor(rs,rt,rd)

    ####################################
    ##  Insturction function definition    
    ####################################

    ####################################
    ## 0. Logic Instructions
    ## 0.1 R-type 
    
    def and_(self,rs,rt,rd):
        '''
            bitwise and
            rd <-- AND(rs,rt)
        '''
        self.registers[rd] = (self.registers[rs]) & (self.registers[rt])
    
    def nor(self,rs,rt,rd):
        '''
            rd <- NOR(rs,rt)
            NOR = ~(rs|rt)
        '''
        self.registers[rd] = (~ (self.registers[rs] | self.registers[rt]) ) & (2**32-1)        

    def or_(self,rs,rt,rd):
        '''
        rd <- OR(rs,rt)
        '''
        self.registers[rd] = (self.registers[rs] | self.registers[rt])  & (2**32-1)        

    def xor(self,rs,rt,rd):
        '''
        rd <- XOR(rs,rt)
        '''
        self.registers[rd] = (self.registers[rs] ^ self.registers[rt])  & (2**32-1)        
    
    
    ## 0.2. I-type

    def andi(self,rs,rt,imm):
        '''
            bitwise AND immediate
            rt <-- AND(rs,zero-extended(imm))
        '''
        zero_imm = to_unsigned(imm)
        self.registers[rt] = (self.registers[rs] ) & (zero_imm)
    
    def ori(self,rs,rt,imm):
        '''
            bitwise or immediate
            rt <-- OR(rs,zero-extended(imm))
        '''
        zero_imm = to_unsigned(imm)
        self.registers[rt] = ((self.registers[rs] ) | (zero_imm)) & (2**32 -1)

    def xori(self,rs,rt,imm):   
        '''
            bitwise xor immediate
            rt <-- XOR(rs,zero-extended(imm))
        '''
        zero_imm = to_unsigned(imm)
        self.registers[rt] = (~ ((self.registers[rs] ) | (zero_imm))) & (2**32 -1) 
    

    ####################################
    ## 1. Arithemetic Instructions
    ## 1.1 R-type

    def add(self,rs,rt,rd):
        '''
            addition with (checking) overflow [-2^31,2^31-1]
            rd <- rs+rt
        '''
        temp = self.registers[rs] + self.registers[rt]
        if (temp >= (-1)* (2**31) ) and ( temp <= (2**31-1)):
            self.registers[rd] = temp        
        else:
            print("Error: add func overflow")

    def addu(self,rs,rt,rd):
        '''
            addition without (checking) overflow
            rd <- rs+rt
        '''
        self.registers[rd] = (self.registers[rs] + self.registers[rt]) & (2**32-1)

    def sub(self,rs,rt,rd):
        '''
            subtract (with overflow)
            rd <-- rs-rt
        '''
        temp = self.registers[rs] - self.registers[rt]
        if (temp >= (-1)* (2**31) ) and ( temp <= (2**31-1)):
            self.registers[rd] = temp        
        else:
            print("Error: sub func overflow")

    def subu(self,rs,rt,rd):
        '''
            subtract (without overflow)
            rd <-- rs-rt
        '''
        self.registers[rd] = (self.registers[rs] - self.registers[rt]) & (2**32-1)

    def div(self,rs,rt):
        '''
            divide signed
            rs/rt = quotient + remainder
            register l0 <-- quotient
            register hi <-- remainder
        '''
        quotient = self.registers[rs] // self.registers[rt]
        remainder = self.registers[rs] % self.registers[rt]
        self.lo = quotient
        self.hi = remainder

    def divu(self,rs,rt):
        '''
            divide unsigned
            rs/rt = quotient + remainder
            register l0 <-- quotient
            register hi <-- remainder
        '''
        quotient = to_unsigned(self.registers[rs]) // to_unsigned(self.registers[rt])
        remainder = to_unsigned(self.registers[rs]) % to_unsigned(self.registers[rt])
        self.lo = quotient
        self.hi = remainder

    def mult(self,rs,rt):
        '''
            {hi,lo} <-- rs * rt
            hi <-- high 32 bit
            lo <-- low  32 bit
            signed
        '''
        temp = self.registers[rs] * self.registers[rt]
        self.lo = temp & (2**32-1)
        self.hi = (temp >> 32) & (2**32-1)  

    def multu(self,rs,rt):
        '''
            {hi,lo} <-- rs * rt
            hi <-- high 32 bit
            lo <-- low  32 bit
            unsigned
        '''
        temp = to_unsigned(self.registers[rs]) * to_unsigned(self.registers[rt])
        self.lo = temp & (2**32-1)
        self.hi = (temp >> 32) & (2**32-1)  
 
       
    ## 1.2 I-type 
    
    def addi(self,rs,rt,imm):
        '''
        add sign_extended immediate (with overflow)
        overflow is outside [-2^31,2^31-1]
        imm(16 bit) sign-extended to 32 bit
        '''
        temp = self.registers[rs] + imm
        self.registers[rt] = temp

    def addiu(self,rs,rt,imm):
        '''
        add sign_extended immediate unsigned(no overflow) 
        '''
        self.register[rt] = (self.registers[rs]+imm) & (2**32-1)

    ####################################
    ## 2. Comparison Instructions
    ## 2.1 R-type 

    def slt(self,rs,rt,rd):
        '''
        set less than signed operand
        slt rd,rs,rt
        set register rd to 1 if register rs is less than rt
        and to 0 otherwise
        '''
        if (self.registers[rs]<self.registers[rt]):
            self.registers[rd] = 1
        else:
            self.registers[rd] = 0
    

    def sltu(self,rs,rt,rd):
        '''
        set less than unsigned
        set register rd to 1 if register rs is less than rt
        and to 0 otherwise
        '''
        if to_unsigned(self.registers[rs]) < to_unsigned(self.registers[rt]):
            self.registers[rd] = 1
        else:
            self.registers[rd] = 0
    
    ## 2.2 I-type

    def slti(self,rs,rt,imm):
        '''
        set less than immediate 
        slti rt,rs,imm
        set register rt to 1 if (signed) register rs is less than 
        sign-extended immediate, and to 0 otherwise
        rt ←（rs <（sign_extended）immediate）
        '''
        if (self.registers[rs]< imm):
            self.registers[rt] = 1
        else:
            self.registers[rt] = 0

    def sltiu(self,rs,rt,imm):
        '''
        set less than unsigned immediate
        slti rt,rs,imm
        set register rt to 1 if (unsigned) register rs is less than 
        sign-extended immediate, and to 0 otherwise
        '''
        if (to_unsigned(self.registers[rs])< to_unsigned(imm)):
            self.registers[rt] = 1
        else:
            self.registers[rt] = 0
        

    ####################################
    ## 3. Jump Instructions
    ## 3.1 R-type 

    def jalr(self,rs,rd):
        '''
            unconditionally jump to the instruction 
                whose address is in register rs
            Save the next instruction in register rd (defaul to be 31)
            pc <-- address in rs
            rd <-- address in rs + 8
        '''
        address = self.registers[rs]
        self.pc = address
        if rd == 0:
            rd = 31
        self.registers[rd] = address + 8

    def jr(self,rs):
        '''
            unconditionally jump to the instruction 
                whose address is in register rs
            pc <-- rs
        '''
        self.pc = self.registers[rs]
    
    ## 3.2 J-type

    def j(self,target):
        '''
            unconditionally jump to the instruction at target
            pc <-- (pc+4)[31,28] || target || 00
            note that self.pc is already incremented by 4
        '''
        self.pc = (target << 2) + (self.pc) & (2**32-2**28) - 0x400000
        
    def jal(self,target):
        '''
            unconditionally jump to the instruction at target
            save the address of the next instruction in register $ra (31)
            pc <-- (pc+4)[31,28] || target ||'00'
            $ra(31) <-- pc + 8
        '''
        pc = self.pc
        self.pc = (target << 2) + (pc & (2**32-2**28)) - 0x400000
        self.registers[31] = self.pc + 4
    
    ####################################
    ## 4. Branch Instructions
    ## 4.1 I-type    
    ## brach_address =(sign_extend) (offset || '00') + (pc+4)
    
    def beq(self,rs,rt,imm):
        '''
            Conditionally branch the number of instructions 
            if rs = rt
        '''
        brach_address = (imm << 2) + (self.pc)
        if self.registers[rs] == self.registers[rt]:
            self.pc = brach_address

    def bgez(self,rs,imm):
        '''
        conditionally branch the number of instructions specified 
        by the offset if rs >= 0
        '''
        brach_address = (imm << 2) + (self.pc)
        if self.registers[rs] >= 0:
            self.pc = brach_address

    def bltz(self,rs,imm):
        '''
        conditionally branch the number of instructions specified 
        by the offset if rs < 0
        '''
        brach_address = (imm << 2) + (self.pc)
        if self.registers[rs] < 0:
            self.pc = brach_address

    def bgtz(self,rs,imm):
        '''
        conditionally branch the number of instructions specified 
        by the offset if rs > 0
        '''
        brach_address = (imm << 2) + (self.pc)
        if self.registers[rs] > 0:
            self.pc = brach_address
    
    def blez(self,rs,imm):
        '''
        conditionally branch the number of instructions specified 
        by the offset if rs <= 0
        '''
        brach_address = (imm << 2) + (self.pc)
        if self.registers[rs] <= 0:
            self.pc = brach_address
    
    def bne(self,rs,rt,imm):
        '''
        conditionally branch the number of instructions specified 
        by the offset if rs is not equal to rt
        '''
        brach_address = (imm << 2) + (self.pc)
        if self.registers[rs] != self.registers[rt]:
            self.pc = brach_address
    
   
    ####################################
    ## 5. Data Movements Instructions
    ## 5.1 R-type 

    def mfhi(self,rd):
        '''
        move from high
        rd <-- hi
        '''
        self.registers[rd] = self.hi
    
    def mflo(self,rd):
        '''
        move from low
        rd <-- lo
        '''
        self.registers[rd] = self.lo
        
    def mthi(self,rs):
        '''
        move to high
        hi <- rs
        '''
        self.hi = self.registers[rs]

    def mtlo(self,rs):
        '''
        move to low
        lo <- rs
        '''
        self.lo = self.registers[rs]
    
    ####################################
    ## 6. Load Instructions
    ## 6.1 I-type 
    ##      imm = offset, rs = base
    ##      load_address = sign_extended(offset) + registers[base]

    def lb(self,rs,rt,imm):
        '''
            lb rt, offset()
            load byte : load the byte at the address into register rt
                        the byte is sign-extended
            rt <- byte from load_address_signed
        '''
        load_address= imm + self.registers[rs] 
        self.registers[rt] = self.memory[load_address]

    def lbu(self,rs,rt,imm):
        '''
            lbu rt, addrss
            load byte unsigned : load the byte at address into register rt
                                 the byte is zero-extended  
                                 0....0 [24] || byte                            
        '''
        load_address= imm + self.registers[rs] 
        self.registers[rt] = to_unsigned(self.memory[load_address ])

    def lh(self,rs,rt,imm):
        '''
            lh rt, address
            load half word: load the 16-bit(2 byte) quantity(halfword) 
                            at address sign_extended into register rt
        '''
        load_address= imm + self.registers[rs] 
        if load_address %2 != 0:
            print("Error: load half word address did not align")
        else:
            self.registers[rt] = self.memory[load_address ] + self.memory[load_address+1 ]*(2**8)

    def lhu(self,rs,rt,imm):
        '''
            lhu rt, address
            load half word: load the 16-bit(2 byte) quantity(halfword) 
                            at address zero_extended into register rt
        '''
        load_address= imm + self.registers[rs]
        if load_address %2 != 0:
            print("Error: load half word address did not align")
        else:
            self.registers[rt] = to_unsigned(self.memory[load_address] + self.memory[load_address+1 ]*(2**8))

    def lw(self,rs,rt,imm):
        '''
            lw rt, address
            load word: 
                load the 32-bit(4 byte) quantity(word) 
                at address into register rt
        '''
        load_address= imm + self.registers[rs]  
        if load_address % 4 != 0:
            print("Error: load word addressdid not align")
        self.registers[rt] = self.memory[load_address ] + self.memory[load_address+1 ]*(2**8) + self.memory[load_address+2 ]*(2**16-1) + self.memory[load_address+3]*(2**24-1)

    def lwl(self,rs,rt,imm):
        '''
            load word left 
            load the left bytes from the word at the possibly unaligned 
            address into register rt
        '''
        load_address= imm + self.registers[rs]   
        n = load_address % 4
        self.registers[rt] = 0
        for i in range(4-n):
            self.registers[rt] += self.memory[load_address + i ] << (24 - 8*i)

    def lwr(self,rs,rt,imm):
        '''
            load word right
            load the right bytes from the word at the possibly unaligned 
            address into register rt
        '''
        load_address= imm + self.registers[rs]   
        n = load_address % 4
        self.registers[rt] = 0
        for i in range(n+1):
            self.registers[rt] += self.memory[load_address - i] << (8*i)

    def lui(self,rt,imm):
        '''
            lui rt, address
            load upper immediate
            load the lower halfword of the immediate imm into the 
            upper halfword of register rt.
            The lowe bits of the register are set to 0
        '''
        self.registers[rt] = (imm << 16 )

    ####################################
    ## 7. Store Instructions
    ## 7.1 I-type  
    ##      imm = offset, rs = base
    ##      store_address = sign_extended(offset) + registers[base] 

    def sb(self,rs,rt,imm):
        '''
        store byte:
            sb rt address
            store the low byte(8-bit) from register rt at address
        '''
        store_address= imm + self.registers[rs]  
        low_byte = self.registers[rt] & (2**8-1)
        self.memory[store_address ] = low_byte

    def sh(self,rs,rt,imm):
        '''
        store halfword:
            sh rt address
            store the low halfword(16-bit) from register rt at address
        '''
        store_address= imm + self.registers[rs]  
        byte_1 = self.registers[rt] & (2**8-1)
        byte_2 = self.registers[rt] & (2**16-2**8)
        if store_address %2 != 0:
            print("Error: store half word address is not aligned")
        else:
            self.memory[store_address] = byte_1
            self.memory[store_address+1 ] = byte_2

    def sw(self,rs,rt,imm):
        '''
        store word:
            sw rt，offset（rs）
            sw rt address
            store the low word(32 bit) from register rt at address
        '''
        store_address= imm + self.registers[rs]
        byte_1 = self.registers[rt] & (2**8-1)
        byte_2 = self.registers[rt] & (2**16-2**8)
        byte_3 = self.registers[rt] & (2**24-2**16)
        byte_4 = self.registers[rt] & (2**32-2**24)
        if store_address %4 != 0:
            print("Error: store word address is not aligned")
        else:
            self.memory[store_address  ] = byte_1
            self.memory[store_address+1 ] = byte_2
            self.memory[store_address+2 ] = byte_3
            self.memory[store_address+3 ] = byte_4
    
    def swl(self,rs,rt,imm):
        '''
        store word left:
            swl rt address
            store the left bytes (higher) from register rt 
            at the possibly unaligned address
        '''
        store_address= imm + self.registers[rs] 
        n  = store_address % 4
        for i in range(4-n):
            self.memory[store_address+i ] = (self.registers[rt] << 24-8*i )&(2**8-1)

    def swr(self,rs,rt,imm):
        '''
        store word right:
            swr rt address
            store the right bytes(lower) from register rt at the possibly unaligned address
        '''
        store_address= imm + self.registers[rs]
        n  = store_address % 4
        for i in range(n+1):
            self.memory[store_address-i  ] = (self.registers[rt] << 8*i )&(2**8-1)

    ####################################
    ## 8. Shift Instructions
    ## 8.1 R-type 

    def sll(self,rt,rd,sa):
        '''
        rd <-- rt << sa
        '''
        self.registers[rd] = self.registers[rt] << sa

    def sllv(self,rs,rt,rd):
        '''
        shift left logical variable
        rd <-- rt << rs[4:0]
        '''
        sa = self.registers[rs] & (2**4-1)
        self.registers[rd] = self.registers[rt] << sa        

    def sra(self,rt,rd,sa):
        '''
        shift right arithmetic
        rd <- rt >> sa (arithmetic)
        extend with r[31]
        '''
        self.registers[rd] = ( self.registers[rt] << sa ) + (self.registers[31] & (2**sa-1)) 
        
    def srav(self,rs,rt,rd):
        '''
        shift right arithmetic variable
        rd <- rt >> rs[4:0] (arithemetic)
        extend with r[31]
        '''
        sa = self.registers[rs] & (2**4-1)
        self.registers[rd] = ( self.registers[rt] << sa ) + (self.registers[31] & (2**sa-1)) 

    def srl(self,rt,rd,sa):
        '''
        shift right logical
        rd <- rt >> sa(logic)
        '''
        self.registers[rd] = self.registers[rt] >> sa

    def srlv(self,rs,rt,rd):
        '''
        shift right logical variable
        rd<-- rt << rs[4:0] (logic)
        '''
        sa = self.registers[rs] & (2**4-1)
        self.registers[rd] = self.registers[rt] >> sa  
        
    ####################################
    ## 9. Syscall Instructions
    ## 9.1 R-type 
    
    def syscall(self):
        syscall_code = self.registers[2]  
        '''
        for syscalls 1,4,11, 
            print the argument in the .out file one line at a time
            print(argu)
        for syscalls 5,8,12,    
            read from .in file one line at a time   
            v0 <- input
        for syscalls 10,13,14,15,16,17
            simulate by directly invoking the Linux APIs

        '''
        if syscall_code == 1:    ## print_int  argu : $a0 (int) 
            argu = self.registers[4]
            with open(out_file,'a+') as f:
                f.write('{}'.format(argu))
            ##print(int(argu), end='')
        elif syscall_code == 4:  ## print_string argu: $a0 (string) 
            argu = self.registers[4] 
            while self.memory[argu ] != 0:
                with open(out_file,'a+') as f:
                    f.write('{}'.format( chr(self.memory[argu]) ))
                argu += 1
        elif syscall_code == 11:  ## print_char argu: $a0 (char)
            argu = self.registers[4]  
            with open(out_file,'a+') as f:
                f.write('{}'.format( chr(self.memory[argu ]) ))
        elif syscall_code == 5:  ## read_int  $v0 <- intput(int)
            ##int_input = input()
            if len(self.listin) >0:
                int_input = self.listin.pop()
                self.registers[2] = int(int_input)
            else:
                raise ComputerExit
        elif syscall_code == 8:  ## read_string $a0 buffer, $a1 length
            str_input = input()
            buffer = self.registers[4]
            length = self.registers[5]
            for i in range(length):
                self.memory[buffer] = ord(str_input[i])
                buffer += 1
        elif syscall_code == 12:  ## read_char $v0 <- input(char)
            char_input = input()
            self.registers[2] = ord(char_input)
        
        elif syscall_code == 10:  ## exit
            raise ComputerExit()

        elif syscall_code == 13:  ## open $a0 = filename(str) $a1 = flags $a2 = mode  file descriptor(in $a0)
            pass

        elif syscall_code == 14:  ## read
            pass

        elif syscall_code == 15:  ## write
            pass

        elif syscall_code == 16:  ## close
            pass

        elif syscall_code == 17:  ## exit2
            raise ComputerExit()

        elif syscall_code == 9:  ## sbrk
            amount = self.registers[4]
            self.registers[2] = self.start_of_dynamic_memory
            self.start_of_dynamic_memory += amount
    
    
if __name__ ==  "__main__":
    x = 'fib'
    INPUT_file = '{}.asm'.format(x)
    in_file = '{}.in'.format(x)
    text_file = '{}.txt'.format(x)
    checkpts_file = '{}_checkpts.txt'.format(x)
    out_file = '{}.out'.format(x)
    open(out_file, 'w').close()
    computer = Computer()
    try:
        #computer.addi(29,29,-2)
        #print(computer.registers[29])
        computer.run()
    except ComputerExit:
        pass



