LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DEC5X32 IS 

	PORT(
		SEL : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		RES : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	    );
		 
END DEC5X32;

ARCHITECTURE BEHAVIORAL OF DEC5X32 IS

	BEGIN
	
	PROCESS(SEL) 
	
		BEGIN
			
			RES <= (OTHERS => '0');
			
			CASE SEL IS
			
				WHEN "00000" => RES     <= (OTHERS =>'0');
				WHEN "00001" => RES(1)  <= '1';
				WHEN "00010" => RES(2)  <= '1';
				WHEN "00011" => RES(3)  <= '1';
				WHEN "00100" => RES(4)  <= '1';
				WHEN "00101" => RES(5)  <= '1';
				WHEN "00110" => RES(6)  <= '1';
				WHEN "00111" => RES(7)  <= '1';
				WHEN "01000" => RES(8)  <= '1';
				WHEN "01001" => RES(9)  <= '1';
				WHEN "01010" => RES(10) <= '1';
				WHEN "01011" => RES(11) <= '1';
				WHEN "01100" => RES(12) <= '1';
				WHEN "01101" => RES(13) <= '1';
				WHEN "01110" => RES(14) <= '1';
				WHEN "01111" => RES(15) <= '1';
				WHEN "10000" => RES(16) <= '1';
				WHEN "10001" => RES(17) <= '1';
				WHEN "10010" => RES(18) <= '1';
				WHEN "10011" => RES(19) <= '1';
				WHEN "10100" => RES(20) <= '1';
				WHEN "10101" => RES(21) <= '1';
				WHEN "10110" => RES(22) <= '1';
				WHEN "10111" => RES(23) <= '1';
				WHEN "11000" => RES(24) <= '1';
				WHEN "11001" => RES(25) <= '1';
				WHEN "11010" => RES(26) <= '1';
				WHEN "11011" => RES(27) <= '1';
				WHEN "11100" => RES(28) <= '1';
				WHEN "11101" => RES(29) <= '1';
				WHEN "11110" => RES(30) <= '1';
				WHEN "11111" => RES(31) <= '1';
				WHEN OTHERS  => RES     <= (OTHERS =>'0');
			
			END CASE;

	END PROCESS;

END BEHAVIORAL;