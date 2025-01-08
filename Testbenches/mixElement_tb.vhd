library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;
---------------------------------------------------------------------------
entity mixElement_tb is
end mixElement_tb;
---------------------------------------------------------------------------

architecture Behavioral of mixElement_tb is

component mixElement
Generic(
    line : integer :=0
);
Port (
    dataOut : out std_logic_vector (7 downto 0);
    dataIn : in dataColumn ;
    clk : in std_logic ;
    enable : in std_logic ;
    rst : in std_logic 
);
end component;

-- input : 09287F47
-- expected output : 52
signal INDATA : dataColumn := (x"09",x"28",x"7F",x"47");
signal OUTDATA : std_logic_vector (7 downto 0) ;
signal enable : std_logic := '0';
signal rst : std_logic :='1';
signal clk : std_logic :='0' ;
signal clkperiod : time := 10ns;

---------------------------------------------------------------------------
begin
    clk <= not clk after clkperiod/2;
    myMixElem : mixElement generic map (line =>0) port map (DataIn => INDATA, DataOut => OUTDATA,clk =>clk, rst => rst, enable => enable);
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
    -- Test for round two, first element
    -- input : 89B5884A
    -- output : 0F
    INDATA <= (x"89",x"b5",x"88",x"4a");

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
    INDATA <= (x"09",x"28",x"7F",x"47");
        wait for 10ns;
        rst <='0';
        wait for 10ns;
        enable <= '0';
        wait for 10ns;
    INDATA <= (x"89",x"b5",x"88",x"4a");  
        wait for 10ns;
        enable <='1';
    end process;
end Behavioral;
---------------------------------------------------------------------------