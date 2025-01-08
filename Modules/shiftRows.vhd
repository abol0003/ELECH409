-- The bytes in the last three rows are cyclically shifted to the left over 
-- a number equal to the row number. The first row is not shifted
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;

entity shiftRows is
Port ( 
    DataIn : in dataMatrix;
    DataOut : out dataMatrix;
    clk : in std_logic;
    enable : in std_logic ;
    rst : in std_logic 
);
end shiftRows;

architecture Behavioral of shiftRows is

signal shiftedDataMatrix : dataMatrix := (others => (others => x"00"));
    
begin
    DataOut <= shiftedDataMatrix;
    shifting : process(clk) begin    
        if rising_edge (clk) then       -- Synchronous reset
            if rst = '1' then
                shiftedDataMatrix <= (others => (others => x"00"));
            elsif enable = '1' and rst = '0' then
                shiftedDataMatrix <= DataIn;
                for i in 1 to 3 loop -- since we don't change first row, skip the first row
                    for j in 0 to 3 loop
                        shiftedDataMatrix(i,j) <= DataIn(i,(j+i) mod 4); -- shifting operation in one line
                    end loop;
                end loop;
            end if;
        end if;
    end process;
end Behavioral;
