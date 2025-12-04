-------------------------------------------------------------------------------
--
-- Title       : EX_WB_Reg
-- Design      : FourStagePipeline
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Design/FourStagePipeline/FourStagePipeline/src/EX_WB_Reg.vhd
-- Generated   : Thu Nov 27 18:24:52 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The EX/WB register holds the ALU result and destination register for writeback as well as
-- suppling data to the Forwarding Unit.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity EX_WB_Reg is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		
		ex_wb_freeze : in STD_LOGIC := '0'; -- Stall control
		
		-- Data coming in from the execute stage
		rd_result_in : in STD_LOGIC_VECTOR(127 downto 0);
		rd_index_in : in unsigned(4 downto 0);
		reg_write_in : in STD_LOGIC;
		
		-- Data going to the Write-Back + Forwarding Unit
		rd_result_out : out STD_LOGIC_VECTOR(127 downto 0);
		rd_index_out : out unsigned(4 downto 0);
		reg_write_out : out STD_LOGIC
	);
end EX_WB_Reg;

architecture behavioral of EX_WB_Reg is
	signal rd_result_reg : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal rd_index_reg : unsigned(4 downto 0) := (others => '0');
    signal reg_write_reg : STD_LOGIC := '0';
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				rd_result_reg <= (others => '0');
				rd_index_reg <= (others => '0');
				reg_write_reg <= '0';
			elsif ex_wb_freeze = '0' then
				rd_result_reg <= rd_result_in;
				rd_index_reg <= rd_index_in;
				reg_write_reg <= reg_write_in;
			end if;
		end if;
	end process;
	
	rd_result_out <= rd_result_reg;
	rd_index_out <= rd_index_reg;
	reg_write_out <= reg_write_reg;
	
end behavioral;