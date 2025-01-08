library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
entity AES_HARDWARE is
Port (
    clk : in std_logic ;
    seg : out std_logic_vector(6 downto 0);
    an : out std_logic_vector (3 downto 0);
    btnC : in std_logic ;
    btnR : in std_logic 
 );
end AES_HARDWARE;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
architecture Behavioral of AES_HARDWARE is

component AES_Encryption_Top
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
end component;

component BitCounter 
generic (N : integer := 2);
port(
    Clk : in std_logic ;
    En : in std_logic ;
    Rst : in std_logic ;
    Q : out std_logic_vector (N-1 downto 0) 
);
end component;

component fourDigitDisplay is
Port (
    clk : in std_logic ;
    segmentFour : out std_logic_vector(6 downto 0) ;
    anodeFour : out std_logic_vector(3 downto 0) ; 
    input16Number : in std_logic_vector (15 downto 0)
 );
 end component;
    
----------------------------------------------------------------------------------------------------------
    
signal output_cipher_text : std_logic_vector(127 downto 0);
signal endEncryption : std_logic ;
signal round_keys : std_logic_vector(1407 downto 0) := X"2B7E151628AED2A6ABF7158809CF4F3C" &
                      X"A0FAFE1788542CB123A339392A6C7605" &
                      X"F2C295F27A96B9435935807A7359F67F" &
                      X"3D80477D4716FE3E1E237E446D7A883B" &
                      X"EF44A541A8525B7FB671253BDB0BAD00" &
                      X"D4D1C6F87C839D87CAF2B8BC11F915BC" &
                      X"6D88A37A110B3EFDDBF98641CA0093FD" &
                      X"4E54F70E5F5FC9F384A64FB24EA6DC4F" &
                      X"EAD27321B58DBAD2312BF5607F8D292F" &
                      X"AC7766F319FADC2128D12941575C006E" &
                      X"D014F9A8C9EE2589E13F0CC8B6630CA6";
signal input_plain_text :  dataText := (
        X"6BC1BEE22E409F96E93D7E117393172A",
        X"AE2D8A571E03AC9C9EB76FAC45AF8E51",
        X"30C81C46A35CE411E5FBC1191A0A52EF",
        X"F69F2445DF4F9B17AD2B417BE66C3710"
    );

-- For Clock divider
signal slowClockEn : std_logic := '1' ;
signal slowClockRst : std_logic := '0';
signal slowClockQ : std_logic_vector (19 downto 0) ;
signal slowClock : std_logic := '0';

-- For Display
signal AESDisplay : std_logic_vector (15 downto 0) := (others => '0');
signal AESSEV : std_logic_vector (15 downto 0) := x"0000";

-- For Debug purposes, usefull when doing testbenches
signal DebugState : std_logic ; 
signal inputData : dataMatrix;
signal key : dataMatrix;
signal number_round     : integer range 0 to 11;
signal enableTextCounter : integer;
signal add_round_key_out, sub_bytes_out, shift_rows_out, mix_columns_out : dataMatrix;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
begin


AES_inst : AES_Encryption_Top
        port map (
            clk                         => slowClock,
            startEncryption             => btnC,
            restartEncryption           => btnR,
            input_text                  => input_plain_text,
            round_keys                  => round_keys,
            output_cipher_text          => output_cipher_text,
            endEncryption               => endEncryption,
            DEBUG_add_round_key_out     => add_round_key_out,
            DEBUG_sub_bytes_out         => sub_bytes_out,
            DEBUG_shift_rows_out        => shift_rows_out,
            DEBUG_input_matrix          => inputData,
            DEBUG_key                   => key,
            DEBUG_nextTextCounter       => enableTextCounter,
            DEBUG_mix_columns_out       => mix_columns_out,
            DEBUG_state                 => DebugState,
            DEBUG_round                 => number_round  
        );

clockDivider : BitCounter
    generic map (N=>20)
    port map (Clk=> clk,En => slowClockEn, Rst => slowClockRst, Q => slowClockQ);

display : fourDigitDisplay port map (clk => clk, segmentFour => seg, anodeFour => an, input16Number => AESDisplay);

-- Updates the seven segments display
updateDisplay : process (clk, AESSEV) begin 
    if rising_edge (clk) then
        AESDisplay <= AESSEV;
    end if;
end process;

changingDisplay : process  (clk, endEncryption) begin
    -- When we end the encryption, the endEncryption goes to high
    -- and we display AES and hold it until endEncryption becomes zero
    -- /!\ We need to put the display value into a register, there is some issue if we don't
    -- /!\ Doesn't work if debugs ports are disabled... 
    if rising_edge(clk) then
        if endEncryption = '1' then
            AESSEV <= x"AE50";                                  -- Comment for debugging purposes
            --AESSEV <= output_cipher_text(127 downto 112);     -- Uncomment for debugging purposes
        elsif endEncryption = '0' then
            AESSEV <= x"bbbb";
        end if;
    end if;
end process;

-- We divide the clock from 100MHz to 50 Hz
-- New clock : OldClock / (2 x slowClockQ)
slowingDownClock : process (clk,slowClockQ, slowClock) begin
    if rising_edge (clk) then
        if slowClockQ=x"F4240" then     -- Didn't try to optimize the clock, F4240 is 1e6
            slowClockRst <= '1';
            slowClock <= not slowClock;
        else slowClockRst <= '0';
        end if;
    end if;
end process;

end Behavioral;
