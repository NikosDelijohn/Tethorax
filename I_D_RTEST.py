# This file is used to generate the spaghetti code needed 

outfile = open("R-COMMANDS2.txt", "w")

FUNCT7 = '0000000'
FUNCT72= '0100000'
RS2    = '00100'
RS1    = '00010'
FUNCT3 = ['000','001','010','011','100','101','110','111']
RD     = '00001'
OPCODE = '0110011'

outfile.write(FUNCT7+RS2+RS1+FUNCT3[0]+RD+OPCODE+'\n')
outfile.write(FUNCT72+RS2+RS1+FUNCT3[0]+RD+OPCODE+'\n')

for i in range(1,6):

	outfile.write(FUNCT7+RS2+RS1+FUNCT3[i]+RD+OPCODE+'\n')

outfile.write(FUNCT72+RS2+RS1+FUNCT3[5]+RD+OPCODE+'\n')
outfile.write(FUNCT7+RS2+RS1+FUNCT3[6]+RD+OPCODE+'\n')
outfile.write(FUNCT7+RS2+RS1+FUNCT3[7]+RD+OPCODE+'\n')

outfile.close()