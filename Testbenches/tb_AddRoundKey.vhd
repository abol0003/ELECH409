library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;  

entity tb_AddRoundKey is
end tb_AddRoundKey;

architecture Behavioral of tb_AddRoundKey is

component AddRoundKey
Port (
    clk : in STD_LOGIC;
    data_in : in dataMatrix;
    round_key : in dataMatrix;
    data_out : out dataMatrix;
    enable : in std_logic;
    rst : in std_logic 
);
end component;

-- key : 2B7E1516 28AED2A6 ABF71588 09CF4F3C
-- input : 6BC1BEE2 2E409F96 E93D7E11 7393172A
-- output : 40BFABF4 06EE4D30 42CA6B99 7A5C5816
signal DATA_IN : dataMatrix := (
            (X"6B", X"2E", X"E9", X"73"),  
            (X"C1", X"40", X"3D", X"93"),  
            (X"BE", X"9F", X"7E", X"17"),  
            (X"E2", X"96", X"11", X"2A")); 
signal ROUND_KEY : dataMatrix := (
            (X"2B", X"28", X"AB", X"09"),  
            (X"7E", X"AE", X"F7", X"CF"),  
            (X"15", X"D2", X"15", X"4F"),  
            (X"16", X"A6", X"88", X"3C")); 
signal DATA_OUT : dataMatrix;
signal ENABLE : std_logic := '0';
signal RST : std_logic := '1' ;
signal CLK : STD_LOGIC := '0';


begin
    
    uut: AddRoundKey
        Port map (
            clk => CLK,
            data_in => DATA_IN,
            round_key => ROUND_KEY,
            data_out => DATA_OUT,
            enable => ENABLE,
            rst => rst
        );
     
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    stim : process begin
    
    -- Test enable and rst
        wait for 10ns;
        rst <= '0';
        wait for 10ns;
        enable <= '1' ;
        wait for 10 ns;
        enable <= '0';
        wait for 10ns;
        rst <= '1';
        wait for 10ns;
        enable <= '1';
        wait for 10ns;
        rst <= '0';
        enable <= '0';
        wait for 10ns;
    -- Test for round two
    -- input : 529F16C2 978615CA E01AAE54 BA1A2659
    -- key : a0fafe1788542cb123a339392a6c7605
    -- output : F265E8D5 1FD2397B C3B9976D 9076505C
    data_in <= (
            (X"00", X"00", X"00", X"00"),  
            (X"00", X"00", X"00", X"00"),  
            (X"00", X"00", X"00", X"00"),  
            (X"00", X"00", X"00", X"00")); 
    round_key <= (
            (X"a0", X"88", X"23", X"2a"),  
            (X"fa", X"54", X"a3", X"6c"),  
            (X"fe", X"2c", X"39", X"76"),  
            (X"17", X"b1", X"39", X"05")); 
     -- Test enable and rst
        wait for 10ns;
        enable <= '1' ;
        wait for 10 ns;
        enable <= '0';
        wait for 10ns;
        rst <= '1';
        wait for 10ns;
        enable <= '1';
        wait for 10ns;
    -- Put back first data to test transition without setting to zero  
    data_in <= (
            (X"6B", X"2E", X"E9", X"73"),  
            (X"C1", X"40", X"3D", X"93"),  
            (X"BE", X"9F", X"7E", X"17"),  
            (X"E2", X"96", X"11", X"2A")); 
    round_key <= (
            (X"2B", X"28", X"AB", X"09"),  
            (X"7E", X"AE", X"F7", X"CF"),  
            (X"15", X"D2", X"15", X"4F"),  
            (X"16", X"A6", X"88", X"3C"));
        wait for 10ns;
        rst <='0';
        wait for 10ns;
        enable <= '0';
        wait for 10ns;
    data_in <= (
            (X"52", X"97", X"e0", X"ba"),  
            (X"9f", X"86", X"1a", X"1a"),  
            (X"16", X"15", X"ae", X"26"),  
            (X"c2", X"ca", X"54", X"59")); 
    round_key <= (
            (X"a0", X"88", X"23", X"2a"),  
            (X"fa", X"54", X"a3", X"6c"),  
            (X"fe", X"2c", X"39", X"76"),  
            (X"17", X"b1", X"39", X"05")); 
        wait for 10ns;
        enable <='1'; 
        
    end process;
end Behavioral;
