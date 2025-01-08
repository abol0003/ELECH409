-- Each column is multiplied by a constant matrix c(x)
-- (Galois field multiplications)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;
---------------------------------------------------------------------------
entity mixColumns is
Port ( 
    DataIn : in dataMatrix;
    DataOut : out dataMatrix;
    clk : in std_logic;
    enable : in std_logic ;
    rst : in std_logic 
);
end mixColumns;
---------------------------------------------------------------------------

architecture Behavioral of mixColumns is

component mixElement
Generic(
    line : integer :=0  -- depending on the line, the multiplication changes
);
Port (
    dataOut : out std_logic_vector (7 downto 0);
    dataIn : in dataColumn ;
    clk : in std_logic ;
    enable : in std_logic;
    rst : in std_logic 
);
end component;

---------------------------------------------------------------------------
begin

    mixingColumn : for j in 0 to 3 generate     -- We generate 16 (4x4 matrix) mixElement
        signal dataCol : dataColumn;    -- /!\ VERY IMPORTANT TO PUT THAT SPECIFICALLY HERE, otherwise error
        begin
            dataCol <= (DataIn(0,j),DataIn(1,j),DataIn(2,j),DataIn(3,j));   -- dataCol is one column of dataIn
            mixingLine : for i in 0 to 3 generate
                begin
                    mixingOneElement : mixElement 
  
                    generic map (line => i)
                    port map (
                        dataIn => dataCol,
                        dataOut => DataOut(i,j), 
                        clk =>clk, enable => enable, 
                        rst => rst);
                
        end generate mixingLine;
    end generate mixingColumn;
    
end Behavioral;
