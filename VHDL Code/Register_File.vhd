-------------------------------------------------------------------------------
--
-- Title       : Register_File
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/Register_File.vhd
-- Generated   : Thu Nov 27 01:41:59 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The register file stores 32 x 128-bit registers, reads values for the decode stage, write back
-- one result each cycle, and use bypass logic so newer values are read immediately.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity Register_File is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		
		-- Read register numbers
		rs1_index : in unsigned(4 downto 0); 
		rs2_index : in unsigned(4 downto 0); 
		rs3_index : in unsigned(4 downto 0);
		
		-- Read register outputs
		rs1_data : out STD_LOGIC_VECTOR(127 downto 0);
        rs2_data : out STD_LOGIC_VECTOR(127 downto 0);
        rs3_data : out STD_LOGIC_VECTOR(127 downto 0);
		
		-- Write-back port
		rd_index : in unsigned(4 downto 0);
		rd_data : in STD_LOGIC_VECTOR(127 downto 0);
		reg_write : in STD_LOGIC
	);
end Register_File;

architecture behavioral of Register_File is
	type reg_array is array(0 to 31) of std_logic_vector(127 downto 0); -- 32 x 128-bit registers
	signal regs : reg_array := (others => (others => '0')); -- Initialize all to zero
begin
	-- Asynchronous Read w/ Write-Bypass
	-- Checks if a register is being written and read in the same cycle, and if so, returns the new write value instead of the old stored value 
	process (rs1_index, rs2_index, rs3_index, regs, rd_index, rd_data, reg_write)
	begin
		rs1_data <= regs(to_integer(rs1_index));
        rs2_data <= regs(to_integer(rs2_index));
        rs3_data <= regs(to_integer(rs3_index));
		
		if reg_write = '1' then
			if rd_index = rs1_index then 
				rs1_data <= rd_data; 
			end if;
            if rd_index = rs2_index then 
				rs2_data <= rd_data; 
			end if;
            if rd_index = rs3_index then 
				rs3_data <= rd_data; 
			end if;
        end if;
    end process;
	
	-- Synchronous Write
	-- Writes occur only on rising clock edge and when reg_write is 1
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				regs <= (others => (others => '0'));
			elsif reg_write = '1' then
				regs(to_integer(rd_index)) <= rd_data;
			end if;
		end if;
	end process;
end behavioral;