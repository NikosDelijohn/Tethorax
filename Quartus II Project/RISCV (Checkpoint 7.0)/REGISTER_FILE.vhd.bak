-- +===========================================================+
-- |			RISC-V RV32I(M) ISA IMPLEMENTATION  	       |
-- |===========================================================|
-- |student:    Deligiannis Nikos							   |
-- |supervisor: Aristides Efthymiou						       |
-- |===========================================================|
-- |			    UNIVERSITY OF IOANNINA - 2019 			   |
-- |  					 VCAS LABORATORY 					   |
-- +===========================================================+

-- *** 2/5: INSTRUCTION DECODE (ID) MODULE DESIGN ***
------------------------------------------------------------
-- PART#3: REGISTER FILE
-- " The system's register file which has a total of 32 regs.  
--   These registers are casual registers with parrarel load
--   function. Except register #0. Register #0 is hardwired
--   to GND and its value cannot be changed. They all are
--   32 bit (XLEN) wide. "
------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.TOOLBOX.ALL;

ENTITY REGISTER_FILE IS 

	PORT ( 
			CLK,RST  : IN  STD_LOGIC;
			LOAD_REG : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			DATA_IN  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		    ADDR_RS1 : IN  STD_LOGIC_VECTOR(4  DOWNTO 0);
			ADDR_RS2 : IN  STD_LOGIC_VECTOR(4  DOWNTO 0) := NULL;
			DATA_RS1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			DATA_RS2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := NULL
		 );
		 
END REGISTER_FILE;

ARCHITECTURE STRUCTURAL OF REGISTER_FILE IS
	
	TYPE MATRIX_2D IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL BUF_OF_BUFFERS : MATRIX_2D;
	SIGNAL BUF_RS1_MUX    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BUF_RS2_MUX    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	BEGIN 
	
		GEN: FOR I IN 0 TO 31 GENERATE 
		
			CASE0: IF I = 0 GENERATE
				   
				   ZERO_REG: REG_32B_ZERO
							 PORT MAP( 
									   CLK => CLK,
									   Q_OUT => BUF_OF_BUFFERS(I)
							         );
			END GENERATE CASE0;
							         
			CASE1: IF I > 0 AND I <= 31 GENERATE
				   
				   CASUALS:  REG_32B_CASUAL
							 PORT MAP(
										LOAD  => LOAD_REG(I),
										CLK   => CLK,
										RST   => RST,
										DATA  => DATA_IN,
										Q_OUT => BUF_OF_BUFFERS(I)
									 );
			END GENERATE CASE1;
			
			
		END GENERATE;
		
		RS1_MUX: MUX32X1 
				 GENERIC MAP( INSIZE => DATA_IN'LENGTH )
				 PORT    MAP(
									BUF_OF_BUFFERS(0) ,BUF_OF_BUFFERS(1) ,BUF_OF_BUFFERS(2) ,BUF_OF_BUFFERS(3) ,BUF_OF_BUFFERS(4) ,BUF_OF_BUFFERS(5) ,BUF_OF_BUFFERS(6) ,BUF_OF_BUFFERS(7) ,
									BUF_OF_BUFFERS(8) ,BUF_OF_BUFFERS(9) ,BUF_OF_BUFFERS(10),BUF_OF_BUFFERS(11),BUF_OF_BUFFERS(12),BUF_OF_BUFFERS(13),BUF_OF_BUFFERS(14),BUF_OF_BUFFERS(15),
									BUF_OF_BUFFERS(16),BUF_OF_BUFFERS(17),BUF_OF_BUFFERS(18),BUF_OF_BUFFERS(19),BUF_OF_BUFFERS(20),BUF_OF_BUFFERS(21),BUF_OF_BUFFERS(22),BUF_OF_BUFFERS(23),
									BUF_OF_BUFFERS(24),BUF_OF_BUFFERS(25),BUF_OF_BUFFERS(26),BUF_OF_BUFFERS(27),BUF_OF_BUFFERS(28),BUF_OF_BUFFERS(29),BUF_OF_BUFFERS(30),BUF_OF_BUFFERS(31),
									ADDR_RS1,
									BUF_RS1_MUX
							);
							
		RS2_MUX: MUX32X1 
				 GENERIC MAP( INSIZE => DATA_IN'LENGTH )
				 PORT    MAP(
									BUF_OF_BUFFERS(0) ,BUF_OF_BUFFERS(1) ,BUF_OF_BUFFERS(2) ,BUF_OF_BUFFERS(3) ,BUF_OF_BUFFERS(4) ,BUF_OF_BUFFERS(5) ,BUF_OF_BUFFERS(6) ,BUF_OF_BUFFERS(7) ,
									BUF_OF_BUFFERS(8) ,BUF_OF_BUFFERS(9) ,BUF_OF_BUFFERS(10),BUF_OF_BUFFERS(11),BUF_OF_BUFFERS(12),BUF_OF_BUFFERS(13),BUF_OF_BUFFERS(14),BUF_OF_BUFFERS(15),
									BUF_OF_BUFFERS(16),BUF_OF_BUFFERS(17),BUF_OF_BUFFERS(18),BUF_OF_BUFFERS(19),BUF_OF_BUFFERS(20),BUF_OF_BUFFERS(21),BUF_OF_BUFFERS(22),BUF_OF_BUFFERS(23),
									BUF_OF_BUFFERS(24),BUF_OF_BUFFERS(25),BUF_OF_BUFFERS(26),BUF_OF_BUFFERS(27),BUF_OF_BUFFERS(28),BUF_OF_BUFFERS(29),BUF_OF_BUFFERS(30),BUF_OF_BUFFERS(31),
									ADDR_RS2,
									BUF_RS2_MUX
							);					
		
		DATA_RS1 <= BUF_RS1_MUX;
		DATA_RS2 <= BUF_RS2_MUX;
		
		
END STRUCTURAL; 								