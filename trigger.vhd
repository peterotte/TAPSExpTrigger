--
-- Peter-Bernd Otte
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all; --  for bufg

entity trigger is
	port (
		clock50 : in STD_LOGIC;
		clock100 : in STD_LOGIC;
		clock200 : in STD_LOGIC;
		clock400 : in STD_LOGIC; 
		clock1 : in STD_LOGIC;
		clock0_5 : in STD_LOGIC;
		trig_in : in STD_LOGIC_VECTOR (32*4-1 downto 0);		
		trig_out_OUT1 : out STD_LOGIC_VECTOR (31 downto 0); --To LVDS to NIM converter
		trig_out_INOUT2 : out STD_LOGIC_VECTOR (31 downto 0); -- To LVDS->NIM Converter fpr CPUs
		trig_out_INOUT3 : out STD_LOGIC_VECTOR (31 downto 0); -- To Multiplicity Trigger
		trig_out_INOUT4 : out STD_LOGIC_VECTOR (31 downto 0); -- To CB Exp Trigger
		nim_in   : in  STD_LOGIC;
		nim_out  : out STD_LOGIC;
		TAPSActualMode_Out : out STD_LOGIC;
		ToScalerOut : out STD_LOGIC_VECTOR(95 downto 0);
		led	     : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs onboard
		pgxled   : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs on PIG board
		Global_Reset_After_Power_Up : in std_logic;
--............................. vme interface ....................
		u_ad_reg :in std_logic_vector(11 downto 2);
		u_dat_in :in std_logic_vector(31 downto 0);
		u_data_o :out std_logic_vector(31 downto 0);
		oecsr, ckcsr:in std_logic
	);
end trigger;


architecture RTL of trigger is

	subtype sub_Address is std_logic_vector(11 downto 4);
	constant BASE_TRIG_FIXED : sub_Address 									:= x"f0" ; -- r
	constant TRIG_FIXED_Master : std_logic_vector(31 downto 0)  		:= x"1311120b";

	constant BASE_TRIG_TAPSActualMode : sub_Address							:= x"30"; --r/w
	constant BASE_TRIG_TAPSDebugSignals : sub_Address						:= x"31"; --r
	
	constant BASE_TRIG_CFDSectorMask : sub_Address 							:= x"20"; -- r/w
	constant BASE_TRIG_LED1SectorMask : sub_Address 						:= x"21"; -- r/w
	constant BASE_TRIG_LED2SectorMask : sub_Address 						:= x"22"; -- r/w
	constant BASE_TRIG_VETOSectorMask : sub_Address 						:= x"23"; -- r/w
	constant BASE_TRIG_PWOSectorMask : sub_Address 							:= x"24"; -- r/w
	constant BASE_TRIG_PWOVETOSectorMask : sub_Address 					:= x"25"; -- r/w
	constant BASE_TRIG_PreScaleFactor_CFD_OR : sub_Address				:= x"10"; -- r/w
	constant BASE_TRIG_PreScaleFactor_LED1_OR : sub_Address				:= x"11"; -- r/w
	constant BASE_TRIG_PreScaleFactor_LED2_OR : sub_Address				:= x"12"; -- r/w
	constant BASE_TRIG_PreScaleFactor_VETO_OR : sub_Address				:= x"13"; -- r/w
	constant BASE_TRIG_PreScaleFactor_CFD_M2Plus : sub_Address			:= x"14"; -- r/w
	constant BASE_TRIG_PreScaleFactor_LED1_M2Plus : sub_Address			:= x"15"; -- r/w
	constant BASE_TRIG_PreScaleFactor_LED2_M2Plus : sub_Address			:= x"16"; -- r/w
	constant BASE_TRIG_PreScaleFactor_VETO_M2Plus : sub_Address			:= x"17"; -- r/w
	constant BASE_TRIG_PreScaleFactor_Pulser : sub_Address				:= x"18"; -- r/w
	constant BASE_TRIG_PreScaleFactor_PWO_OR : sub_Address				:= x"19"; -- r/w
	constant BASE_TRIG_PreScaleFactor_PWO_M2Plus : sub_Address			:= x"1a"; -- r/w
	constant BASE_TRIG_PreScaleFactor_PWO_VETO_OR : sub_Address			:= x"1b"; -- r/w
	constant BASE_TRIG_PreScaleFactor_PWO_VETO_M2Plus : sub_Address	:= x"1c"; -- r/w

	--Readout / Total Dead Time
	constant BASE_TRIG_SelectIncludeCPU : sub_Address							:= x"40"; --r/w
	constant BASE_TRIG_DisableTriggerSignal : sub_Address						:= x"41"; --r/w
	constant BASE_TRIG_ResetVMEbusCPUsState : sub_Address 					:= x"43"; --w   <-- write a 0x1 to it
	constant BASE_TRIG_SingleVMECPUsReadoutComplete_Local : sub_Address 	:= x"45"; --w  <-- acts like ACK of CBD
	constant BASE_TRIG_ExpTrigger_Delayed_Local : sub_Address 				:= x"46"; --r  <-- acts like INT of CBD
	--Delay: CPU Interrupt Signals
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_0 : sub_Address		:= x"50"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_1 : sub_Address		:= x"51"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_2 : sub_Address		:= x"52"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_3 : sub_Address		:= x"53"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_4 : sub_Address		:= x"54"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_5 : sub_Address		:= x"55"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_6 : sub_Address		:= x"56"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_7 : sub_Address		:= x"57"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_8 : sub_Address		:= x"58"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_9 : sub_Address		:= x"59"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_10 : sub_Address		:= x"5A"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_11 : sub_Address		:= x"5b"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_12 : sub_Address		:= x"5c"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_13 : sub_Address		:= x"5d"; --r/w

	--debug
	constant BASE_TRIG_Debug_ActualState : sub_Address							:= x"e0"; --r
	constant BASE_TRIG_SelectedDebugInput_1 : sub_Address						:= x"e1"; --r/w
	constant BASE_TRIG_SelectedDebugInput_2 : sub_Address						:= x"e2"; --r/w
	constant BASE_TRIG_SelectedDebugInput_3 : sub_Address						:= x"e3"; --r/w
	constant BASE_TRIG_SelectedDebugInput_4 : sub_Address						:= x"e4"; --r/w

	--Event ID
	constant BASE_TRIG_EventID_SetUserEventID : sub_Address					:= x"a0"; --r
	constant BASE_TRIG_EventID_ResetSending : sub_Address						:= x"a1"; --w  --write 1 to it to reset
	constant BASE_TRIG_EventID_ReadStatus : sub_Address						:= x"a2"; --r  

	------------------------------------------------------------------------------
	
	component GateShortener
		 	generic ( 
				NCh : integer
			);  
			Port ( sig_in : in  STD_LOGIC;
				  sig_out : out  STD_LOGIC;
				  clock : in  STD_LOGIC);
	end component;
	
	component Multiplicity2Plus
    Port ( Sig_In : in  STD_LOGIC_VECTOR (5 downto 0);
           M1Plus : out  STD_LOGIC;
           M2Plus : out  STD_LOGIC);
	end component;
	
	component PreScaler
    Port ( Sig_In : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC;
           Factor : in  STD_LOGIC_VECTOR (3 downto 0);
			  clock : in std_logic);
	end component;
	
	component Pulser
		generic (
			DividingPower : integer;
			OutputWidth : integer
			);
		 Port ( clock : in  STD_LOGIC;
				  Sig_Out : out  STD_LOGIC);
	end component;
	
	-----------------------------------------------------------------------------
	-- All CPUs Readout
	constant NVMEbusChs : integer := 14;
	signal SingleVMECPUsReadoutComplete, SelectIncludeCPU : std_logic_vector(NVMEbusChs-1 downto 0);
	signal BusyAllCPUs_Signal : std_logic;
	signal ReadoutCompleteReset_Signal : std_logic;
	signal ResetVMEbusCPUsState : std_logic;
	signal SingleVMECPUsBusy : std_logic_vector(NVMEbusChs-1 downto 0);
	--For VMECPU AcquRoot
	signal SingleVMECPUsReadoutComplete_Local : std_logic; --needs to be w via VME
	signal ExpTrigger_Delayed_Local : std_logic; --needs r via VME

	COMPONENT AllCPUs
		generic (
			NVMEbusChs : integer
		);
    Port ( ExpTriggerIn : in  STD_LOGIC;
				Interrupt_Delayed : out std_logic_vector(NVMEbusChs-1 downto 0);
			  SingleVMECPUsReadoutComplete : in  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
           ReadoutCompleteReset : out  STD_LOGIC;
			  Reset : in std_logic;
			  SingleVMECPUsBusy : out  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectIncludeCPU : in  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectInterruptDelayTimes : in std_logic_vector(NVMEbusChs*16-1 downto 0);
           VMECPUsBusy : out  STD_LOGIC;
			  clock100 : in  std_logic;
			  Debug_Out : out std_logic_vector(NVMEbusChs-1 downto 0));
	end COMPONENT;
	--Delay of Interrupt signals to CPUs
	signal CPUInterruptSignalsDelayTime : std_logic_vector(16*NVMEbusChs-1 downto 0);
	COMPONENT DelayByCounterFixedWidth
		Generic (
			OutputTime : integer := 4
		);
		 Port ( Clock : in  STD_LOGIC;
				  Input : in  STD_LOGIC;
					DelayTime : in STD_LOGIC_VECTOR(15 downto 0);
				  ExternalReset : in std_logic;
				  DelayedOutput : out  STD_LOGIC);
	end COMPONENT;
	signal CPUInterruptSignalsDelayed : std_logic_vector(NVMEbusChs-1 downto 0);

	----------------------------------------------------------------------------------
	--Total Dead Time
	signal TAPSTotalDeadTime_Signal : std_logic;
	signal TAPSDisableTriggerSignal : std_logic := '1';

	----------------------------------------------------------------------------------

	------------------------------------------------------------------------------
	-- DebugChSelector

	COMPONENT DebugChSelector
	PORT(
		DebugSignalsIn : IN std_logic_vector(479 downto 0);
		SelectedInput : IN std_logic_vector(8 downto 0);          
		SelectedOutput : OUT std_logic
		);
	END COMPONENT;

	constant NDebugSignalOutputs : integer := 4;
	signal DebugSignals : std_logic_vector(479 downto 0);
	signal SelectedDebugInput : std_logic_vector(9*NDebugSignalOutputs-1 downto 0);
	signal Debug_ActualState : std_logic_vector(NDebugSignalOutputs-1 downto 0);

	signal Inter_ToScalerOut : std_logic_vector(95 downto 0);
	------------------------------------------------------------------------------


	------------------------------------------------------------------------------
	-- EventID Sender
	signal EventID_UserEventID : std_logic_vector(31 downto 0);
	signal EventID_ResetSenderCounter : std_logic;
	signal EventID_StatusCounter : std_logic_vector(6 downto 0);
	signal EventID_OutputPin, EventID_FromExpTrigger : std_logic;

	COMPONENT EventIDSender
	PORT(
		UserEventID : IN std_logic_vector(31 downto 0);
		ResetSenderCounter : IN std_logic;
		clock50 : IN std_logic;          
		StatusCounter : OUT std_logic_vector(6 downto 0);
		OutputPin : OUT std_logic
		);
	END COMPONENT;
	----------------------------------------------------------------------------------------------


	--Enable L1 Signals
	signal CFDSectorMask, LED1SectorMask, LED2SectorMask, VetoSectorMask, PWOSectorMask, PWOVetoSectorMask : std_logic_vector(5 downto 0) := "111111";

	--L1 Signals
	signal Pre_CFD_SectorORs, Pre_LED1_SectorORs, Pre_LED2_SectorORs, Pre_Veto_SectorORs, Pre_PWO_SectorORs, Pre_PWO_Veto_SectorORs : std_logic_vector(5 downto 0); -- Before SectorMask
	signal CFD_SectorORs, LED1_SectorORs, LED2_SectorORs, Veto_SectorORs, PWO_SectorORs, PWO_Veto_SectorORs : std_logic_vector(5 downto 0);
		
	signal CFD_TAPSOR, LED1_TAPSOR, LED2_TAPSOR, VETO_TAPSOR, 
		CFD_TAPSM2Plus, LED1_TAPSM2Plus, LED2_TAPSM2Plus, Veto_TAPSM2Plus,
		PulserOutput,
		PWO_TAPSOR, PWO_Veto_TAPSOR, 
		PWO_TAPSM2Plus, PWO_Veto_TAPSM2Plus : std_logic;
	signal LED2_TAPSM2Plus_Short : std_logic;

	signal PulserOutput_PreScaled,
		CFD_TAPSOR_PreScaled, LED1_TAPSOR_PreScaled, LED2_TAPSOR_PreScaled, Veto_TAPSOR_PreScaled,
		CFD_TAPSM2Plus_PreScaled, LED1_TAPSM2Plus_PreScaled, LED2_TAPSM2Plus_PreScaled, Veto_TAPSM2Plus_PreScaled,
		PWO_TAPSOR_PreScaled, PWO_Veto_TAPSOR_PreScaled, 
		PWO_TAPSM2Plus_PreScaled, PWO_Veto_TAPSM2Plus_PreScaled : std_logic; -- After Prescaler
	
	signal PreScaleFactor_CFD_OR, PreScaleFactor_LED1_OR, PreScaleFactor_LED2_OR, PreScaleFactor_Veto_OR,
		PreScaleFactor_CFD_M2Plus, PreScaleFactor_LED1_M2Plus, PreScaleFactor_LED2_M2Plus, PreScaleFactor_Veto_M2Plus,
		PreScaleFactor_Pulser,
		PreScaleFactor_PWO_OR, PreScaleFactor_PWO_M2PLUS, PreScaleFactor_PWO_VETO_OR, PreScaleFactor_PWO_VETO_M2PLUS	: std_logic_vector(3 downto 0) := x"f";
	
	--
	signal TAPSActualMode : std_logic := '0'; --0 = Stand alone, 1 = coupled mode
	signal TAPSDebugSignals : std_logic_vector(31 downto 0); --0 used for status of BusyAllCPUs_Signal

	signal CBInterrupt, TAPSInterrupt : std_logic;
	signal PulserOutput_PreScaled_ExtDelayed : std_logic;
	signal TAPS_L1_Trigger : std_logic; --if TAPS saw an L1 event
	signal TAPS_L1_Interrupt : std_logic;
	signal TAPS_L1_Interrupt_Delayed : std_logic; --delayed outside the VUPROM module
	
begin
	----------------------------------------------------------------------------------------------
	-- EventID Sender

	Inst_EventIDSender: EventIDSender PORT MAP(
		StatusCounter => EventID_StatusCounter,
		UserEventID => EventID_UserEventID,
		ResetSenderCounter => EventID_ResetSenderCounter,
		OutputPin => EventID_OutputPin,
		clock50 => clock50
	);
	
	EventID_FromExpTrigger <= trig_in(3*32+31);
	trig_out_INOUT2(31) <= EventID_OutputPin when (TAPSActualMode = '0') else EventID_FromExpTrigger;
	----------------------------------------------------------------------------------------------


	CBInterrupt <= nim_in;
	TAPS_L1_Interrupt_Delayed <= trig_in(11+16*1); --NIM_IN, Sector B
	PulserOutput_PreScaled_ExtDelayed <= trig_in(11+16*5); --NIM_IN, Sector F
	
	------------------------------------------------------------------------------------------------
	-- Collect Sector ORs
	Pre_CFD_SectorORs  <= trig_in(0+5*16) & trig_in(0+4*16) & trig_in(0+3*16) & trig_in(0+2*16) & trig_in(0+1*16) & trig_in(0+0*16);
	Pre_LED1_SectorORs <= trig_in(1+5*16) & trig_in(1+4*16) & trig_in(1+3*16) & trig_in(1+2*16) & trig_in(1+1*16) & trig_in(1+0*16);
	Pre_LED2_SectorORs <= trig_in(2+5*16) & trig_in(2+4*16) & trig_in(2+3*16) & trig_in(2+2*16) & trig_in(2+1*16) & trig_in(2+0*16);
	Pre_Veto_SectorORs <= trig_in(3+5*16) & trig_in(3+4*16) & trig_in(3+3*16) & trig_in(3+2*16) & trig_in(3+1*16) & trig_in(3+0*16);
	Pre_PWO_SectorORs  <= trig_in(4+5*16) & trig_in(4+4*16) & trig_in(4+3*16) & trig_in(4+2*16) & trig_in(4+1*16) & trig_in(4+0*16);
	Pre_PWO_Veto_SectorORs <= trig_in(5+5*16) & trig_in(5+4*16) & trig_in(5+3*16) & trig_in(5+2*16) & trig_in(5+1*32) & trig_in(5+0*16);
	
	 
	--Apply mask for individual sectors
	CFD_SectorORs <= Pre_CFD_SectorORs and CFDSectorMask;
	LED1_SectorORs <= Pre_LED1_SectorORs and LED1SectorMask;
	LED2_SectorORs <= Pre_LED2_SectorORs and LED2SectorMask;
	VETO_SectorORs <= Pre_Veto_SectorORs and VetoSectorMask;
	PWO_SectorORs <= Pre_PWO_SectorORs and PWOSectorMask;
	PWO_Veto_SectorORs <= Pre_PWO_Veto_SectorORs and PWOVetoSectorMask;

	--To Scalers
	Inter_ToScalerOut(5+6*0+32 downto 0+6*0+32) <= CFD_SectorORs;
	Inter_ToScalerOut(5+6*1+32 downto 0+6*1+32) <= LED1_SectorORs;
	Inter_ToScalerOut(5+6*2+32 downto 0+6*2+32) <= LED2_SectorORs;
	Inter_ToScalerOut(5+6*3+32 downto 0+6*3+32) <= VETO_SectorORs;
	Inter_ToScalerOut(5+6*4+32 downto 0+6*4+32) <= PWO_SectorORs;
	Inter_ToScalerOut(5+6*5+32 downto 0+6*5+32) <= PWO_Veto_SectorORs;

	------------------------------------------------------------------------------------------------
	-- Multiplicity and BigOR logic
	M2Plus_CFD 		: Multiplicity2Plus Port MAP (Sig_In => CFD_SectorORs, M1Plus => CFD_TAPSOR, M2Plus => CFD_TAPSM2Plus);
	M2Plus_LED1 	: Multiplicity2Plus Port MAP (Sig_In => LED1_SectorORs, M1Plus => LED1_TAPSOR, M2Plus => LED1_TAPSM2Plus);
	M2Plus_LED2 	: Multiplicity2Plus Port MAP (Sig_In => LED2_SectorORs, M1Plus => LED2_TAPSOR, M2Plus => LED2_TAPSM2Plus);
	M2Plus_Veto 	: Multiplicity2Plus Port MAP (Sig_In => Veto_SectorORs, M1Plus => Veto_TAPSOR, M2Plus => Veto_TAPSM2Plus);
	M2Plus_PWO  	: Multiplicity2Plus Port MAP (Sig_In => PWO_SectorORs, M1Plus => PWO_TAPSOR, M2Plus => PWO_TAPSM2Plus);
	M2Plus_PWO_Veto : Multiplicity2Plus Port MAP (Sig_In => PWO_Veto_SectorORs, M1Plus => PWO_Veto_TAPSOR, M2Plus => PWO_Veto_TAPSM2Plus);
	
	------------------------------------------------------------------------------------------------
	-- Generate Pulser
	PedestalPulser : Pulser Generic Map (DividingPower => 13, OutputWidth => 10) Port Map (clock => clock50, Sig_Out => PulserOutput);
	
	------------------------------------------------------------------------------------------------
	-- Prescaler logic
	CFD_TAPSOR_Prescaler : PreScaler 			Port MAP ( Sig_In => CFD_TAPSOR, 		Sig_Out => CFD_TAPSOR_PreScaled, 		Factor => PreScaleFactor_CFD_OR, clock=>clock100);
	LED1_TAPSOR_Prescaler :	PreScaler 			Port MAP ( Sig_In => LED1_TAPSOR, 		Sig_Out => LED1_TAPSOR_PreScaled, 		Factor => PreScaleFactor_LED1_OR, clock=>clock100);
	LED2_TAPSOR_Prescaler :	PreScaler 			Port MAP ( Sig_In => LED2_TAPSOR, 		Sig_Out => LED2_TAPSOR_PreScaled, 		Factor => PreScaleFactor_LED2_OR, clock=>clock100);
	Veto_TAPSOR_Prescaler :	PreScaler 			Port MAP ( Sig_In => Veto_TAPSOR, 		Sig_Out => Veto_TAPSOR_PreScaled, 		Factor => PreScaleFactor_Veto_OR, clock=>clock100);
	PWO_TAPSOR_Prescaler :	PreScaler 			Port MAP ( Sig_In => PWO_TAPSOR, 		Sig_Out => PWO_TAPSOR_PreScaled, 		Factor => PreScaleFactor_PWO_OR, clock=>clock100);
	PWO_Veto_TAPSOR_Prescaler : PreScaler 		Port MAP ( Sig_In => PWO_Veto_TAPSOR, 	Sig_Out => PWO_Veto_TAPSOR_PreScaled, 	Factor => PreScaleFactor_PWO_VETO_OR, clock=>clock100);

	CFD_TAPSM2Plus_Prescaler : PreScaler 		Port MAP ( Sig_In => CFD_TAPSM2Plus, 		Sig_Out => CFD_TAPSM2Plus_PreScaled, 		Factor => PreScaleFactor_CFD_M2Plus, clock=>clock100);
	LED1_TAPSM2Plus_Prescaler : PreScaler 		Port MAP ( Sig_In => LED1_TAPSM2Plus, 		Sig_Out => LED1_TAPSM2Plus_PreScaled, 		Factor => PreScaleFactor_LED1_M2Plus, clock=>clock100);
	LED2_TAPSM2Plus_Prescaler : PreScaler 		Port MAP ( Sig_In => LED2_TAPSM2Plus, 		Sig_Out => LED2_TAPSM2Plus_PreScaled, 		Factor => PreScaleFactor_LED2_M2Plus, clock=>clock100);
	Veto_TAPSM2Plus_Prescaler : PreScaler 		Port MAP ( Sig_In => Veto_TAPSM2Plus, 		Sig_Out => Veto_TAPSM2Plus_PreScaled, 		Factor => PreScaleFactor_Veto_M2Plus, clock=>clock100);
	PWO_TAPSM2Plus_Prescaler : PreScaler 		Port MAP ( Sig_In => PWO_TAPSM2Plus, 		Sig_Out => PWO_TAPSM2Plus_PreScaled, 		Factor => PreScaleFactor_PWO_M2PLUS, clock=>clock100);
	PWo_Veto_TAPSM2Plus_Prescaler : PreScaler Port MAP ( Sig_In => PWO_Veto_TAPSM2Plus, Sig_Out => PWO_Veto_TAPSM2Plus_PreScaled, Factor => PreScaleFactor_PWO_VETO_M2PLUS, clock=>clock100);

	PulserOutput_Prescaler : PreScaler 		Port MAP ( Sig_In => PulserOutput, 		Sig_Out => PulserOutput_PreScaled, 		Factor => PreScaleFactor_Pulser, clock=>clock100);
	------------------------------------------------------------------------------------------------
		
		
	TAPS_L1_Trigger <= PulserOutput_PreScaled_ExtDelayed or 
		Veto_TAPSM2Plus_PreScaled or LED2_TAPSM2Plus_PreScaled or LED1_TAPSM2Plus_PreScaled or CFD_TAPSM2Plus_PreScaled or 
		Veto_TAPSOR_PreScaled or LED2_TAPSOR_PreScaled or LED1_TAPSOR_PreScaled or CFD_TAPSOR_PreScaled or
		PWO_TAPSOR_PreScaled or PWO_Veto_TAPSOR_PreScaled or PWO_TAPSM2Plus_PreScaled or PWO_Veto_TAPSM2Plus_PreScaled;
	
	TAPS_L1_Interrupt <= TAPS_L1_Trigger when (TAPSTotalDeadTime_Signal = '0') else '0';
		
	TAPSInterrupt <= TAPS_L1_Interrupt_Delayed when (TAPSActualMode = '0') else
		CBInterrupt when (TAPSActualMode = '1')
		else '0';
		
	------------------------------------------------------------------------------------------------
	-- Outputs
	GateShortener_NIMOut : GateShortener GENERIC MAP (NCh => 40) PORT MAP (LED2_TAPSM2Plus, LED2_TAPSM2Plus_Short, clock200); --NCh ==4 -> Length 4*clock+1*clock as jitter

	trig_out_OUT1(0) <= CFD_TAPSOR;
	trig_out_OUT1(1) <= LED1_TAPSOR;
	trig_out_OUT1(2) <= LED2_TAPSM2Plus;
	trig_out_OUT1(3) <= BusyAllCPUs_Signal;
	trig_out_OUT1(4) <= TAPSActualMode;
	trig_out_OUT1(5) <= TAPSTotalDeadTime_Signal;
	trig_out_OUT1(12 downto 6) <= PulserOutput_PreScaled & PulserOutput_PreScaled & PulserOutput_PreScaled & PulserOutput_PreScaled & 
		PulserOutput_PreScaled & PulserOutput_PreScaled & PulserOutput_PreScaled;
	trig_out_OUT1(25 downto 13) <= TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & 
		TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt & TAPSInterrupt;
	trig_out_OUT1(26) <= CFD_TAPSOR_PreScaled;
	trig_out_OUT1(27) <= LED1_TAPSOR_PreScaled;
	trig_out_OUT1(28) <= LED2_TAPSM2Plus_PreScaled; --LED2_TAPSM2Plus;
	trig_out_OUT1(29) <= LED2_TAPSM2Plus_Short;
	trig_out_OUT1(30) <= TAPS_L1_Trigger;
	trig_out_OUT1(31) <= TAPS_L1_Interrupt;

	nim_out <= LED2_TAPSM2Plus_Short;
	TAPSActualMode_Out <= TAPSActualMode;
	
	--Signals to CB Exp. Trigger
	trig_out_INOUT4(5 downto 0) <= LED1_SectorORs;
	trig_out_INOUT4(6+5 downto 6) <= PWO_SectorORs;
	trig_out_INOUT4(12+5 downto 12) <= VETO_SectorORs;
	trig_out_INOUT4(18+5 downto 18) <= PWO_Veto_SectorORs;
	trig_out_INOUT4(27 downto 24) <= Debug_ActualState;
	trig_out_INOUT4(28) <= TAPSInterrupt;
	trig_out_INOUT4(29) <= LED2_TAPSM2Plus_Short;
	trig_out_INOUT4(30) <= PulserOutput_PreScaled_ExtDelayed;
	trig_out_INOUT4(31) <= BusyAllCPUs_Signal;

	--Signals to Multiplicity Trigger
	trig_out_INOUT3(5+6*0 downto 6*0) <= CFD_SectorORs;
	trig_out_INOUT3(5+6*1 downto 6*1) <= LED1_SectorORs;
	trig_out_INOUT3(5+6*2 downto 6*2) <= LED2_SectorORs;
	trig_out_INOUT3(5+6*3 downto 6*3) <= PWO_SectorORs;
	trig_out_INOUT3(31 downto 6*4) <= (others => '0');

	
	-- output to scalers
	Inter_ToScalerOut(0) <= BusyAllCPUs_Signal;
	Inter_ToScalerOut(1) <= CBInterrupt;
	Inter_ToScalerOut(2) <= CFD_TAPSOR;
	Inter_ToScalerOut(3) <= LED1_TAPSOR;
	Inter_ToScalerOut(4) <= LED2_TAPSOR;
	Inter_ToScalerOut(5) <= CFD_TAPSM2Plus;
	Inter_ToScalerOut(6) <= LED1_TAPSM2Plus;
	Inter_ToScalerOut(7) <= LED2_TAPSM2Plus;
	Inter_ToScalerOut(8) <= PulserOutput;
	Inter_ToScalerOut(9) <= CFD_TAPSOR_PreScaled;
	Inter_ToScalerOut(10) <= LED1_TAPSOR_PreScaled;
	Inter_ToScalerOut(11) <= LED2_TAPSOR_PreScaled;
	Inter_ToScalerOut(12) <= CFD_TAPSM2Plus_PreScaled;
	Inter_ToScalerOut(13) <= LED1_TAPSM2Plus_PreScaled;
   Inter_ToScalerOut(14) <= LED2_TAPSM2Plus_PreScaled;
	Inter_ToScalerOut(15) <= PulserOutput_PreScaled;
	Inter_ToScalerOut(16) <= TAPS_L1_Trigger;
	Inter_ToScalerOut(17) <= TAPS_L1_Interrupt;
	Inter_ToScalerOut(18) <= TAPSInterrupt;
	Inter_ToScalerOut(19) <= TAPSActualMode;
	Inter_ToScalerOut(20) <= PWO_Veto_TAPSM2Plus_PreScaled;
	Inter_ToScalerOut(21) <= Veto_TAPSOR;
	Inter_ToScalerOut(22) <= Veto_TAPSM2Plus;
	Inter_ToScalerOut(23) <= Veto_TAPSOR_PreScaled;
	Inter_ToScalerOut(24) <= Veto_TAPSM2Plus_PreScaled;
	Inter_ToScalerOut(25) <= PWO_TAPSOR;
	Inter_ToScalerOut(26) <= PWO_Veto_TAPSOR;
	Inter_ToScalerOut(27) <= PWO_TAPSM2Plus;
	Inter_ToScalerOut(28) <= PWO_Veto_TAPSM2Plus;
	Inter_ToScalerOut(29) <= PWO_TAPSOR_PreScaled;
	Inter_ToScalerOut(30) <= PWO_Veto_TAPSOR_PreScaled;
	Inter_ToScalerOut(31) <= PWO_TAPSM2Plus_PreScaled;
	
	ToScalerOut <= Inter_ToScalerOut;
	
	DebugSignals(4*32-1 downto 0) <= trig_in;
	DebugSignals(4*32) <= NIM_IN;
	DebugSignals(200+95 downto 200) <= Inter_ToScalerOut;
	
	TAPSDebugSignals(0) <= BusyAllCPUs_Signal;
	TAPSDebugSignals(1) <= CBInterrupt;


	-----------------------------------------------------------------------------------------------
	-- AllCPUs Readout
	SingleVMECPUsReadoutComplete <= SingleVMECPUsReadoutComplete_Local & trig_in(32*3+(NVMEbusChs-1)-1 downto 32*3);  --INOUT 1
	DebugSignals(143+(NVMEbusChs-1) downto 143) <= SingleVMECPUsReadoutComplete;
	
	Inst_AllCPUs: AllCPUs GENERIC MAP(
		NVMEbusChs => NVMEbusChs
	) PORT MAP(
		ExpTriggerIn => TAPSInterrupt,
		Interrupt_Delayed => CPUInterruptSignalsDelayed,
		SingleVMECPUsReadoutComplete => SingleVMECPUsReadoutComplete,
		ReadoutCompleteReset => ReadoutCompleteReset_Signal,
		Reset => ResetVMEbusCPUsState, --for debug reasons, to trigger a Master Reset via VME bus
		SingleVMECPUsBusy => SingleVMECPUsBusy,
		SelectIncludeCPU => SelectIncludeCPU,  --- needs VME write
		SelectInterruptDelayTimes => CPUInterruptSignalsDelayTime, --needs VME read/write
		VMECPUsBusy => BusyAllCPUs_Signal,
		clock100 => clock100,
		Debug_Out => DebugSignals(185+(NVMEbusChs-1) downto 185)
	);
	DebugSignals(157+(NVMEbusChs-1) downto 157) <= SingleVMECPUsBusy;
	DebugSignals(142) <= ReadoutCompleteReset_Signal;
	DebugSignals(141) <= BusyAllCPUs_Signal;
	DebugSignals(171+(NVMEbusChs-1) downto 171) <= CPUInterruptSignalsDelayed;
	
	trig_out_INOUT2(12 downto 0) <= CPUInterruptSignalsDelayed(12 downto 0);
	ExpTrigger_Delayed_Local <= CPUInterruptSignalsDelayed(13);

	Inst_CPUsLiveTime_Scalers : for i in 0 to NVMEbusChs-1 generate begin
		Inter_ToScalerOut(68+i) <= clock1 when SingleVMECPUsBusy(i) = '0' else '0';
	end generate;
	Inter_ToScalerOut(68+NVMEbusChs) <= clock1 when TAPSTotalDeadTime_Signal = '0' else '0';
	Inter_ToScalerOut(68+NVMEbusChs+1) <= clock1;


	------------------------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------------
	-- Total Dead Time
	TAPSTotalDeadTime_Signal <= TAPSDisableTriggerSignal or BusyAllCPUs_Signal;
	DebugSignals(140) <= TAPSTotalDeadTime_Signal;


	-------------------------------------------------------------------------------------------------
	-- Debug Selector
	DebugChSelectors: for i in 0 to NDebugSignalOutputs-1 generate
   begin
		Inst_DebugChSelector: DebugChSelector PORT MAP(
			DebugSignalsIn => DebugSignals,
			SelectedInput => SelectedDebugInput((i+1)*9-1 downto i*9),  ---needs VME write
			SelectedOutput => Debug_ActualState(i)
		);
	end generate;
	trig_out_INOUT2(26+NDebugSignalOutputs-1 downto 26) <= Debug_ActualState;
	Inter_ToScalerOut(84+3 downto 84) <= Debug_ActualState;
	-------------------------------------------------------------------------------------------------



	------------------------------------------------------------------------------------------------
	-- Switch on corresponding LED if cable is connected
	led(1) <= '0' when (trig_in(31+0*32 downto 0*32) = x"00000000") else '1';
	led(2) <= '0';
	led(3) <= '0' when (trig_in(31+1*32 downto 1*32) = x"00000000") else '1';
	led(4) <= '0';
	led(5) <= '0' when (trig_in(31+2*32 downto 2*32) = x"00000000") else '1';
	led(6) <= '0';
	pgxled(1) <= '0' when (trig_in(31+3*32 downto 3*32) = x"00000000") else '1';
	pgxled(2) <= '0';
	led(8 downto 7) <= "00";
	pgxled(8 downto 3) <= (others => '0');

	------------------------------------------------------------------------------------------------
	


	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- handle read commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, oecsr, u_ad_reg)
	begin
		if (clock50'event and clock50 = '1' and oecsr = '1') then
			u_data_o <= (others => '0');
				
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_FIXED) then 
				u_data_o(31 downto 0) <= TRIG_FIXED_Master; end if;
				
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_CFD_OR) then 		u_data_o(3 downto 0) <= PreScaleFactor_CFD_OR; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_LED1_OR) then 		u_data_o(3 downto 0) <= PreScaleFactor_LED1_OR; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_LED2_OR) then 		u_data_o(3 downto 0) <= PreScaleFactor_LED2_OR; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_VETO_OR) then 		u_data_o(3 downto 0) <= PreScaleFactor_VETO_OR; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_CFD_M2Plus) then 	u_data_o(3 downto 0) <= PreScaleFactor_CFD_M2Plus; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_LED1_M2Plus) then u_data_o(3 downto 0) <= PreScaleFactor_LED1_M2Plus; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_LED2_M2Plus) then u_data_o(3 downto 0) <= PreScaleFactor_LED2_M2Plus; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_VETO_M2Plus) then u_data_o(3 downto 0) <= PreScaleFactor_VETO_M2Plus; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_Pulser) then 		u_data_o(3 downto 0) <= PreScaleFactor_Pulser; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_PWO_OR) then 				u_data_o(3 downto 0) <= PreScaleFactor_PWO_OR; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_PWO_M2Plus) then 			u_data_o(3 downto 0) <= PreScaleFactor_PWO_M2PLUS; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_PWO_VETO_OR) then 		u_data_o(3 downto 0) <= PreScaleFactor_PWO_VETO_OR; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreScaleFactor_PWO_VETO_M2Plus) then	u_data_o(3 downto 0) <= PreScaleFactor_PWO_VETO_M2PLUS; end if;

			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CFDSectorMask) then 	u_data_o(5 downto 0) <= CFDSectorMask; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_LED1SectorMask) then u_data_o(5 downto 0) <= LED1SectorMask; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_LED2SectorMask) then u_data_o(5 downto 0) <= LED2SectorMask; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_VetoSectorMask) then u_data_o(5 downto 0) <= VetoSectorMask; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PWOSectorMask) then u_data_o(5 downto 0) <= PWOSectorMask; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PWOVETOSectorMask) then u_data_o(5 downto 0) <= PWOVetoSectorMask; end if;

			if (u_ad_reg(11 downto 4) =  BASE_TRIG_TAPSActualMode) then u_data_o(0) <= TAPSActualMode; end if;
				
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_TAPSDebugSignals) then u_data_o <= TAPSDebugSignals; end if;
			--Readout / Total Dead Time
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectIncludeCPU) then 					u_data_o(NVMEbusChs-1 downto 0) <= SelectIncludeCPU; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_DisableTriggerSignal) then 			u_data_o(0) <= TAPSDisableTriggerSignal; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_ExpTrigger_Delayed_Local) then 		u_data_o(0) <= ExpTrigger_Delayed_Local; end if;
			--CPU Interrupt Signals Delays
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_0) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*0+15 downto 16*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_1) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*1+15 downto 16*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_2) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*2+15 downto 16*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_3) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*3+15 downto 16*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_4) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*4+15 downto 16*4); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_5) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*5+15 downto 16*5); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_6) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*6+15 downto 16*6); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_7) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*7+15 downto 16*7); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_8) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*8+15 downto 16*8); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_9) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*9+15 downto 16*9); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_10) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*10+15 downto 16*10); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_11) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*11+15 downto 16*11); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_12) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*12+15 downto 16*12); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_13) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*13+15 downto 16*13); end if;
			--debug
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_1) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*1-1 downto 9*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_2) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*2-1 downto 9*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_3) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*3-1 downto 9*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_4) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*4-1 downto 9*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Debug_ActualState) then 				u_data_o(NDebugSignalOutputs-1 downto 0) <= Debug_ActualState; end if;

			--EventID
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_SetUserEventID) then 			u_data_o(31 downto 0) <= EventID_UserEventID; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_ReadStatus) then 				u_data_o(6 downto 0) <= EventID_StatusCounter; end if;
		end if;
	end process;

	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- decoder for data registers
	-- handle write commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, ckcsr, u_ad_reg)
	begin
		if (clock50'event and clock50 ='1') then
			ResetVMEbusCPUsState <= '0';
			SingleVMECPUsReadoutComplete_Local <= '0';
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_CFD_OR ) then				PreScaleFactor_CFD_OR <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_LED1_OR ) then				PreScaleFactor_LED1_OR <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_LED2_OR ) then				PreScaleFactor_LED2_OR <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_VETO_OR ) then				PreScaleFactor_VETO_OR <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_CFD_M2Plus ) then			PreScaleFactor_CFD_M2Plus <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_LED1_M2Plus ) then		PreScaleFactor_LED1_M2Plus <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_LED2_M2Plus ) then		PreScaleFactor_LED2_M2Plus <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_Pulser ) then				PreScaleFactor_Pulser <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_PWO_OR ) then				PreScaleFactor_PWO_OR <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_PWO_M2Plus ) then			PreScaleFactor_PWO_M2PLUS <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_PWO_VETO_OR ) then		PreScaleFactor_PWO_VETO_OR <= u_dat_in(3 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PreScaleFactor_PWO_VETO_M2Plus ) then	PreScaleFactor_PWO_VETO_M2PLUS <= u_dat_in(3 downto 0); end if;

			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_CFDSectorMask ) then							CFDSectorMask <= u_dat_in(5 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_LED1SectorMask ) then						LED1SectorMask <= u_dat_in(5 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_LED2SectorMask ) then						LED2SectorMask <= u_dat_in(5 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_VETOSectorMask ) then						VETOSectorMask <= u_dat_in(5 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PWOSectorMask ) then							PWOSectorMask <= u_dat_in(5 downto 0); end if;
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_PWOVETOSectorMask ) then					PWOVetoSectorMask <= u_dat_in(5 downto 0); end if;
			
			if (ckcsr='1' and u_ad_reg(11 downto 4)= BASE_TRIG_TAPSActualMode ) then						TAPSActualMode <= u_dat_in(0); end if;
			--Readout / Total Dead Time
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectIncludeCPU) ) then 				SelectIncludeCPU <= u_dat_in(NVMEbusChs-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_DisableTriggerSignal) ) then 			TAPSDisableTriggerSignal <= u_dat_in(0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_ResetVMEbusCPUsState) ) then 			ResetVMEbusCPUsState <= u_dat_in(0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SingleVMECPUsReadoutComplete_Local) ) then SingleVMECPUsReadoutComplete_Local <= u_dat_in(0); end if;
			--CPUs Interrupt Signal Delay
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_0) ) then CPUInterruptSignalsDelayTime(16*0+15 downto 16*0) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_1) ) then CPUInterruptSignalsDelayTime(16*1+15 downto 16*1) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_2) ) then CPUInterruptSignalsDelayTime(16*2+15 downto 16*2) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_3) ) then CPUInterruptSignalsDelayTime(16*3+15 downto 16*3) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_4) ) then CPUInterruptSignalsDelayTime(16*4+15 downto 16*4) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_5) ) then CPUInterruptSignalsDelayTime(16*5+15 downto 16*5) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_6) ) then CPUInterruptSignalsDelayTime(16*6+15 downto 16*6) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_7) ) then CPUInterruptSignalsDelayTime(16*7+15 downto 16*7) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_8) ) then CPUInterruptSignalsDelayTime(16*8+15 downto 16*8) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_9) ) then CPUInterruptSignalsDelayTime(16*9+15 downto 16*9) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_10) ) then CPUInterruptSignalsDelayTime(16*10+15 downto 16*10) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_11) ) then CPUInterruptSignalsDelayTime(16*11+15 downto 16*11) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_12) ) then CPUInterruptSignalsDelayTime(16*12+15 downto 16*12) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_13) ) then CPUInterruptSignalsDelayTime(16*13+15 downto 16*13) <= u_dat_in(15 downto 0); end if;
			--debug
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_1) ) then 			SelectedDebugInput(9*1-1 downto 9*0) <= u_dat_in(8 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_2) ) then 			SelectedDebugInput(9*2-1 downto 9*1) <= u_dat_in(8 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_3) ) then 			SelectedDebugInput(9*3-1 downto 9*2) <= u_dat_in(8 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_4) ) then 			SelectedDebugInput(9*4-1 downto 9*3) <= u_dat_in(8 downto 0); end if;

			--EventID
			EventID_ResetSenderCounter <= '0';
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_SetUserEventID) ) then 		EventID_UserEventID <= u_dat_in; end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_ResetSending) ) then 			EventID_ResetSenderCounter <= u_dat_in(0); end if;
		end if;
	end process;
	


end RTL;