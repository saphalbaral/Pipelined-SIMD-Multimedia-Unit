-------------------------------------------------------------------------------
--
-- Title       : Instruction_Buffer
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/Instruction_Buffer.vhd
-- Generated   : Thu Nov 27 00:59:41 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The instruction buffer holds 64 x 25-bit instructions and loads instructions from the testbench, returning
-- the instruction indexed by the PC for the IF stage.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity Instruction_Buffer is
	port(
		clk : in STD_LOGIC;
	
		-- Pipeline Read Path:
		-- pc_addr comes from the PC
		-- The instruction is sent into IF/ID pipeline register
		pc_addr : in unsigned(5 downto 0); -- 6-bit PC index (0-63)
		instruction : out STD_LOGIC_VECTOR(24 downto 0); -- 25-bit fetched instruction
		
		-- Testbench Write-Only:
		-- Used only at simulation startup to preload instructions
		-- Does not interfere with pipeline execution
		load_enable : in STD_LOGIC; -- write enable for loading program
		load_addr : in unsigned(5 downto 0); -- instruction memory index to write
		load_data : in STD_LOGIC_VECTOR(24 downto 0) -- instruction to store
	);
end Instruction_Buffer;

architecture behavioral of Instruction_Buffer is
	type instr_memory is array(0 to 63) of std_logic_vector(24 downto 0); -- 64 memory slots x 25-bit instructions
	signal mem : instr_memory := (others => (others => '0')); -- NOP to avoid undefined memory behavior 
begin
	instruction <= mem(to_integer(pc_addr)); -- Asynchronous Read: instruction updates when PC changes
	process(clk)
	begin
		-- Synchronous Write (testbench program loading): Write only on rising clock edge
		if rising_edge(clk) then
			if load_enable = '1' then
				mem(to_integer(load_addr)) <= load_data;
			end if;
		end if;
	end process;
end behavioral;