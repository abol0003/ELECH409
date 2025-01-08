library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;  -- Utilisation du package myDataMatrix où dataMatrix est défini

entity tb_SubBytes is
end tb_SubBytes;

architecture Behavioral of tb_SubBytes is

component SubBytes
Port (
    clk : in STD_LOGIC;
    data_in : in dataMatrix;
    data_out : out dataMatrix;
    enable : in std_logic;
    rst : in std_logic
); 
end component;

-- input : 40BFABF4 06EE4D30 42CA6B99 7A5C5816
-- output : 090862BF 6F28E304 2C747FEE DA4A6A47
signal data_in : dataMatrix := (
            (X"40", X"06", X"42", X"7A"),  
            (X"BF", X"EE", X"CA", X"5C"),  
            (X"AB", X"4D", X"6B", X"58"),  
            (X"F4", X"30", X"99", X"16"));
signal data_out : dataMatrix;
signal enable : std_logic := '0' ;
signal rst : std_logic := '1' ;
signal clk : STD_LOGIC := '0';

begin

    uut: SubBytes
        port map (
            clk => clk,
            data_in => data_in,
            data_out => data_out,
            enable => enable,
            rst => rst
        );

    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Stimulus
    stim_proc: process
    begin
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
    -- input : F265E8D5 1FD2397B C3B9976D 9076505C
    -- output : 894D9B03 C0B51221 2E56883C 6038534A
    data_in <= (
            (X"f2", X"1f", X"c3", X"90"),  
            (X"65", X"d2", X"b9", X"76"),  
            (X"e8", X"39", X"97", X"50"),  
            (X"d5", X"7b", X"6d", X"5c")); 

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
            (X"40", X"06", X"42", X"7A"),  
            (X"BF", X"EE", X"CA", X"5C"),  
            (X"AB", X"4D", X"6B", X"58"),  
            (X"F4", X"30", X"99", X"16"));
        wait for 10ns;
        rst <='0';
        wait for 10ns;
        enable <= '0';
        wait for 10ns;
    data_in <= (
            (X"f2", X"1f", X"c3", X"90"),  
            (X"65", X"d2", X"b9", X"76"),  
            (X"e8", X"39", X"97", X"50"),  
            (X"d5", X"7b", X"6d", X"5c")); 
        wait for 10ns;
        enable <='1';       
    end process;
end Behavioral;

