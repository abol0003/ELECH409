library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.myDataMatrix.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
entity AES_Encryption_Top is
    Port (
        input_text          : in dataText;    -- array (0 to 3) of 128 bits
        output_cipher_text  : out std_logic_vector(127 downto 0);
        round_keys          : in std_logic_vector(1407 downto 0); -- 11 x 128 bits = 1408 bits
        clk                 : in std_logic;
        restartEncryption   : in std_logic;
        startEncryption     : in std_logic ;
        endEncryption       : out std_logic ;
        DEBUG_add_round_key_out   : out dataMatrix;
        DEBUG_sub_bytes_out       : out dataMatrix;
        DEBUG_shift_rows_out      : out dataMatrix;
        DEBUG_mix_columns_out     : out dataMatrix;
        DEBUG_input_matrix : out dataMatrix ;
        DEBUG_key : out dataMatrix ;
        DEBUG_nextTextCounter : out integer ;
        DEBUG_state : out std_logic ;
        DEBUG_round         : out integer range 0 to 11
       );
end AES_Encryption_Top;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
architecture FSM of AES_Encryption_Top is
    -- State type
    type roundState is (REPEATROUNDS, LASTROUND, IDLE,RESTART);
    type stepState is (ADDROUNDKEY_STEP, SUBBYTES_STEP, SHIFTROWS_STEP, MIXCOLUMNS_STEP,IDLE_STEP,RESTART_STEP);
    signal currentRound, nextRound : roundState := IDLE;    -- When we start, we are in idle mode
    signal currentStep, nextStep : stepState := IDLE_STEP;

    -- Keys
    signal round_key        : dataMatrix;
    signal round            : integer range 0 to 11 := 0;
    signal round_key_vector : std_logic_vector(127 downto 0);

    -- Input and output
    
    signal final_output_vector    : std_logic_vector(127 downto 0) := (others => '0');  -- Make sure output at init is zero
    signal outputData : dataMatrix := (others => (others => x"00"));
    signal input_plain_text : dataMatrix;
    signal input_plain_text_vector :  std_logic_vector(127 downto 0);
    
    -- Signals for next Line in plain text 
    signal enableNextText : std_logic := '1' ;
    signal nextTextCounter : integer := 0;
    signal stateActive : std_logic := '0';


    -- Signals between AES steps
    signal add_round_key_in : dataMatrix; 
    signal add_round_key_out : dataMatrix; 
    signal sub_bytes_in     : dataMatrix;
    signal sub_bytes_out     : dataMatrix;
    signal shift_rows_in    : dataMatrix;
    signal shift_rows_out    : dataMatrix;
    signal mix_columns_in   : dataMatrix;
    signal mix_columns_out   : dataMatrix;
    
    -- Enable and Rst Bus signals
    signal enableBus : std_logic_vector ( 3 downto 0):= "0000";
    signal rstBus : std_logic_vector (3 downto 0):="0000";

    -- Component declarations
    component VectorToMatrix
        Port (
            vec_in  : in std_logic_vector(127 downto 0);
            mat_out : out dataMatrix
        );
    end component;

    component MatrixToVector
        Port (
            mat_in  : in dataMatrix;
            vec_out : out std_logic_vector(127 downto 0)
        );
    end component;

    component AddRoundKey
        Port (
            clk      : in std_logic;
            enable   : in std_logic;
            data_in  : in dataMatrix;
            round_key: in dataMatrix;
            data_out : out dataMatrix;
            rst : in std_logic 
        );
    end component;

    component SubBytes
        Port (
            clk      : in std_logic;
            enable   : in std_logic;
            data_in  : in dataMatrix;
            data_out : out dataMatrix ;
            rst : in std_logic 
        );
    end component;

    component ShiftRows
        Port (
            clk      : in std_logic;
            enable   : in std_logic;
            DataIn   : in dataMatrix;
            DataOut  : out dataMatrix ;
            rst : in std_logic 
        );
    end component;

    component MixColumns
        Port (
            clk      : in std_logic;
            enable   : in std_logic;
            DataIn   : in dataMatrix;
            DataOut  : out dataMatrix ;
            rst : in std_logic 
        );
    end component;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
begin
    -- For debugging purposes
    DEBUG_round <= round;
    DEBUG_add_round_key_out <= add_round_key_out;
    DEBUG_sub_bytes_out <= sub_bytes_out;
    DEBUG_shift_rows_out <= shift_rows_out;
    DEBUG_mix_columns_out <= mix_columns_out;
    DEBUG_nextTextCounter <= nextTextCounter;
    DEBUG_input_matrix <= input_plain_text;
    DEBUG_key <= round_key;
    DEBUG_State <= stateActive;     -- change this value to 1 at desired state to debug
    
    -- Connecting steps together and outputs
    sub_bytes_in <= add_round_key_out;
    shift_rows_in <= sub_bytes_out;
    mix_columns_in <= shift_rows_out;
    output_cipher_text <= final_output_vector;
    endEncryption <= enablenexttext;
    
    -- Component instantiations
    VectorToMatrix_input : VectorToMatrix
        port map (vec_in => input_plain_text_vector, mat_out => input_plain_text);

    VectorToMatrix_round_key : VectorToMatrix
        port map (vec_in => round_key_vector, mat_out => round_key);

    MatrixToVector_inst : MatrixToVector
        port map (mat_in => outputData, vec_out => final_output_vector);

    AddRoundKey_inst : AddRoundKey
        port map (clk => clk, enable => enableBus(0), data_in => add_round_key_in, round_key => round_key, 
            data_out => add_round_key_out, rst => rstBus(0));

    SubBytes_inst : SubBytes
        port map (clk => clk, enable => enableBus(1), data_in => sub_bytes_in, data_out => sub_bytes_out, rst => rstBus(1));

    ShiftRows_inst : ShiftRows
        port map (clk => clk, enable => enableBus(2), DataIn =>shift_rows_in, DataOut => shift_rows_out, rst => rstBus(2));

    MixColumns_inst : MixColumns
        port map (clk => clk, enable => enableBus(3), DataIn => mix_columns_in, DataOut => mix_columns_out, rst => rstBus(3));
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Updates current states and modifies the round number each tine we are at the AddRoundKey Step
update_current_state : process(clk,restartEncryption, enableNextText,nextTextCounter,input_text) begin

    -- To restart the encryption, reset every module
    -- /!\ The reset is synchronous for every modules but important to put 
    -- the rstBus here (asynchronously) so that at next rising edge, resets are all high (avoid one clock delay)
    if restartEncryption = '1' then 
        rstBus <="1111";
    else rstBus <= "0000";
    end if;
    
    -- Change the next input to the following line
    -- Doing it at the end because if we have an error,
    -- we are restarting the whole encryption process and
    -- we don't to restart with the following text if we
    -- didn't finish the current one
    if enableNextText = '1'then
        if nextTextCounter <= 3 then
            input_plain_text_vector <= input_text (nextTextCounter);
        else input_plain_text_vector <= input_text (3);
        end if;
        
    end if;
    
    if rising_edge(clk) then
    
    -- Update the states
    currentRound <= nextRound;
    currentStep <= nextStep;
        -- put back the round at zero and update the state to be at restart
        if restartEncryption = '1' then
            currentRound <= RESTART;
            currentStep <= RESTART_STEP;
            round <=0;
        elsif nextStep = ADDROUNDKEY_STEP then -- After every add round key, we need to increase the round
            round <= round +1;
        end if;
    
    end if;
end process;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Depending on the round, this process modifies the order of the steps
-- It is important to add the output signals in the sensitivity list or else we have clock delays
-- Remark : these signals are the one we are connecting differently depending on the round
-- Also, the process is sensitive to the start and restart button (once again to avoid one clock delay)
nextRoundUpdate : process(currentRound,currentStep,round,
    mix_columns_out,shift_rows_out,add_round_key_out,restartEncryption,startEncryption, round_keys, input_plain_text) begin
    
-- Manage the keys, if we are at the last round 11, don't try to take another key
if round <= 10 then
    round_key_vector <= round_keys((1407 - round * 128) downto (1280 - round * 128));
else round_key_vector <= round_keys(127 downto 0);
end if;
case currentRound is

--------------------------------------------------------------------------------------      
when REPEATROUNDS =>
    case round is 
    when 1 to 9 =>
        nextRound <= REPEATROUNDS;      -- do the same thing 9 times
        add_round_key_in <= mix_columns_out;
        stateActive <= '1';     -- Debug
        -- Basically : AddRoundKey -> SubBytes -> ShiftRows -> MixColumns -> AddRoundKey...
        case currentStep is
            when ADDROUNDKEY_STEP =>
                nextStep <= SUBBYTES_STEP;
            when SUBBYTES_STEP =>
                nextStep <= SHIFTROWS_STEP;               
            when SHIFTROWS_STEP =>
                nextStep <= MIXCOLUMNS_STEP;
            when MIXCOLUMNS_STEP =>
                nextStep <= ADDROUNDKEY_STEP;
            when others => nextStep <= RESTART_STEP; -- Error handling
        end case;
        
    -- We are changing to the last rounds, important to already setup the next step
    -- to avoid one clock delay
    when 10 =>
        nextRound <= LASTROUND;
        nextStep <= SUBBYTES_STEP;
    when others =>  -- Error handling
        nextRound <= RESTART;
        nextStep <= RESTART_STEP;
    end case;
--------------------------------------------------------------------------------------       
when LASTROUND =>
    case round is
            
    -- In this round, we need to change the input of AddRoundKey step to the output of shiftRows step
    when 10 =>
        add_round_key_in <= shift_rows_out;
        nextRound <= LASTROUND;
        case currentStep is 
            when SUBBYTES_STEP =>
                nextStep <= SHIFTROWS_STEP;               
            when SHIFTROWS_STEP =>
                nextStep <= ADDROUNDKEY_STEP;   -- No longer MixColumns !
            when others => nextStep <= RESTART_STEP;    -- Error handling
        end case;
        
    -- At round 11, we are taking the result of the last AddRoundKey output it 
    when 11 => 
         outputData <= add_round_key_out;
         nextRound <= IDLE;
         nextStep <= IDLE_STEP;     -- We end the encryption, we do nothing
         -- Signal to tell that we finished the encryption
         -- This signal will change the current Text Input with the next one to encrypt
         enableNextText <= '1';     
    when others => 
        nextRound <= RESTART;
        nextStep <= RESTART_STEP;  
    end case;
--------------------------------------------------------------------------------------
when IDLE =>

    -- When in IDLE mode, we are at the start or at the end
    -- At start (round 0), we are waiting for the start button to be pushed
    -- At the end, we are staying in the IDLE mode until the restart button is pushed
    -- When it is pushed, we are going to the restart state
    -- We did it this way to ensure that the start button only works at the beginning
    case round is
    when 0 =>
        case startEncryption is
            when '1'=>
                nextRound <= REPEATROUNDS;
                nextStep <= ADDROUNDKEY_STEP;
                enableNextText <= '0';          -- Starting to encrypt, pull down
                add_round_key_in <= input_plain_text;
            when '0'=>
                nextRound <= IDLE;
                nextStep <= IDLE_STEP;
            when others =>  -- Error handling
                nextRound <= RESTART;
                nextStep <= RESTART_STEP;
        end case;
    when 1 to 11 =>
        nextRound <= IDLE;  -- stay in the same state unless restart button is pushed
        nextStep <= IDLE_STEP;
    when others =>  -- Error handling
        nextRound <= RESTART;
        nextStep <= RESTART_STEP;
    end case;
--------------------------------------------------------------------------------------
when RESTART =>
    
    -- If the Restart button is high, we are staying in the restart state
    -- We restart the encryption once we release the button
    case restartEncryption is
        when '1'=>  
            nextRound <= RESTART;
            nextStep <= RESTART_STEP;
            add_round_key_in <= input_plain_text;
        when '0' => 
            nextRound <= REPEATROUNDS;
            nextStep <= ADDROUNDKEY_STEP;
            
            -- If we start to encrypt, we don't change the current text in the case that we have an error
            -- In fact, the RESTART state handles the error and redo every steps with THE SAME TEXT INPUT
            -- We change the enableNextText when we are done with the encryption
            enableNextText <= '0';
        when others =>  -- Error handling
            nextRound <= RESTART;
            nextStep <= RESTART_STEP;
    end case;
--------------------------------------------------------------------------------------      
end case;
end process;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Process that enables the right step
stepHandler : process(nextStep) begin
    case nextStep is
        when ADDROUNDKEY_STEP => enableBus <= "0001" ;
        when SUBBYTES_STEP => enableBus <= "0010" ;
        when SHIFTROWS_STEP => enableBus <= "0100" ;
        when MIXCOLUMNS_STEP => enableBus <= "1000" ;
        when IDLE_STEP => enableBus <= "0000";  -- Do nothing during IDLE state
        when RESTART_STEP => enableBus <= "0000";   -- Do nothing during RESTART state, the rst is handled in the update
    end case;
end process;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Process that handles the plain text input
-- /!\ We are changing the text when we are done with the encryption
-- At round 11 in LASTROUND, we change the enableNextText to 0 -> 1
-- When we are doing that, we are also increasing the nextTextCounter (basically choosing the next line in text)
-- /!\ We can't put this +1 simply in the process that manages the next state because
-- the ouputdata is in the sensivity, which means that we are not doing +1 but +2 in one clock
-- tl;dr : we need to handle the next input line in another process
inputTextHandler : process(enableNextText) begin
    if rising_edge (enableNextText) then
        if nextTextCounter <3 then
            nextTextCounter <= nextTextCounter +1 ;
        else nextTextCounter <= 0;      -- With this, we can redo all the encryption again from beginning
        end if;
    end if;
end process;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end FSM;