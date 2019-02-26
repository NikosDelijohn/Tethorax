-- This is a Custom PACKAGE file used to avoid duplicate code being written
-- in other files (e.g. ARCHITECTURES).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE TOOLBOX IS

-- ================== INSTRUCTION FETCH COMPONENTS ================== --
------------------------------------------------------------------------
	-- Defined @ "I_F_RAM.vhd" file.
	COMPONENT I_F_RAM IS
	
			PORT
				(
					address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
					clock		: IN STD_LOGIC  := '1';
					data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
					wren		: IN STD_LOGIC ;
					q		    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
				);
				
	END COMPONENT I_F_RAM;
------------------------------------------------------------------------

END PACKAGE TOOLBOX;