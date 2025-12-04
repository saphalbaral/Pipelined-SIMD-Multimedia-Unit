-------------------------------------------------------------------------------
--
-- Title       : CPU_tb
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/CPU_tb.vhd
-- Generated   : Sun Nov 30 01:00:28 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Top level testbench to test the operation of the entire pipeline.
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity CPU_tb is
end CPU_tb;

architecture sim of CPU_tb is

    -- File for input program
    file program_file : text open read_mode is "program.txt";

    -- DUT Signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- Instruction buffer load interface
    signal load_enable : std_logic := '0';
    signal load_addr : unsigned(5 downto 0) := (others => '0');
    signal load_data : std_logic_vector(24 downto 0) := (others => '0');

    -- DUT execution runtime control
    constant TOTAL_CYCLES : integer := 200;

begin
	
	-- Clock generation
    clk_gen : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    DUT : entity work.CPU_Top_Level
        port map(
            clk => clk,
            rst => rst,
			load_enable => load_enable,
			load_addr => load_addr,
			load_data => load_data
        );

    -- Loads program.txt into instruction memory before pipeline runs
    load_proc : process
        variable L : line;
        variable instr : std_logic_vector(24 downto 0);
    begin
        -- Hold reset during instruction loading
        rst <= '1';
        load_enable <= '1';
        wait for 20 ns;
		
        -- Read file line-by-line and load into instruction buffer
        load_addr <= (others => '0');

        while not endfile(program_file) loop
            readline(program_file, L);
            read(L, instr);
            load_data <= instr;

            wait until rising_edge(clk);
            load_addr <= load_addr + 1;
        end loop;

        load_enable <= '0'; 
        wait for 20 ns;

        -- Release reset, CPU begins executing normally
        rst <= '0';
        report "PROGRAM LOADED. PIPELINE STARTING EXECUTION.";
        wait;

    end process;
	
	-- Run for n cycles then print register results
    finish_proc : process
    begin
        wait for TOTAL_CYCLES * 10 ns;

        report "======================= CPU FINISHED =======================";

        -- Read the register file contents (final register dump)
        for r in 0 to 31 loop
            report "R" & integer'image(r) & " = <view in waveform>";
        end loop;

        report "============================================================";
        wait;
    end process;

end sim;