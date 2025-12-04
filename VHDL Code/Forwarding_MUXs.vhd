-------------------------------------------------------------------------------
--
-- Title       : Forwarding_MUXs
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/Forwarding_MUXs.vhd
-- Generated   : Thu Nov 27 03:35:19 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The forwarding MUXs prior to the MALU choose between original register values and the newer value
-- from EX/WB when a data hazard is detected. This prevents pipeline stalls by forwarding results directly into the MALU
-- instead of waiting for write-back.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all; 
use work.all;

entity Forwarding_MUXs is
	port(
		-- Inputs from the ID/EX pipeline register (prior data)
		rs1_in : in STD_LOGIC_VECTOR(127 downto 0);
		rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
		rs3_in : in STD_LOGIC_VECTOR(127 downto 0);
		--opcode : in STD_LOGIC_VECTOR(7 downto 0);
		
		-- Inputs from the EX/WB pipeline register (new data)
		EX_WB_res : in STD_LOGIC_VECTOR(127 downto 0);
		--rd_EX_WB_index : in STD_LOGIC_VECTOR(4 downto 0);
		
		-- Forwarding selection signals
		sel_rs1 : in STD_LOGIC;
		sel_rs2 : in STD_LOGIC;
		sel_rs3 : in STD_LOGIC;
		
		-- Output into MALU
		rs1_res : out STD_LOGIC_VECTOR(127 downto 0);
		rs2_res : out STD_LOGIC_VECTOR(127 downto 0);
		rs3_res : out STD_LOGIC_VECTOR(127 downto 0)
	);
end Forwarding_MUXs;

architecture behavioral of Forwarding_MUXs is
begin
	process(all)
	begin
		if sel_rs1 = '1' then
			rs1_res <= EX_WB_res; -- Forward
		else
			rs1_res <= rs1_in; -- Normal
		end if;
		
		if sel_rs2 = '1' then
			rs2_res <= EX_WB_res;
		else
			rs2_res <= rs2_in;
		end if;
		
		if sel_rs3 = '1' then
			rs3_res <= EX_WB_res;
		else
			rs3_res <= rs3_in;
		end if;
	end process;
end behavioral;