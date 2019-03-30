import sys
from colorama import init
from colorama import Fore,Back,Style

init()

##margin_a = 7
##margin_b = 

def gen_line(file):

	for line in file:
		yield line
		
def parse(file1,file2):
	
	file2.write(" WIDTH = 32; \n DEPTH = 128; \n ADDRESS_RADIX = UNS; \n DATA_RADIX = HEX; \n\nCONTENT BEGIN \n")
	
	for i in range(0,36):
	
		temp = str(next(gen_line(file1)))
		file2.write( "\t" + str(i) + "   : " + temp[:-1] + ";\n")
		
	file2.write("\t [36..127] : 00\nEND;")
	file2.close()


def main():
	try:
	
		if (len(sys.argv) != 2):
		
			raise IndexError
		
		hex_file_name = str(sys.argv[1])
		mif_file_name = "INSTRUCTION_CACHE.mif"
		
		infile  = open(hex_file_name,"r")
		outfile = open(mif_file_name,"w")
		
		parse(infile,outfile)
		
		
		
		
	except IndexError:
		
		print( Fore.RED + "Usage \"python hex_to_mif.py <.hex filename>\"")
		
	except IOError:
	
		print( Fore.RED + "File \"" + sys.argv[1] + "\" not found")
		
if __name__ == '__main__':

	main()