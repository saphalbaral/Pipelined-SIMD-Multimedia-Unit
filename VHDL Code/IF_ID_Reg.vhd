-------------------------------------------------------------------------------
--
-- Title       : IF_ID_Reg
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/IF_ID_Reg.vhd
-- Generated   : Thu Nov 27 01:21:02 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : THE IF/ID register captures the fetched instruction at the rising clock edge and holds it for the
-- decode stage on the next cycle.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity IF_ID_Reg is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		
		if_id_freeze : in STD_LOGIC; -- Stall control 
		
		instruction_in : in STD_LOGIC_VECTOR(24 downto 0); -- Fetched instruction 
		instruction_out : out STD_LOGIC_VECTOR(24 downto 0) -- Instruction passed to ID
	);
end IF_ID_Reg;

architecture behavioral of IF_ID_Reg is
begin
	process(clk)
	begin
		if rising_edge(clk) then 
			if rst = '1' then -- Reset to flush pipeline
				instruction_out <= (others => '0');
			elsif if_id_freeze = '0' then
				instruction_out <= instruction_in; -- Latch instruction
			end if;
		end if;
	end process;
end behavioral;