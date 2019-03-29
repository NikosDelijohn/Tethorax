LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.PIPELINE.ALL;

ENTITY PACKAGE_ERROR IS

	PORT (  
			INP : IN  BIT;
			RES : OUT BIT
		  );
		  
END PACKAGE_ERROR;

ARCHITECTURE WHAT OF PACKAGE_ERROR IS

	SIGNAL CLK : STD_LOGIC;
	SIGNAL OP  : STD_LOGIC_VECTOR(3  DOWNTO 0);
	SIGNAL WR  : STD_LOGIC_VECTOR(6  DOWNTO 0);
	SIGNAL DAT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL R   : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
	
	MEM4: MEMORY
		  PORT MAP (
		  
					CLK => CLK,
					OP  => OP,
					WR_ADR => WR,
					WR_DAT => DAT,
					MEM_RES => R
					);
					
END WHAT;