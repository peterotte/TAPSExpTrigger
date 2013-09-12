--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.2
--  \   \         Application : xaw2vhdl
--  /   /         Filename : clkbst200to400.vhd
-- /___/   /\     Timestamp : 09/10/2013 12:01:30
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-intstyle C:/Users/otte/Documents/Documents/Dissertation/Hardware Projekte/CB Trigger/CBMaster/clkbst200to400.xaw -st clkbst200to400.vhd
--Design Name: clkbst200to400
--Device: xc4vlx40-11ff1148
--
-- Module clkbst200to400
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity clkbst200to400 is
   port ( CLKIN_IN   : in    std_logic; 
          RST_IN     : in    std_logic; 
          CLK0_OUT   : out   std_logic; 
          CLK2X_OUT  : out   std_logic; 
          LOCKED_OUT : out   std_logic);
end clkbst200to400;

architecture BEHAVIORAL of clkbst200to400 is
   signal CLKFB_IN   : std_logic;
   signal CLK0_BUF   : std_logic;
   signal CLK2X_BUF  : std_logic;
   signal GND_BIT    : std_logic;
   signal GND_BUS_7  : std_logic_vector (6 downto 0);
   signal GND_BUS_16 : std_logic_vector (15 downto 0);
begin
   GND_BIT <= '0';
   GND_BUS_7(6 downto 0) <= "0000000";
   GND_BUS_16(15 downto 0) <= "0000000000000000";
   CLK0_OUT <= CLKFB_IN;
   CLK0_BUFG_INST : BUFG
      port map (I=>CLK0_BUF,
                O=>CLKFB_IN);
   
   CLK2X_BUFG_INST : BUFG
      port map (I=>CLK2X_BUF,
                O=>CLK2X_OUT);
   
   DCM_ADV_INST : DCM_ADV
   generic map( CLK_FEEDBACK => "1X",
            CLKDV_DIVIDE => 2.0,
            CLKFX_DIVIDE => 1,
            CLKFX_MULTIPLY => 4,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => 5.000,
            CLKOUT_PHASE_SHIFT => "NONE",
            DCM_AUTOCALIBRATION => TRUE,
            DCM_PERFORMANCE_MODE => "MAX_SPEED",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "HIGH",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"F0F0",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => TRUE)
      port map (CLKFB=>CLKFB_IN,
                CLKIN=>CLKIN_IN,
                DADDR(6 downto 0)=>GND_BUS_7(6 downto 0),
                DCLK=>GND_BIT,
                DEN=>GND_BIT,
                DI(15 downto 0)=>GND_BUS_16(15 downto 0),
                DWE=>GND_BIT,
                PSCLK=>GND_BIT,
                PSEN=>GND_BIT,
                PSINCDEC=>GND_BIT,
                RST=>RST_IN,
                CLKDV=>open,
                CLKFX=>open,
                CLKFX180=>open,
                CLK0=>CLK0_BUF,
                CLK2X=>CLK2X_BUF,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                DO=>open,
                DRDY=>open,
                LOCKED=>LOCKED_OUT,
                PSDONE=>open);
   
end BEHAVIORAL;

