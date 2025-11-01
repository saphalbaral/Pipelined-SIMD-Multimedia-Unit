-------------------------------------------------------------------------------
--
-- Title       : MALU
-- Design      : MALU
-- Author      : saphalbaral, harrylin
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/ESE345Project/MALU/src/MALU.vhd
-- Generated   : Sat Oct 25 18:46:21 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : All multimedia ALU functions at the 3rd (execute) pipelines stage after forwarding.
-- 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all; 
use work.all;

entity MALU is
	port(
		rs1 : in STD_LOGIC_VECTOR(127 downto 0);				-- 128-bit vector (input)
		rs2 : in STD_LOGIC_VECTOR(127 downto 0); 				-- 128-bit vector (input)
		rs3 : in STD_LOGIC_VECTOR(127 downto 0);				-- 128-bit vector (input)	
		instruction_format : in STD_LOGIC_VECTOR(24 downto 0); 	-- 25-bit vector (input)
		rd : out STD_LOGIC_VECTOR(127 downto 0) 				-- 128-bit vector (output)
	);
end MALU;

architecture behavioral of MALU is
begin

	process(all)
	variable output : STD_LOGIC_VECTOR(127 downto 0);	    -- output register
	variable format_id : STD_LOGIC_VECTOR(1 downto 0);	    
	
	-- LOAD IMMEDIATE FIELDS
	variable load_index : integer;				-- Used to identify the load index (3-bits, so 0-7) 
	variable immediate : unsigned(15 downto 0);		-- 16-bit immediate value
	
	-- R4 INSTRUCTION FORMAT FIELDS			   
	variable li_sa_hl : STD_LOGIC_VECTOR(2 downto 0);	
	constant signed_long_64_min : signed(63 downto 0) := signed(b"1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000");
	constant signed_int_32_min : signed(31 downto 0) := signed(b"10000000000000000000000000000000");
	constant signed_long_64_max : signed(63 downto 0) := signed(b"0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111");
	constant signed_int_32_max : signed(31 downto 0) := signed(b"01111111111111111111111111111111");
	
	variable product_int_32 : signed(31 downto 0);
	variable sum_int_32 : signed(32 downto 0);
	variable diff_int_32 : signed(32 downto 0);
	
	variable product_long_64 : signed(63 downto 0);
	variable sum_long_64 : signed(64 downto 0);
	variable diff_long_64 : signed(64 downto 0);
	
	-- R3 INSTRUCTION FORMAT FIELDS
	variable r3_opcode : STD_LOGIC_VECTOR(7 downto 0); -- Bits [22:15] represent opcode
	
	variable shift : integer range 0 to 15;
	variable cnt : integer range 0 to 16;
	
	variable reg1 : signed(15 downto 0); -- Used in AHS, SFS
	variable reg2 : signed(15 downto 0); -- Used in AHS, SFHS
	variable sum : signed(16 downto 0); -- extra bit for overflow, AHS
	variable diff :signed(16 downto 0); -- extra bit for overflow, SFS
		
	variable reg_result : signed(127 downto 0); 
	
	variable reg3 : signed (31 downto 0); -- Used in MAXWS, MINWS, CLZW
	variable reg4 : signed (31 downto 0);	-- Used in MAXWS, MINWS
	variable product : unsigned(31 downto 0); -- Used in MAXWS, MINWS, MLHU, MLHCU
	
	variable word_val :std_logic_vector(31 downto 0); -- Used in CLZW
	variable count : integer range 0 to 32; -- 2^5 = 32 bits	
	
	variable w1, w2 : unsigned(31 downto 0); -- Used in SFWU
	variable result : unsigned (31 downto 0); 
	
	variable half_rs1, half_rs2 : unsigned(15 downto 0);
	
	variable w3 : unsigned(15 downto 0); -- Used in MLHCU
	variable w0 : unsigned(15 downto 0); -- Used in MLHCU 														   
	
	variable rotated_rs1 : std_logic_vector(31 downto 0); -- Used in ROTW
	variable temp_lsb : std_logic; -- Used in ROTW
	
	variable num_rot : integer range 0 to 31;  -- Used in ROTW, max value: 2^5 - 1 = 31
	
	begin
		format_id := instruction_format(24 downto 23);
		output := (others => '0');					-- Clear output
		
		case format_id is
			-- Load Immediate
			when "00" | "01" =>
			load_index := to_integer(unsigned(instruction_format(23 downto 21))); 		-- Extract the load index 
			immediate := unsigned(instruction_format(20 downto 5));			 		-- Extract the immediate value
			output := rd;									 			 		-- Reads register in which the source = destination
			output(load_index*16 + 15 downto load_index*16) := std_logic_vector(immediate);	-- Place immediate value in correct load index field 
			rd <= output;								 				 		-- Output new result
		   --==========================================================================================================--	
			-- R4 instructions
			when "10" =>
			li_sa_hl := instruction_format(22 downto 20);
			output := (others => '0');
				
				case li_sa_hl is
					-- Signed Integer Multiply - Add Low with Saturation
					when "000" =>
					-- Word 0 [31:0]
					product_int_32 := signed(rs2(15 downto 0)) * signed(rs3(15 downto 0));
					sum_int_32 := resize(signed(rs1(31 downto 0)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(31 downto 0) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
					
					-- Word 1 [63:32]
					product_int_32 := signed(rs2(47 downto 32)) * signed(rs3(47 downto 32));
					sum_int_32 := resize(signed(rs1(63 downto 32)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(63 downto 32) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
					
					-- Word 2 [95:64]
					product_int_32 := signed(rs2(79 downto 64)) * signed(rs3(79 downto 64));
					sum_int_32 := resize(signed(rs1(95 downto 64)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(95 downto 64) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
					
					-- Word 3 [127:96]
					product_int_32 := signed(rs2(111 downto 96)) * signed(rs3(111 downto 96));
					sum_int_32 := resize(signed(rs1(127 downto 96)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(127 downto 96) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
			--==========================================================================================================--		
					-- Signed Integer Multiply - Add High with Saturation
					when "001" =>
					-- Word 0 [31:0]
					product_int_32 := signed(rs2(31 downto 16)) * signed(rs3(31 downto 16));
					sum_int_32 := resize(signed(rs1(31 downto 0)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(31 downto 0) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
					
					-- Word 1 [63:32]
					product_int_32 := signed(rs2(63 downto 48)) * signed(rs3(63 downto 48));
					sum_int_32 := resize(signed(rs1(63 downto 32)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(63 downto 32) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
					
					-- Word 2 [95:64]
					product_int_32 := signed(rs2(95 downto 80)) * signed(rs3(95 downto 80));
					sum_int_32 := resize(signed(rs1(95 downto 64)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(95 downto 64) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
					
					-- Word 3 [127:96]
					product_int_32 := signed(rs2(127 downto 112)) * signed(rs3(127 downto 112));
					sum_int_32 := resize(signed(rs1(127 downto 96)), 33) + resize(product_int_32, 33);
					if sum_int_32 > resize(signed_int_32_max, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif sum_int_32 < resize(signed_int_32_min, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(127 downto 96) := STD_LOGIC_VECTOR(sum_int_32(31 downto 0));
					end if;
			   --==========================================================================================================--
					-- Signed Integer Multiply - Subtract Low with Saturation
					when "010" =>
					-- Word 0 [31:0]
					product_int_32 := signed(rs2(15 downto 0)) * signed(rs3(15 downto 0));
					diff_int_32 := resize(signed(rs1(31 downto 0)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(31 downto 0) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
					
					-- Word 1 [63:32]
					product_int_32 := signed(rs2(47 downto 32)) * signed(rs3(47 downto 32));
					diff_int_32 := resize(signed(rs1(63 downto 32)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(63 downto 32) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
					
					-- Word 2 [95:64]
					product_int_32 := signed(rs2(79 downto 64)) * signed(rs3(79 downto 64));
					diff_int_32 := resize(signed(rs1(95 downto 64)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(95 downto 64) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
					
					-- Word 3 [127:96]
					product_int_32 := signed(rs2(111 downto 96)) * signed(rs3(111 downto 96));
					diff_int_32 := resize(signed(rs1(127 downto 96)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(127 downto 96) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
			  --==========================================================================================================--
					-- Signed Integer Multiply - Subtract High with Saturation
					when "011" =>
					-- Word 0 [31:0]
					product_int_32 := signed(rs2(31 downto 16)) * signed(rs3(31 downto 16));
					diff_int_32 := resize(signed(rs1(31 downto 0)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(31 downto 0) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(31 downto 0) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
					
					-- Word 1 [63:32]
					product_int_32 := signed(rs2(63 downto 48)) * signed(rs3(63 downto 48));
					diff_int_32 := resize(signed(rs1(63 downto 32)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(63 downto 32) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(63 downto 32) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
					
					-- Word 2 [95:64]
					product_int_32 := signed(rs2(95 downto 80)) * signed(rs3(95 downto 80));
					diff_int_32 := resize(signed(rs1(95 downto 64)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(95 downto 64) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(95 downto 64) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
					
					-- Word 3 [127:96]
					product_int_32 := signed(rs2(127 downto 112)) * signed(rs3(127 downto 112));
					diff_int_32 := resize(signed(rs1(127 downto 96)), 33) - resize(product_int_32, 33);
					if diff_int_32 > resize(signed_int_32_max, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_max);
					elsif diff_int_32 < resize(signed_int_32_min, 33) then
						output(127 downto 96) := STD_LOGIC_VECTOR(signed_int_32_min);
					else
						output(127 downto 96) := STD_LOGIC_VECTOR(diff_int_32(31 downto 0));
					end if;
			  --==========================================================================================================--	
					-- Signed Long Integer Multiply - Add Low with Saturation
					when "100" =>									 
					-- Word 0 [63:0]
					product_long_64 := signed(rs2(31 downto 0)) * signed(rs3(31 downto 0));
					sum_long_64 := resize(signed(rs1(63 downto 0)), 65) + resize(product_long_64, 65);		 
					
					if sum_long_64 > resize(signed_long_64_max, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif sum_long_64 < resize(signed_long_64_min, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(63 downto 0) := STD_LOGIC_VECTOR(sum_long_64(63 downto 0));
					end if;
					
					-- Word 1 [127:64]
					product_long_64 := signed(rs2(95 downto 64)) * signed(rs3(95 downto 64));
					sum_long_64 := resize(signed(rs1(127 downto 64)), 65) + resize(product_long_64, 65);
					
					if sum_long_64 > resize(signed_long_64_max, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif sum_long_64 < resize(signed_long_64_min, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(127 downto 64) := STD_LOGIC_VECTOR(sum_long_64(63 downto 0));
					end if;
			   --==========================================================================================================--	
					-- Signed Long Integer Multiply - Add High with Saturation
					when "101" =>
					-- Word 0 [63:0]
					product_long_64 := signed(rs2(63 downto 32)) * signed(rs3(63 downto 32));
					sum_long_64 := resize(signed(rs1(63 downto 0)), 65) + resize(product_long_64, 65);
					if sum_long_64 > resize(signed_long_64_max, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif sum_long_64 < resize(signed_long_64_min, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(63 downto 0) := STD_LOGIC_VECTOR(sum_long_64(63 downto 0));
					end if;
					
					-- Word 1 [127:64]
					product_long_64 := signed(rs2(127 downto 96)) * signed(rs3(127 downto 96));
					sum_long_64 := resize(signed(rs1(127 downto 64)), 65) + resize(product_long_64, 65);
					if sum_long_64 > resize(signed_long_64_max, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif sum_long_64 < resize(signed_long_64_min, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(127 downto 64) := STD_LOGIC_VECTOR(sum_long_64(63 downto 0));
					end if;
			   --==========================================================================================================--					
					-- Signed Long Integer Multiply - Subtract Low with Saturation
					when "110" =>
					-- Word 0 [63:0]
					product_long_64 := signed(rs2(31 downto 0)) * signed(rs3(31 downto 0));
					diff_long_64 := resize(signed(rs1(63 downto 0)), 65) - resize(product_long_64, 65);
					if diff_long_64 > resize(signed_long_64_max, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif diff_long_64 < resize(signed_long_64_min, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(63 downto 0) := STD_LOGIC_VECTOR(diff_long_64(63 downto 0));
					end if;
					
					-- Word 1 [127:64]
					product_long_64 := signed(rs2(95 downto 64)) * signed(rs3(95 downto 64));
					diff_long_64 := resize(signed(rs1(127 downto 64)), 65) - resize(product_long_64, 65);
					if diff_long_64 > resize(signed_long_64_max, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif diff_long_64 < resize(signed_long_64_min, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(127 downto 64) := STD_LOGIC_VECTOR(diff_long_64(63 downto 0));
					end if;
			   --==========================================================================================================--	
					-- Signed Long Integer Multiply - Subtract High with Saturation
					when "111" =>
					-- Word 0 [63:0]
					product_long_64 := signed(rs2(63 downto 32)) * signed(rs3(63 downto 32));
					diff_long_64 := resize(signed(rs1(63 downto 0)), 65) - resize(product_long_64, 65);
					if diff_long_64 > resize(signed_long_64_max, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif diff_long_64 < resize(signed_long_64_min, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(63 downto 0) := STD_LOGIC_VECTOR(diff_long_64(63 downto 0));
					end if;
					
					-- Word 1 [127:64]
					product_long_64 := signed(rs2(127 downto 96)) * signed(rs3(127 downto 96));
					diff_long_64 := resize(signed(rs1(127 downto 64)), 65) - resize(product_long_64, 65);
					if diff_long_64 > resize(signed_long_64_max, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_max);
					elsif diff_long_64 < resize(signed_long_64_min, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(signed_long_64_min);
					else
						output(127 downto 64) := STD_LOGIC_VECTOR(diff_long_64(63 downto 0));
					end if;
			   --==========================================================================================================--	
			   	when others => 
				   output := (others => '0');
				end case;
			  rd <= output;
		
			-- R3 instructions 
			when "11" =>
			r3_opcode := instruction_format(22 downto 15);
			output := (others => '0');
			
			case r3_opcode(3 downto 0) is
				-- NOP
				when "0000" => 
				rd <= rd;
		      --==========================================================================================================--		
				-- SHRHI
				when "0001" =>
				shift := to_integer(unsigned(instruction_format(13 downto 10)));
					for i in 0 to 7 loop
						output((i*16+15) downto (i*16)) := std_logic_vector(shift_right(unsigned(rs1((i*16+15) downto (i*16))), shift));
					end loop;
				rd <= output;
			 --==========================================================================================================--	
				--AU
				when "0010" =>
				for i in 0 to 3 loop
					w1 := unsigned(rs1((i*32+31) downto (i*32)));
					w2 := unsigned(rs2((i*32+31) downto (i*32)));
					result := w1 + w2;
					reg_result((i*32+31) downto (i*32)) := signed(result);
				end loop;
				
				rd <= std_logic_vector(reg_result);
			 --==========================================================================================================--
				--CNT1H
				when "0011" =>
				cnt := 0;
				
				for i in 0 to 7 loop
					cnt := 0;
					for bit_i in 0 to 15 loop
						if rs1(i*16 + bit_i) = '1' then
							cnt := cnt + 1;
						end if;
					end loop;
					reg_result((i*16+15) downto (i*16)) := to_signed(cnt, 16);
				end loop;
				rd <= std_logic_vector(reg_result);
			 --==========================================================================================================--
				--AHS
				when "0100" =>
				-- Extract 16 bits from each reg, starting from 15 to 0
					for i in 0 to 7 loop
						reg1 := signed(rs1((i*16 + 15) downto (i*16)));
						reg2 := signed(rs2((i*16 + 15) downto (i*16)));
				
					-- add and saturate
					sum := resize(reg1, 17) + resize(reg2, 17);
					if sum > to_signed(32767, 17) then
						-- edit the respective bit positions	 to_signed(integer_value, length)
						reg_result((i*16 + 15) downto (i*16)) :=  to_signed(32767, 16);
				
					elsif sum < to_signed(-32768, 17) then
						reg_result((i*16 + 15) downto (i*16)) := to_signed(-32768,16);
				
					else -- we can use the respective sums
						reg_result((i*16 + 15) downto (i*16)) := resize(sum,16);
					end if;
				end loop;
				rd <= std_logic_vector(reg_result);
			--==========================================================================================================--
				--OR
				when "0101" =>
				rd <= rs1 or rs2;	
			--==========================================================================================================--
				--BCW
				when "0110" =>
				rd(31 downto 0) <= rs1(127 downto 96);
				rd(63 downto 32) <= rs1(127 downto 96);
				rd(95 downto 64) <= rs1(127 downto 96);
				rd(127 downto 96) <= rs1(127 downto 96);
			--==========================================================================================================--	
				--MAXWS
				when "0111" =>
					for i in 0 to 3 loop
						reg3 := signed(rs1((i*32+31) downto (i*32)));
						reg4 := signed(rs2((i*32+31) downto (i*32)));
			
					if reg3 > reg4 then
						reg_result((i*32+31) downto (i*32)) := reg3;
					else
						reg_result((i*32+31) downto (i*32)) := reg4;
					end if;
				end loop;
				rd <= std_logic_vector(reg_result);
			--==========================================================================================================--
				--MINWS
				when "1000" =>
				for i in 0 to 3 loop
						reg3 := signed(rs1((i*32+31) downto (i*32)));
						reg4 := signed(rs2((i*32+31) downto (i*32)));
			
					if reg3 < reg4 then
						reg_result((i*32+31) downto (i*32)) := reg3;
					else
						reg_result((i*32+31) downto (i*32)) := reg4;
					end if;
				end loop;
				rd <= std_logic_vector(reg_result); 
			--==========================================================================================================--
				--MLHU
				when "1001" =>
				for i in 0 to 3 loop
	
					--convert 16 rightmost bits into val
					half_rs1 := unsigned(rs1((i*32+15) downto (i*32)));
					half_rs2 := unsigned(rs2((i*32+15) downto (i*32)));
					
					-- Multiply the 16 rightmost
					product := resize((half_rs1 * half_rs2), 32);
					rd((i*32 + 31) downto (i*32)) <= std_logic_vector(product);
				end loop;
			--==========================================================================================================--	
				--MLHCU
				when "1010" =>									
				w0 := resize(unsigned(instruction_format(14 downto 10)), 16);
				for i in 0 to 3 loop
					w3 := unsigned(rs1((i*32 + 15) downto (i*32)));
					product := resize((w0*w3), 32);
					rd((i*32 + 31) downto (i*32)) <= std_logic_vector(product);
				end loop;
		     --==========================================================================================================--	
				--AND
				when "1011" =>
				rd <= rs1 and rs2;
			--==========================================================================================================--	
				--CLZW
				when "1100" =>
				for i in 0 to 3 loop
					word_val := rs1((i*32 + 31) downto (i*32));
					
					-- counter for # of zeros
					count := 0;
					
					-- all zeros
					if word_val = X"00000000" then
						count := 32;
					else -- need to look for first 1
						for j in 31 downto 0 loop
							if word_val(j) = '0' then
								count := count + 1;
							else -- it is a 1, then STOP
					   			exit;
							end if;
						end loop;
			 		end if;
					rd((i*32 + 31) downto (i*32)) <= std_logic_vector(to_unsigned(count, 32));
				end loop; 
			--==========================================================================================================--	
				--ROTW
				when "1101" =>
				for i in 0 to 3 loop
					rotated_rs1 := rs1((i*32 + 31) downto (i*32)); -- copy 32 orignal into rotated
					num_rot := to_integer(unsigned(rs2((i*32 +4) downto (i*32)))); -- get respective val of 5 bit in each 32 bit
					
					for j in 1 to num_rot loop
						temp_lsb := rotated_rs1(0); -- save the lsb
						rotated_rs1(30 downto 0) := rotated_rs1(31 downto 1); -- shift right 1 by copying
						rotated_rs1(31) := temp_lsb; -- put lsb into the msb
					end loop;
					rd((i*32 + 31) downto (i*32)) <= rotated_rs1;	
				end loop;
			--==========================================================================================================--	
				--SFWU
				when "1110" =>
				for i in 0 to 3 loop
					w1 := unsigned(rs1((i*32 + 31) downto (i*32))); 
					w2 := unsigned(rs2((i*32 + 31) downto (i*32)));
					result := w2 - w1;
					rd((i*32 + 31) downto (i*32)) <= std_logic_vector(result);
				end loop;
			--==========================================================================================================--	
				--SFHS
				when "1111" =>
				for i in 0 to 7 loop
					reg1 := signed(rs1((i*16 + 15) downto (i*16)));
					reg2 := signed(rs2((i*16 + 15) downto (i*16)));
					diff := resize(reg2, 17) - resize(reg1, 17);
					
					if diff > to_signed(32767,17) then -- pos overflow, fix
						reg_result((i*16 + 15) downto (i*16)) := to_signed(32767, 16);
					elsif diff < to_signed(-32768,17) then --neg overflow, fix
						reg_result((i*16 + 15) downto (i*16)) := to_signed(-32768, 16);	
					else -- value works, keep original 
						reg_result((i*16 + 15) downto (i*16)) := resize(diff,16);
					end if;
				end loop;
				rd <= std_logic_vector(reg_result);
			--==========================================================================================================--	
			when others => 
			rd <= (others => '0');
				end case;
			when others =>
				rd <= (others => '0');
			end case;
	end process;
end behavioral;