-------------------------------------------------------------------------------
--
-- Title       : MALU_tb
-- Design      : MALU
-- Author      : saphalbaral, harrylin
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/ESE345Project/MALU/src/MALU_tb.vhd
-- Generated   : Tue Oct 28 15:28:59 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : All multimedia ALU functions testbench code is written. To test each individual case,
-- it is recommended that you comment all the code out (CTRL + K) and then uncomment (CTRL + SHIFT + K)
-- the test case you want to test for the constant period of 10ns. If you choose to uncomment all code, 
-- you must view each test case every 10ns. Please refer to the testbench to indiciate at what time intervals 
-- a certain instruction is operating.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;
use work.all;

entity MALU_tb is
end MALU_tb;

architecture tb_architecture of MALU_tb is

signal rs1, rs2, rs3, rd : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal instruction_format : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');

constant period : time := 10ns;

begin
	UUT : entity MALU
		port map(
		rs1 => rs1, 
		rs2 => rs2, 
		rs3 => rs3, 
		instruction_format => instruction_format, 
		rd => rd
		);
		
	stim : process
		variable expected : STD_LOGIC_VECTOR(127 downto 0);
	begin
		report "=== STARTING MALU TESTBENCH ===";
		
		report "=== STARTING LOAD IMMEDIATE TESTBENCH ===";
		-- TEST 1
		-- AND rs1 and rs2 just to have a rd that is not 'U'
		rs1 <= x"11111111111111111111111111111111";
		rs2 <= x"11111111111111111111111111111111";
		instruction_format <= "11" & "00001011" & "000000000000000";
		wait for period;
		
		-- Format ID: "00", Load Index = "011", Immediate = x"F00D", rd = "00000"
		instruction_format <= "0" & "011" & x"F00D" & "00000";
		wait for period;
			
		-- TEST 2
		-- AND rs1 and rs2 just to have a rd that is not 'U'
		rs1 <= x"11111111111111111111111111111111";
		rs2 <= x"11111111111111111111111111111111";
		instruction_format <= "11" & "00001011" & "000000000000000";
		wait for period;
		
		-- Format ID: "01", Load Index = "101", Immediate = x"BEEF", rd = "01010"
		instruction_format <= "0" & "101" & x"BEEF" & "01010";
		wait for period; 
			
		-- TEST 3
		-- AND rs1 and rs2 just to have a rd that is not 'U'
		rs1 <= x"11111111111111111111111111111111";
		rs2 <= x"11111111111111111111111111111111";
		instruction_format <= "11" & "00001011" & "000000000000000";
		wait for period;
		
		-- Format ID: "01", Load Index = "111", Immediate = x"DEAD", rd = "11011"
		instruction_format <= "0" & "111" & x"DEAD" & "11011";
		wait for period; 
		
		report "All load immediate tests complete!";
		----------------------------------------------------------------
		-- SIMALWS --
		report "=== STARTING SIGNED INTEGER MULTIPLY - ADD LOW WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"0000FFFF0000FFFF0000FFFF0000FFFF";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; 
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"0000FFFF0000FFFE0000FFFD0000FFFC";
		rs3 <= x"00000001000000020000000300000004";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; 
	
		report "All signed integer multiply - add low with saturation tests complete!";
		----------------------------------------------------------------
		-- SIMAHWS --
		report "=== STARTING SIGNED INTEGER MULTIPLY - ADD HIGH WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "001" & "00000100000010000100";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"0000FFFF0000FFFF0000FFFF0000FFFF";
		instruction_format <= "10" & "001" & "00000000000000000000";
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		instruction_format <= "10" & "001" & "00000001000010000000";
		wait for period; 
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"7FFF80007FFF80007FFF80007FFF8000";  
		rs3 <= x"00010001000100010001000100010001";
		instruction_format <= "10" & "001" & "00000000000000000000";
		wait for period; 
		
		report "All signed integer multiply - add high with saturation tests complete!";
		---------------------------------------------------------------- 
		-- SIMSLWS -- 
		report "=== STARTING SIGNED INTEGER MULTIPLY - SUBTRACT LOW WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "010" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		instruction_format <= "10" & "010" & "00001000000001000100";
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00000002000000020000000200000002";
		rs3 <= x"00007FFF00007FFF00007FFF00007FFF";
		instruction_format <= "10" & "010" & "00000000010000101100";
		wait for period;
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"0000FFFF0000FFFE0000FFFD0000FFFC";
		rs3 <= x"00000001000000020000000300000004";
		instruction_format <= "10" & "010" & "00001001000000001000";
		wait for period; 
		
		report "All signed integer multiply - subtract low with saturation tests complete!";
		---------------------------------------------------------------- 
		-- SIMSHWS --
		report "=== STARTING SIGNED INTEGER MULTIPLY - SUBTRACT HIGH WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00020003000400050006000700080009"; 
		rs3 <= x"00010002000300040005000600070008";
		instruction_format <= "10" & "011" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 
		rs2 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 
		rs3 <= x"FFFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF";
		instruction_format <= "10" & "011" & "00000000010000000010"; 
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000"; 
		rs2 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 
		rs3 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 		
		instruction_format <= "10" & "011" & "00010000000100000000";  
		wait for period;  
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"7FFF80007FFF80007FFF80007FFF8000"; 
		rs3 <= x"80007FFF80007FFF80007FFF80007FFF";
		instruction_format <= "10" & "011" & "00000011000000001000";
		wait for period;                                                                                         
		
		report "All signed integer multiply - subtract high with saturation tests complete!";
		----------------------------------------------------------------                         
		-- SLIMALWS --
		report "=== STARTING SIGNED LONG INTEGER MULTIPLY - ADD LOW WITH SATURATION TESTBENCH ==="; 
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000000000000010000000000000002";
		rs2 <= x"00000002000000030000000400000005"; 
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "100" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF"; 
		rs2 <= x"00000002000000020000000200000002"; 
		rs3 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		instruction_format <= "10" & "100" & "00000000010000000010"; 
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000000000008000000000000000"; 
		rs2 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 
		rs3 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 		
		instruction_format <= "10" & "100" & "00010000000100000000";  
		wait for period;  
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000000000000010000000000000002";
		rs2 <= x"FFFFFFFF0000000100000000FFFFFFFF"; 
		rs3 <= x"0000000200000003FFFFFFFFFFFFFFFE";
		instruction_format <= "10" & "100" & "00000011000000001000";
		wait for period;

		report "All signed long integer multiply - add low with saturation tests complete!";
		----------------------------------------------------------------                         
		-- SLIMAHWS --
		report "=== STARTING SIGNED LONG INTEGER MULTIPLY - ADD HIGH WITH SATURATION TESTBENCH ==="; 
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000000000000010000000000000002";
		rs2 <= x"00000002000000030000000400000005"; 
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "101" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF"; 
		rs2 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 
		rs3 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		instruction_format <= "10" & "101" & "00000000010000000010"; 
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000000000008000000000000000"; 
		rs2 <= x"80000000800000008000000080000000"; 
		rs3 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 		
		instruction_format <= "10" & "101" & "00010000000100000000";  
		wait for period;  
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000000000000010000000000000002";
		rs2 <= x"7FFFFFFF800000007FFFFFFF80000000"; 
		rs3 <= x"800000007FFFFFFF800000007FFFFFFF";
		instruction_format <= "10" & "101" & "00000011000000001000";
		wait for period;

		report "All signed long integer multiply - add high with saturation tests complete!";
		--------------------------------------------------------------
		-- SLIMSLWS --
		report "=== STARTING SIGNED LONG INTEGER MULTIPLY - SUBTRACT LOW WITH SATURATION TESTBENCH ==="; 
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000000000000020000000000000004";
		rs2 <= x"00000002000000030000000400000005"; 
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "110" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF"; 
		rs2 <= x"00000000FFFFFFFF00000000FFFFFFFF"; 
		rs3 <= x"000000007FFFFFFF000000007FFFFFFF";
		instruction_format <= "10" & "110" & "00000000000000000000"; 
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000000000008000000000000000"; 
		rs2 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 
		rs3 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 		
		instruction_format <= "10" & "110" & "00000000000000000000";  
		wait for period;  
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000000000000010000000000000002";
		rs2 <= x"FFFFFFFF0000000100000000FFFFFFFF"; 
		rs3 <= x"0000000200000003FFFFFFFFFFFFFFFE";
		instruction_format <= "10" & "110" & "00000000000000000000";
		wait for period;

		report "All signed long integer multiply - subtract low with saturation tests complete!";
		--------------------------------------------------------------
		-- SLIMSHWS --
		report "=== STARTING SIGNED LONG INTEGER MULTIPLY - SUBTRACT HIGH WITH SATURATION TESTBENCH ==="; 
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000000000000020000000000000004";
		rs2 <= x"00000002000000030000000400000005"; 
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "111" & "00000000000000000000";
		wait for period; 
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF"; 
		rs2 <= x"00000000FFFFFFFF00000000FFFFFFFF"; 
		rs3 <= x"000000007FFFFFFF000000007FFFFFFF";
		instruction_format <= "10" & "111" & "00000000000000000000"; 
		wait for period; 
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000000000008000000000000000"; 
		rs2 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 
		rs3 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 		
		instruction_format <= "10" & "111" & "00000000000000000000";  
		wait for period;  
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000000000000010000000000000002";
		rs2 <= x"7FFFFFFF800000007FFFFFFF80000000"; 
		rs3 <= x"800000007FFFFFFF800000007FFFFFFF";
		instruction_format <= "10" & "111" & "00000000000000000000";
		wait for period;

		report "All signed long integer multiply - subtract high with saturation tests complete!";
		----------------------------------------------------------------
		-- NOP -- 
		report "=== STARTING NOP TESTBENCH ===";
	
		-- TEST 1
		-- Using SIMSHWS to output a rd and seeing if rd stays the same in nop
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"7FFF80007FFF80007FFF80007FFF8000"; 
		rs3 <= x"80007FFF80007FFF80007FFF80007FFF";
		instruction_format <= "10" & "011" & "00000011000000001000";
		wait for period;        

		rs1 <= x"11112222333344445555666677778888";
		rs2 <= x"9999AAAAFFFFEEEE7777555544443333";
		rs3 <= x"00000000000000000000000000000000"; -- no longer needed for R3 instructions
		instruction_format <= "11" & "00000000" & "000000000000000";
		wait for period;
		
		report "All nop tests complete!";
		----------------------------------------------------------------
		-- SHRHI --
		report "=== STARTING SHRHI TESTBENCH ===";
		
		-- TEST 1 (shift 8) 
		rs1 <= x"ABCD1234FFFF00FF000080007FFF7FFF";
		rs2 <= x"00000000000000000000000000000000"; -- value not important here so reset  
		instruction_format <= "11" & "00010001" & "010000000000000"; 
		wait for period;
		
		-- TEST 2 (max shift)
		rs1 <= x"FFFF0001800000017FFF800000010002";
		instruction_format <= "11" & "00010001" & "111110000000000"; 
		wait for period;
		
		-- TEST 3 (mixed +/-)
		rs1 <= x"80007FFF00008000FFFF000180007FFF";
		instruction_format <= "11" & "00010001" & "000110000000000";
		wait for period;
		
		report "All shrhi tests complete!";
		----------------------------------------------------------------
		-- AU --
		report "=== STARTING AU TESTBENCH ===";
		
		-- TEST 1 (no overflow)
		rs1 <= x"FFFF0001FFF10010ABCD98765432FEDC";
		rs2 <= x"00000000000000000000000000000004";  
		instruction_format <= "11" & "01100010" & "000000000000000";
		wait for period;
		
		-- TEST 2 (overflow)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		rs2 <= x"00000001000000010000000100000001";
		instruction_format <= "11" & "00000010" & "000000000000000";
		wait for period;
		
		report "All au tests complete!";
		----------------------------------------------------------------
		-- CNT1H --
		report "=== STARTING CNT1H TESTBENCH ===";
		
		-- TEST 1 (all ones)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		rs2 <= x"00000000000000000000000000000000"; -- not needed so reset  
		instruction_format <= "11" & "00000011" & "000000000000000";
		wait for period; 
		
		-- TEST 2 (alternating)
		rs1 <= x"AAAA5555AAAA5555AAAA5555AAAA5555"; 
		instruction_format <= "11" & "00000011" & "000000000000000";
		wait for period;
		
		report "All cnt1h tests complete!";
		----------------------------------------------------------------
		-- AHS --
		report "=== STARTING AHS TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00010002000300040005000600070008"; 
		rs2 <= x"00080007000600050004000300020001";
		instruction_format <= "11" & "00000100" & "000010000010000";
		wait for period; 	   
		
		-- TEST 2 (+ overflow)
		rs1 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF";  
		rs2 <= x"00010001000100010001000100010001";
		instruction_format <= "11" & "00000100" & "000000000000000";
		wait for period;
		
		-- TEST 3 (- overflow)
		rs1 <= x"80008000800080008000800080008000";  
		rs2 <= x"FFFF8000FFFF8000FFFF8000FFFF8000";  
		instruction_format <= "11" & "00000100" & "000000000000000";
		wait for period;
		
		report "All ahs tests complete!";
		----------------------------------------------------------------
		-- OR --
		report "=== STARTING OR TESTBENCH ===";
		
		-- TEST 1 (random)
		rs1 <= x"12345678ABCDEF00FF00FF00FF00FF00";
		rs2 <= x"00FF00FF00FF00FF00FF00FF00FF00FF";
		instruction_format <= "11" & "00000101" & "000001000000000";
		wait for period;
		
		-- TEST 2 (alternating bits)
		rs1 <= x"F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0";
		rs2 <= x"0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F";
		instruction_format <= "11" & "00000101" & "000000000000001";
		wait for period; 	   
		
		report "All or tests complete!";
		----------------------------------------------------------------
		-- BCW --
		report "=== STARTING BCW TESTBENCH ===";
		
		-- TEST 1 (random)
		rs1 <= x"DEADBEEFCAFEBABE0123456789ABCDEF";
		rs2 <= x"00000000000000000000000000000000"; -- not needed so reset
		instruction_format <= "11" & "00000110" & "000000000000001";
		wait for period;
		
		-- TEST 2 (alternating bits)
		rs1 <= x"A5A5A5A55A5A5A5AFFFFFFFF00000000";
		instruction_format <= "11" & "00000110" & "000000000000001";
		wait for period;
		
		report "All bcw tests complete!";
		----------------------------------------------------------------
		-- MAXWS --
		report "=== STARTING MAXWS TESTBENCH ===";
		
		-- TEST 1 (+)
		rs1 <= x"00000001000000020000000300000004";  
		rs2 <= x"00000004000000030000000200000001";
		instruction_format <= "11" & "00000111" & "000000000000000";
		wait for period;
		
		-- TEST 2 (mixed signs)
		rs1 <= x"80000000FFFFFFFF7FFFFFFF00000000";  
		rs2 <= x"7FFFFFFF8000000000000000FFFFFFFF";
		instruction_format <= "11" & "00000111" & "000000000000000";
		wait for period;
		
		-- TEST 3 (largest and smallest signed)
		rs1 <= x"7FFFFFFF800000007FFFFFFF80000000";  
		rs2 <= x"800000007FFFFFFF800000007FFFFFFF"; 
		instruction_format <= "11" & "00000111" & "000000000000000";
		wait for period;
		
		report "All maxws tests complete!";
		----------------------------------------------------------------
		-- MINWS --
		report "=== STARTING MINWS TESTBENCH ===";
		
		-- TEST 1 (+)
		rs1 <= x"00000001000000020000000300000004";  
		rs2 <= x"00000004000000030000000200000001";
		instruction_format <= "11" & "00001000" & "000000000000000";
		wait for period;
		
		-- TEST 2 (mixed signs)
		rs1 <= x"80000000FFFFFFFF7FFFFFFF00000000";  
		rs2 <= x"7FFFFFFF8000000000000000FFFFFFFF";
		instruction_format <= "11" & "00001000" & "000000000000000";
		wait for period;
		
		-- TEST 3 (largest and smallest signed)
		rs1 <= x"7FFFFFFF800000007FFFFFFF80000000";  
		rs2 <= x"800000007FFFFFFF800000007FFFFFFF"; 
		instruction_format <= "11" & "00001000" & "000000000000000";
		wait for period;
		
		report "All minws tests complete!";
		----------------------------------------------------------------
		-- MLHU --
		report "=== STARTING MLHU TESTBENCH ===";
		
		-- TEST 1 (no overflow)
		rs1 <= x"00010002000300040001000200030004";  
		rs2 <= x"00050006000700080005000600070008"; 
		instruction_format <= "11" & "00001001" & "000000000000000";
		wait for period;

		-- TEST 2 (mixed bits)
		rs1 <= x"00010000FFFF123400010000FFFF1234";  
		rs2 <= x"FFFF0001ABCD1111FFFF0001ABCD1111";  
		instruction_format <= "11" & "11111001" & "000000000000000";
		wait for period;
		
		-- TEST 3 (max unsigned, overflow)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";  
		rs2 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";  
		instruction_format <= "11" & "00001001" & "000000000000000";
		wait for period;
		
		report "All mlhu tests complete!";
		----------------------------------------------------------------
		-- MLHCU --
		report "=== STARTING MLHCU TESTBENCH ===";
		
		-- TEST 1 (mixed bits)
		rs1 <= x"00010000FFFF1234000A0005ABCD0102";
		rs2 <= x"00000000000000000000000000000000"; -- value is irrelevant so reset
		instruction_format <= "11" & "00001010" & "000010100000000";  -- rs2 = 00001 = 1
		wait for period;
		
		-- TEST 2 (large constant)
		rs1 <= x"00010002000300040005000600070008";
		instruction_format <= "11" & "10101010" & "111110000000000"; -- rs2 = 11111 = 31
		wait for period;
		
		-- TEST 3 (max halfword * max constant)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		instruction_format <= "11" & "10101010" & "111110000000000"; -- rs2 = 11111 = 31
		wait for period;
		
		report "All mlhcu tests complete!";
		----------------------------------------------------------------
		-- AND --
		report "=== STARTING AND TESTBENCH ===";
		
		-- TEST 1
		rs1 <= x"0123456789ABCDEF0011223344556677";
		rs2 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		instruction_format <= "11" & "00001011" & "000000000000000";
		wait for period;
		
		-- TEST 2
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		rs2 <= x"00000000000000000000000000000000";
		instruction_format <= "11" & "00001011" & "000000000000000";
		wait for period;
		
		report "All and tests complete!";
		----------------------------------------------------------------
		-- CLZW --
		report "=== STARTING CLZW TESTBENCH ===";
		
		-- TEST 1
		rs1 <= x"8000000080000000000000007FFFFFFF"; 
		rs2 <= x"00000000000000000000000000000000"; -- not needed so reset
		instruction_format <= "11" & "00001100" & "000000000000000";
		wait for period;
		
		-- TEST 2
		rs1 <= x"0F0F0F0FF0F0F0F00FFF0000FF000000"; 
		instruction_format <= "11" & "00001100" & "000000000000000";
		wait for period;
		
		report "All clzw tests complete!";
		----------------------------------------------------------------
		-- ROTW --
		report "=== STARTING ROTW TESTBENCH ===";
		
		-- TEST 1 (one-bit rotation)
		rs1 <= x"00000001000000020000000480000000"; 
		rs2 <= x"00000001000000010000000100000001"; 
		instruction_format <= "11" & "00001101" & "000000000000000";
		wait for period;
		
		-- TEST 2 (max rotation - 31)
		rs1 <= x"00000001FFFFFFFFAAAAAAAA55555555";  
		rs2 <= x"0000001F0000001F0000001F0000001F"; 
		instruction_format <= "11" & "00001101" & "000000000000000";
		wait for period;
		
		-- TEST 3 (mixed rotation)
		rs1 <= x"F00000000F000000AAAAAAAA55555555";  
		rs2 <= x"00000004000000080000000C00000010";  
		instruction_format <= "11" & "00101101" & "000000000000000";
		wait for period;
		
		report "All rotw tests complete!";
		----------------------------------------------------------------
		-- SFWU --
		report "=== STARTING SFWU TESTBENCH ===";
		
		-- TEST 1 (underflow, borrowing)
		rs1 <= x"00000002000000030000000400000005";
		rs2 <= x"00000001000000020000000300000004";
		instruction_format <= "11" & "00001110" & "000000000000000";
		wait for period;

		-- TEST 2 (extremes)
		rs1 <= x"FFFFFFFF000000000000000000000000";
		rs2 <= x"00000000FFFFFFFFFFFFFFFFFFFFFFFF";
		instruction_format <= "11" & "00001110" & "000000000000000";
		wait for period;
		
		-- TEST 3 (alternating bits)
		rs1 <= x"AAAAAAAA55555555FFFFFFFF00000000";
		rs2 <= x"55555555AAAAAAAA00000000FFFFFFFF";
		instruction_format <= "11" & "00001110" & "000000000000000";
		wait for period;

		report "All sfwu tests complete!";
		----------------------------------------------------------------
		-- SFHS --
		report "=== STARTING SFHS TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00010002000300040005000600070008"; 
		rs2 <= x"00080007000600050004000300020001";
		instruction_format <= "11" & "00001111" & "000000000000000";
		wait for period;
		
		-- TEST 2 (+ overflow)
		rs1 <= x"80008000800080008000800080008000"; 
		rs2 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 
		instruction_format <= "11" & "00001111" & "000000000000000";
		wait for period;
		
		-- TEST 3 (- overflow)
		rs1 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 
		rs2 <= x"80008000800080008000800080008000"; 
		instruction_format <= "11" & "00001111" & "000000000000000";
		wait for period;
		
		-- TEST 4 (mixed signs)
		rs1 <= x"7FFF0000800000017FFFFFFF80000000";
		rs2 <= x"00007FFF7FFF8000FFFF00007FFF8000";
		instruction_format <= "11" & "00001111" & "000000000000000";
		wait for period;

		report "All sfhs tests complete!";		
	
		report "=== FINISHED MALU TESTBENCH ===";
	
  	std.env.finish;
  end process;
end tb_architecture;
