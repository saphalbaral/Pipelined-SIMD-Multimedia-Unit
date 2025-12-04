-------------------------------------------------------------------------------
--
-- Title       : Program_Counter
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/Program_Counter.vhd
-- Generated   : Thu Nov 27 00:36:50 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The program counter holds the current instruction address and updates it every clock cycle unless reset or frozen.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity Program_Counter is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		pc_freeze : in STD_LOGIC; -- input to prevent PC from updating (stalls/bubble)
		pc_out : out unsigned(5 downto 0) -- outputs current instruction address; into pc_addr input of instruction buffer
	);
end Program_Counter;

architecture behavioral of Program_Counter is
	signal pc_current : unsigned(5 downto 0) := (others => '0'); -- holds PC value (starts at 0)
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then -- synchronous reset
				pc_current <= (others => '0'); -- reset to first instruction address
			elsif pc_freeze = '0' then
				pc_current <= pc_current + 1; -- increment PC
			end if;
		end if;
	end process;
	
	pc_out <= pc_current; -- drives instruction buffer address
	
end behavioral;