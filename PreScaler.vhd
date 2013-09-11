----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:09:45 10/07/2011 
-- Design Name: 
-- Module Name:    PreScaler - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PreScaler is
    Port ( Sig_In : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC;
           Factor : in  STD_LOGIC_VECTOR (3 downto 0);
			  clock : in std_logic);
end PreScaler;

architecture Behavioral of PreScaler is
	signal InterCounter : std_logic_vector(14 downto 0);
	signal InterSig_Out : std_logic;
	
	component GateShortener
		 	generic ( 
				NCh : integer
			);  
			Port ( sig_in : in  STD_LOGIC;
				  sig_out : out  STD_LOGIC;
				  clock : in  STD_LOGIC);
	end component;
begin
	GateShortener_1 : GateShortener GENERIC MAP (NCh => 10) PORT MAP (InterSig_Out, Sig_Out, clock);

	InterSig_Out <= Sig_In when Factor = x"0" else
		InterCounter(0) when Factor = x"1" else
		InterCounter(1) when Factor = x"2" else
		InterCounter(2) when Factor = x"3" else
		InterCounter(3) when Factor = x"4" else
		InterCounter(4) when Factor = x"5" else
		InterCounter(5) when Factor = x"6" else
		InterCounter(6) when Factor = x"7" else
		InterCounter(7) when Factor = x"8" else
		InterCounter(8) when Factor = x"9" else
		InterCounter(9) when Factor = x"a" else
		InterCounter(10) when Factor = x"b" else
		InterCounter(11) when Factor = x"c" else
		InterCounter(12) when Factor = x"d" else
		InterCounter(13) when Factor = x"e" else
		'0' when Factor = x"f" else
		'0';
		
	process (Sig_In)
	begin
		if rising_edge(Sig_In) then
			InterCounter <= InterCounter +1;
		end if;
	end process;


end Behavioral;

