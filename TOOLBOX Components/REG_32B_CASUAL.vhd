-- 32 Bit Register with Parrarel Load function and Asynchronous Reset
-- There will be 31 of those registers in the register file

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY REG_32B_CASUAL IS 

	PORT (
			LOAD, CLK, RST : IN  STD_LOGIC;
			DATA		   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Q_OUT 		   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		 );

END REG_32B_CASUAL;

ARCHITECTURE RTL OF REG_32B_CASUAL IS

	SIGNAL BUF : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN

	FUNC: PROCESS(CLK,RST,LOAD)

		BEGIN
			
			IF 	  (RST = '1') THEN BUF <= (OTHERS =>'0');

			ELSIF (CLK'EVENT AND CLK = '1' AND LOAD = '1') THEN BUF <= DATA;

			ELSE  NULL;

			END IF;
			
		 END PROCESS;
		  
		 Q_OUT <= BUF;
		  
END RTL;