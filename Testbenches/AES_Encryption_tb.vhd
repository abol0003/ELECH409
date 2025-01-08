library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.myDataMatrix.all;

entity AES_Encryption_tb is
end AES_Encryption_tb;

architecture Behavioral of AES_Encryption_tb is

-- Component Declaration
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

    -- Signals
signal slowClock : std_logic := '0';
signal number_round     : integer range 0 to 11;
signal endEncryption : std_logic ;
signal enableTextCounter : integer;
signal  btnC :  std_logic := '0' ;
signal  btnR :  std_logic := '0';
signal add_round_key_out, sub_bytes_out, shift_rows_out, mix_columns_out : dataMatrix;
signal output_cipher_text : std_logic_vector(127 downto 0);
signal inputData : dataMatrix;

signal key : dataMatrix;
constant clk_period : time := 10 ns;
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
    
signal slowClockEn : std_logic := '1' ;
signal slowClockRst : std_logic := '0';
signal slowClockQ : std_logic_vector (19 downto 0) ; -- Choose other than 19 for other clock
signal AESDisplay : std_logic_vector (15 downto 0) := (others => '0');
signal DebugState : std_logic ;
signal clk              : std_logic := '0';
signal  seg : std_logic_vector(6 downto 0);
signal  an :  std_logic_vector (3 downto 0);
   
begin
    -- DUT Instance
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

changingDisplay : process  (endEncryption) begin
        -- When we end the encryption, the endEncryption goes to high
        -- and we display AES and hold it until endEncryption becomes zero
        case endEncryption is
            when '1'=> AESDisplay <= x"AE50";
            when '0'=> AESDisplay <= x"0000";
            when others => AESDisplay <= x"EEEE";
        end case;
end process;

slowingDownClock : process (clk,slowClockQ, slowClock) begin
    if rising_edge (clk) then
        if slowClockQ=x"0000a" then     -- Choose this value to divide the clock
            slowClockRst <= '1';
            slowClock <= not slowClock;
        else slowClockRst <= '0';
        end if;
    end if;
end process;
    -- Clock Process
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
    stim : process begin
        wait for 200 ns;
        btnC <= '1';
        wait for 100ns;
        btnC <= '0';
        wait for 500 ns;
        btnC <= '1';
        wait for 200ns;
        btnC <= '0';
        wait for 4000ns;
        btnC <= '1';
        wait for 100ns;
        btnC <='0';
        wait for 400ns;
        btnR <= '1';
        wait for 100ns;
        btnR <= '0';
        wait for 100ns;
        btnR <= '1';
        wait for 100ns;
        btnR <= '0';
        wait for 500ns;
        btnR <= '1';
        wait for 200ns;
        btnR <= '0';
        wait for 10000ns;
        btnR <= '1';
    end process;



end Behavioral;
