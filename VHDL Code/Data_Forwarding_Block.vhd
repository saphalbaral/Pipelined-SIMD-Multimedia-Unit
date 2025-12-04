-------------------------------------------------------------------------------
--
-- Title       : Data_Forwarding_Block
-- Design      : FourStagePipeline
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Design/FourStagePipeline/FourStagePipeline/src/Data_Forwarding_Block.vhd
-- Generated   : Thu Nov 27 19:30:18 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The block detects the hazards between the previous instruction and the current one by comparing source registers in
-- ID/EX with the destination register in EX/WB. If a match exists and write-back is enabled, it asserts a select line to forward the
-- newer ALU result instead of using stale data.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity Data_Forwarding_Block is
	port(
		id_ex_rs1 : in unsigned(4 downto 0);
		id_ex_rs2 : in unsigned(4 downto 0);
		id_ex_rs3 : in unsigned(4 downto 0);
		
		id_ex_uses_rs1 : in STD_LOGIC;
		id_ex_uses_rs2 : in STD_LOGIC;
		id_ex_uses_rs3 : in STD_LOGIC; -- only used for R4 instructions
		
		-- Inputs from the EX/WB stage
		ex_wb_rd : in unsigned(4 downto 0);
		ex_wb_regWrite : in STD_LOGIC;
		
		-- Outputs driving into the forwarding mux
		sel_rs1 : out STD_LOGIC;
		sel_rs2 : out STD_LOGIC;
		sel_rs3 : out STD_LOGIC
	);
end Data_Forwarding_Block;

architecture behavioral of Data_Forwarding_Block is
begin
	process(all)
	begin
		
		-- Default (no forwarding)
		sel_rs1 <= '0';
		sel_rs2 <= '0';
		sel_rs3 <= '0';
		
		if ex_wb_regWrite = '1' and ex_wb_rd /= "00000" then -- ignore forwrafing from r0 (ex_wb_rd does not equal 00000 = r0)
			-- Forward to rs1
			if id_ex_uses_rs1 = '1' and ex_wb_rd = id_ex_rs1 then
				sel_rs1 <= '1';
            end if;
			-- Forward to rs2
            if id_ex_uses_rs2 = '1' and ex_wb_rd = id_ex_rs2 then
                sel_rs2 <= '1';
            end if;
			-- Forward to rs3 but only if R4 instruction format uses rs3
            if id_ex_uses_rs3 = '1' and ex_wb_rd = id_ex_rs3 then
                sel_rs3 <= '1';
            end if;
		end if;
	end process;
end behavioral;