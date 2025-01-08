library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;

entity mixColumns_tb is
--  Port ( );
end mixColumns_tb;

architecture Behavioral of mixColumns_tb is

component mixColumns port(
    DataIn : in dataMatrix;
    DataOut : out dataMatrix;
    clk : in std_logic ;
    enable : in std_logic ;
    rst : in std_logic 
);
end component;

-- input : 09287F47 6F746ABF 2C4A6204 DA08E3EE
-- output : 529F16C2 978615CA E01AAE54 BA1A2659
signal INDATA : dataMatrix := ((x"09",x"6F",x"2C",x"DA"),(x"28",x"74",x"4A",x"08"),
    (x"7F",x"6A",x"62",x"E3"),(x"47",x"BF",x"04",x"EE"));
signal OUTDATA : dataMatrix ;
signal enable : std_logic := '0';
signal rst : std_logic := '1';
signal clk : std_logic :='0' ;
signal clkperiod : time := 10ns;

begin

    clk <= not clk after clkperiod/2;
    myMixColumn : mixColumns port map (DataIn => INDATA, DataOut => OUTDATA,clk =>clk, rst => rst, enable => enable);
    
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
    -- input : 89B5884A C0565303 2E389B21 604D123C
    -- output : 0F31E929 319A3558 AEC95893 39F04D87
    INDATA <= (
            (X"89", X"c0", X"2e", X"60"),  
            (X"b5", X"56", X"38", X"4d"),  
            (X"88", X"53", X"9b", X"12"),  
            (X"4a", X"03", X"21", X"3c")); 

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
            (x"28",x"74",x"4A",x"08"),
            (x"7F",x"6A",x"62",x"E3"),
            (x"47",x"BF",x"04",x"EE"));
        wait for 10ns;
        rst <='0';
        wait for 10ns;
        enable <= '0';
        wait for 10ns;
    INDATA <= (
            (X"89", X"c0", X"2e", X"60"),  
            (X"b5", X"56", X"38", X"4d"),  
            (X"88", X"53", X"9b", X"12"),  
            (X"4a", X"03", X"21", X"3c"));  
        wait for 10ns;
        enable <='1';
    end process;

end Behavioral;
