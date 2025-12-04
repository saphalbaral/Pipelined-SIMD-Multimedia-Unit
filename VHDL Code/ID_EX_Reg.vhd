-------------------------------------------------------------------------------
--
-- Title       : ID_EX_Reg
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/ID_EX_Reg.vhd
-- Generated   : Thu Nov 27 03:12:48 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The ID/EX register stores decoded operands, immediate values, opcode, and control signals from the decode stage
-- and passes them into the execute stage on the next clock cycle.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity ID_EX_Reg is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		
		id_ex_freeze : in STD_LOGIC := '0'; -- Stall control
		
		-- Inputs from Stage 2: Instruction Decode 
		rs1_in : in STD_LOGIC_VECTOR(127 downto 0);
        rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
        rs3_in : in STD_LOGIC_VECTOR(127 downto 0);
		
		rs1_index_in : in unsigned(4 downto 0);
        rs2_index_in : in unsigned(4 downto 0);
        rs3_index_in : in unsigned(4 downto 0);
		
        immediate16_in : in STD_LOGIC_VECTOR(15 downto 0);
        opcode_in : in STD_LOGIC_VECTOR(7 downto 0);
		li_load_index_in : in unsigned(2 downto 0);
		
        rd_index_in : in unsigned(4 downto 0);
        is_li_in : in STD_LOGIC;
        reg_write_in : in STD_LOGIC;
		
		uses_rs1_in : in STD_LOGIC;
		uses_rs2_in : in STD_LOGIC;
		uses_rs3_in : in STD_LOGIC;
		
		instruction_in : in STD_LOGIC_VECTOR(24 downto 0);
        instruction_out : out STD_LOGIC_VECTOR(24 downto 0);
		
		-- Outputs to Stage 3: Execute
		rs1_out : out STD_LOGIC_VECTOR(127 downto 0);
        rs2_out : out STD_LOGIC_VECTOR(127 downto 0);
        rs3_out : out STD_LOGIC_VECTOR(127 downto 0);
		
		rs1_index_out : out unsigned(4 downto 0);
        rs2_index_out : out unsigned(4 downto 0);
        rs3_index_out : out unsigned(4 downto 0);
		
        immediate16_out : out STD_LOGIC_VECTOR(15 downto 0);
        opcode_out : out STD_LOGIC_VECTOR(7 downto 0);
		li_load_index_out : out unsigned(2 downto 0);
		
        rd_index_out : out unsigned(4 downto 0);
        is_li_out : out STD_LOGIC;
        reg_write_out : out STD_LOGIC;
		
		uses_rs1_out : out STD_LOGIC;
		uses_rs2_out : out STD_LOGIC;
		uses_rs3_out : out STD_LOGIC
	);
end ID_EX_Reg;

architecture behavioral of ID_EX_Reg is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				rs1_out <= (others => '0');
				rs2_out <= (others => '0');
				rs3_out <= (others => '0');
				rs1_index_out <= (others => '0');
                rs2_index_out <= (others => '0');
                rs3_index_out <= (others => '0');
				immediate16_out <= (others => '0');
				opcode_out <= (others => '0');
				li_load_index_out <= (others => '0');
				rd_index_out <=	(others => '0');
				is_li_out <= '0';
				reg_write_out <= '0';
				uses_rs1_out <= '0';
    			uses_rs2_out <= '0';
    			uses_rs3_out <= '0';
				instruction_out <= (others => '0');
			elsif id_ex_freeze = '0' then
				rs1_out <= rs1_in;
				rs2_out <= rs2_in;
				rs3_out <= rs3_in;
				rs1_index_out <= rs1_index_in;
                rs2_index_out <= rs2_index_in;
                rs3_index_out <= rs3_index_in;
				immediate16_out <= immediate16_in;
				opcode_out <= opcode_in;
				li_load_index_out <= li_load_index_in;
				rd_index_out <=	rd_index_in;
				is_li_out <= is_li_in;
				reg_write_out <= reg_write_in;
				uses_rs1_out <= uses_rs1_in;
    			uses_rs2_out <= uses_rs2_in;
    			uses_rs3_out <= uses_rs3_in;
				instruction_out <= instruction_in;
			end if;
		end if;
	end process;
end behavioral;