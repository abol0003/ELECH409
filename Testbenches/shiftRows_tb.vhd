library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;

entity shiftRows_tb is
end shiftRows_tb;

architecture Behavioral of shiftRows_tb is

component shiftRows is port (
    DataIn : in dataMatrix;
    DataOut : out dataMatrix;
    clk : in std_logic ;
    enable : in std_logic ;
    rst : in std_logic 
);
end component;

-- input : 090862BF 6F28E304 2C747FEE DA4A6A47
-- output : 09287F47 6F746ABF 2C4A6204 DA08E3EE
signal INDATA : dataMatrix := ((x"09",x"6F",x"2C",x"DA"),(x"08",x"28",x"74",x"4A"),
    (x"62",x"E3",x"7F",x"6A"),(x"BF",x"04",x"EE",x"47"));
signal OUTDATA : dataMatrix ;
signal enable : std_logic :='0';
signal rst : std_logic := '1';
signal clk : std_logic :='0' ;
signal clkperiod : time := 10ns;


begin
    
    clk <= not clk after clkperiod/2;
    myShiftRow : shiftRows port map (DataIn => INDATA, DataOut => OUTDATA,clk =>clk,enable => enable, rst => rst);
    
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
    -- input : 894D9B03 C0B51221 2E56883C 6038534A
    -- output : 89B5884A C0565303 2E389B21 604D123C
    INDATA <= (
            (X"89", X"c0", X"2e", X"60"),  
            (X"4d", X"b5", X"56", X"38"),  
            (X"9b", X"12", X"88", X"53"),  
            (X"03", X"21", X"3c", X"4a")); 

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
    INDATA <= (
            (x"09",x"6F",x"2C",x"DA"),
            (x"08",x"28",x"74",x"4A"),
            (x"62",x"E3",x"7F",x"6A"),
            (x"BF",x"04",x"EE",x"47"));
        wait for 10ns;
        rst <='0';
        wait for 10ns;
        enable <= '0';
        wait for 10ns;
    INDATA <= (
            (X"89", X"c0", X"2e", X"60"),  
            (X"4d", X"b5", X"56", X"38"),  
            (X"9b", X"12", X"88", X"53"),  
            (X"03", X"21", X"3c", X"4a"));  
        wait for 10ns;
        enable <='1';
    end process;


end Behavioral;
