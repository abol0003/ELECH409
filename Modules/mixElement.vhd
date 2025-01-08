-- This module takes an entire column of data and applies 
-- the right matrice multiplication to compute one element
-- of the mixColumns output result

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;
---------------------------------------------------------------------------
entity mixElement is
Generic(
    line : integer :=0  -- depending on the line, the multiplication changes
);
Port (
    dataOut : out std_logic_vector (7 downto 0);
    dataIn : in dataColumn ;
    clk : in std_logic ;
    enable : in std_logic ;
    rst : in std_logic
);
end mixElement;
---------------------------------------------------------------------------

architecture Behavioral of mixElement is

component LUT_mul2 port (
    byte_in : in STD_LOGIC_VECTOR (7 downto 0);
    byte_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component LUT_mul3 Port ( 
    byte_in : in STD_LOGIC_VECTOR (7 downto 0);
    byte_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal mul2in : std_logic_vector (7 downto 0):=x"00";
signal mul2out : std_logic_vector (7 downto 0);
signal mul3in : std_logic_vector (7 downto 0):=x"00";
signal mul3out : std_logic_vector (7 downto 0);

signal result : std_logic_vector (7 downto 0):= x"00";  -- initial value of output is zero

---------------------------------------------------------------------------
begin
    
    dataOut <= result;  -- Make sure output is at zero value
    
    mul2 : LUT_mul2 port map(byte_in => DataIn(line),byte_out => mul2out);
    mul3 : LUT_mul3 port map(byte_in => DataIn((line+1) mod 4),byte_out => mul3out);
    
    mul2in <= DataIn(line);     -- Depending on line, we multiply by 2 one element of dataIn column
    mul3in <= DataIn((line+1) mod 4);   -- Very important to put that outside the process, we must first compute the output of mul2/3

    mixingOneElement : process (clk) begin
        if rising_edge (clk) then
            if rst = '1' then       -- synchronous reset
                result <= (others =>  '0' );
            elsif enable ='1' and rst = '0' then
                result <= dataIn((line+2) mod 4) xor dataIn((line+3) mod 4) xor mul2out xor mul3out;    -- Xor operation for output
            end if;
        end if;
    end process;
    
end Behavioral;
---------------------------------------------------------------------------