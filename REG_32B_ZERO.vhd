-- This special type of register will be register x0.
-- x0 is hardwired to value 0 and its value cannot be changed.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY REG_32B_ZERO IS

	PORT (
		 	CLK   : IN  STD_LOGIC;
		 	Q_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		 );

END REG_32B_ZERO;

ARCHITECTURE RTL OF REG_32B_ZERO IS

	SIGNAL BUF : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	
	BEGIN

	FUNC: PROCESS(CLK)

		  BEGIN 

			IF   (CLK'EVENT AND CLK ='1') THEN BUF <= (OTHERS =>'0');

			ELSE NULL;

			END IF;
			
		  END PROCESS;
		
		  Q_OUT <= BUF;
		
END RTL;	