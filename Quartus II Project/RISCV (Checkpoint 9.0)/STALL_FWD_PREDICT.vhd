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
---------------------------------------------------------------
-- PART#5 STALL AND FORWARD PREDICTOR
-- " In some cases, to speed up things and avoid loosing 
--   some clock cycles, "forwarding" is required. In others,
--   a Stall signal must be generated and IF and ID stages 
--   have to halt for 1 clock cycle due to the nature of true
--   dependency RAW. This module works as following
--   
--   Stall: If the command at EXE stage is a Load command and
--          its rd equals the rs1 OR rs2 of the command which
-- 		    is currently at ID stage then a Stall signal has
--          to be generated. Also, Stall => FWD_B = 1 **
-- 
--   FWD_A: If the command at EXE stage is not a Load command
--          and its rd equals the rs1 OR rs2 of the command 
--          which is currently at ID stage then the rd value 
--          can be forwarded from EXE out to EXE in.
--
--   FWD_B: If the command at MEM stage is a Load command and
--          its rd equals the rs1 OR rs2 of the command which 
--          is currently at ID stage then the rd value can be
--          forwarded from MEM out to EXE in.
--
--   FWD_C: If the command at EXE stage is a Load command
--          AND the command at ID stage is a Store command and
--          Load's rd == Store's rs2 then the rd value can be
--          forwarded from MEM out to MEM in.
-- 
--   ** :   NOTE that FWD_A and FWD_C signals if they are 
--          generated then this means that Stall == 0. 
--          On the other hand, Stall must also generate a 
--          FWD_B signal otherwise we should halt for another cc.
---------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

USE WORK.TOOLBOX.ALL;

ENTITY STALL_FWD_PREDICT IS

	PORT( 
			RS1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS1 comming from ID
			RS2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS2 comming from ID
			RD_E : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RD  comming from EXE
			RD_M : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RD  comming from MEM
			
			LOAD_IN_EXE : IN  STD_LOGIC; -- 1 if command at EXE is Load
			LOAD_IN_MEM : IN  STD_LOGIC; -- 1 if command at MEM is Load
			
			-- Local (ID) Signal
			IMGEN : IN STD_LOGIC_VECTOR(2 DOWNTO  0); -- Used to detect B/U/R/S/J - Commands
			
			STALL: OUT STD_LOGIC;
			FWDA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- bit#1 rs1, bit#0 rs2
			FWDB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- bit#1 rs1, bit#0 rs2
			FWDC : OUT STD_LOGIC                     -- This forward path concerns only rs2
		);

END STALL_FWD_PREDICT;

ARCHITECTURE RTL OF STALL_FWD_PREDICT IS
	
	SIGNAL GND  : STD_LOGIC := '0';
	
	SIGNAL MUST_STALL : STD_LOGIC;
		
	SIGNAL BUF_A: STD_LOGIC;
	SIGNAL BUF_B: STD_LOGIC;
	SIGNAL BUF_C: STD_LOGIC;
	SIGNAL BUF_D: STD_LOGIC;
	
	SIGNAL SELECT_RS1 : STD_LOGIC;
	SIGNAL SELECT_RS2 : STD_LOGIC;
	
	SIGNAL ITS_STORE    : STD_LOGIC;
	SIGNAL ITS_R        : STD_LOGIC;
	SIGNAL ITS_LUI_AUIPC: STD_LOGIC;
	SIGNAL ITS_JAL      : STD_LOGIC;
	SIGNAL ITS_BRANCH   : STD_LOGIC;
	
	SIGNAL OR_A : STD_LOGIC; -- Used for stalls and fwda,
	SIGNAL OR_B : STD_LOGIC; -- fwdc.
	SIGNAL OR_C : STD_LOGIC; -- Used only for
	SIGNAL OR_D : STD_LOGIC; -- fwdb.
	
	BEGIN

	BUF_A <= AND_REDUCE(RS1 XNOR RD_E); -- RS1 == RD of EXE stage
	BUF_B <= AND_REDUCE(RS2 XNOR RD_E); -- RS2 == RD of EXE stage
	BUF_C <= AND_REDUCE(RS1 XNOR RD_M); -- RS1 == RD of MEM stage
	BUF_D <= AND_REDUCE(RS2 XNOR RD_M); -- RS2 == RD of MEM stage
	
	ITS_STORE 	  <= AND_REDUCE(IMGEN XNOR "001"); -- ID_DECODER gives IMGEN 001 for STORE
	ITS_R     	  <= AND_REDUCE(IMGEN XNOR "111"); -- ID_DECODER gives IMGEN 111 for R
	ITS_LUI_AUIPC <= AND_REDUCE(IMGEN XNOR "011"); -- ID_DECODER gives IMGEN 011 for U 
	ITS_JAL       <= AND_REDUCE(IMGEN XNOR "100"); -- ID_DECODER gives IMGEN 100 for JAL 
	ITS_BRANCH    <= AND_REDUCE(IMGEN XNOR "010"); -- ID_DECODER gives IMGEN 010 for Branch
	
	SELECT_RS1 <= ITS_LUI_AUIPC   OR ITS_JAL; 
	SELECT_RS2 <= ITS_R           OR ITS_BRANCH OR (ITS_STORE AND (NOT LOAD_IN_EXE)); -- If the ID has a STORE and the EXE has OP != Load then again, 
	                                                                                  -- forward is needed in case of equality between rs2,rd.
	EXE_MUX_RS1: MUX2X1_BIT														      -- ex: ADD a, b, c
			 PORT MAP (															      --      SW a, d, e 
						D0  => BUF_A,      -- If it is AUIPC or LUI or JAL
						D1  => GND,        -- then there is no RS1
						SEL => SELECT_RS1, 
						O   => OR_A
					   );
	EXE_MUX_RS2: MUX2X1_BIT
			 PORT MAP (
						D0  => GND,        -- If it is NOT R or Branch
						D1  => BUF_B,	   -- then there is no RS2. If it is Store
						SEL => SELECT_RS2, -- then RS2 has its own FWD path in MEM
						O   => OR_B        -- fwdc.
					  );
					  
	MEM_MUX_RS1: MUX2X1_BIT
			 PORT MAP (
						D0  => BUF_C,		-- These Muxes concern the FWDB path
						D1  => GND, 		 
						SEL => SELECT_RS1,  
 						O   => OR_C
					  );
					  
	MEM_MUX_RS2: MUX2X1_BIT
			 PORT MAP (
						D0  => GND,
						D1  => BUF_D,
						SEL => SELECT_RS2,
						O   => OR_D
					  );
	
	MUST_STALL <= (OR_A OR OR_B) AND LOAD_IN_EXE;
	
	STALL <=  MUST_STALL;
	FWDA  <= (OR_A AND NOT MUST_STALL) & (OR_B AND NOT MUST_STALL);
	FWDB  <= ((OR_C AND LOAD_IN_MEM) OR MUST_STALL) & ((OR_D AND LOAD_IN_MEM) OR MUST_STALL);
	FWDC  <=  LOAD_IN_EXE AND ITS_STORE AND BUF_B AND NOT MUST_STALL;
	
END RTL;