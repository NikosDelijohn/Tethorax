LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

USE WORK.TOOLBOX.ALL;

ENTITY ID_STALL_FWD_PREDICT IS

	PORT( 
			RS1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS1 comming from ID
			RS2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RS2 comming from ID
			RD_E : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RD  comming from EXE
			RD_M : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- RD  comming from MEM
			
			LOAD_IN_EXE : IN  STD_LOGIC; -- 1 if command at EXE is Load
			LOAD_IN_MEM : IN  STD_LOGIC; -- 1 if command at MEM is Load
			
			-- Local (ID) Signals
			IMGEN : IN STD_LOGIC_VECTOR(2 DOWNTO  0); -- Used to detect U/R/S - Commands
			JUMP  : IN STD_LOGIC; -- Used to detect Jump
			JALR  : IN STD_LOGIC; -- /
			BRANCH: IN STD_LOGIC; -- Used to detect Branches
			
			STALL: OUT STD_LOGIC;
			FWDA : OUT STD_LOGIC;
			FWDB : OUT STD_LOGIC;
			FWDC : OUT STD_LOGIC
		);

END ID_STALL_FWD_PREDICT;

ARCHITECTURE RTL OF ID_STALL_FWD_PREDICT IS
	
	SIGNAL GND  : STD_LOGIC := '0';
	
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
	
	SIGNAL OR_A : STD_LOGIC; -- Used for stalls and fwda,
	SIGNAL OR_B : STD_LOGIC; -- fwdc.
	SIGNAL OR_C : STD_LOGIC; -- Used only for
	SIGNAL OR_D : STD_LOGIC; -- fwdb.
	
	BEGIN

	BUF_A <= AND_REDUCE(RS1 XNOR RD_E); -- RS1 == RD of EXE stage
	BUF_B <= AND_REDUCE(RS2 XNOR RD_E); -- RS2 == RD of EXE stage
	BUF_C <= AND_REDUCE(RS1 XNOR RD_M); -- RS1 == RD of MEM stage
	BUF_D <= AND_REDUCE(RS1 XNOR RD_M); -- RS2 == RD of MEM stage
	
	ITS_STORE 	  <= AND_REDUCE(IMGEN XNOR "001"); -- ID_DECODER gives IMGEN 001 for STORE
	ITS_R     	  <= AND_REDUCE(IMGEN XNOR "111"); -- ID_DECODER gives IMGEN 111 for R
	ITS_LUI_AUIPC <= AND_REDUCE(IMGEN XNOR "011"); -- ID_DECODER gives IMGEN 011 for U 
	ITS_JAL       <= JUMP AND (NOT JALR);  
	
	SELECT_RS1 <= ITS_LUI_AUIPC   OR ITS_JAL;   -- ID depended
	SELECT_RS2 <= ITS_R OR BRANCH OR ITS_STORE; -- signals.
	
	EXE_MUX_RS1: MUX2X1_BIT
			 PORT MAP (
						D0  => BUF_A,      -- If it is AUIPC or LUI
						D1  => GND,        -- then there is no RS1
						SEL => SELECT_RS1, 
						O   => OR_A
					   );
	EXE_MUX_RS2: MUX2X1_BIT
			 PORT MAP (
						D0  => GND,       -- If it is NOT R or Branch or Store 
						D1  => BUF_B,	  -- then there is no RS2
						SEL => SELECT_RS2,
						O   => OR_B
					  );
					  
	MEM_MUX_RS1: MUX2X1_BIT
			 PORT MAP (
						D0  => BUF_C,
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
	
	STALL <= (OR_A OR OR_B) AND LOAD_IN_EXE;
	FWDA  <=  OR_A OR OR_B;
	FWDB  <= (OR_C OR OR_D) AND LOAD_IN_MEM;
	FWDC  <=  LOAD_IN_EXE AND ITS_STORE AND BUF_B;
	
END RTL;