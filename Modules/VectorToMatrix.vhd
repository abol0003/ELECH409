library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.myDataMatrix.all;

entity VectorToMatrix is
    -- Transform a 128-bit vector into a 4x4 matrix
    Port (
        vec_in  : in std_logic_vector(127 downto 0);
        mat_out : out dataMatrix
    );
end VectorToMatrix;

architecture Behavioral of VectorToMatrix is
    -- Function to convert vector to matrix
    function VecToMat(vec: std_logic_vector(127 downto 0)) return dataMatrix is
        variable mat: dataMatrix := (others => (others => (others => '0'))); -- Initialize matrix
    begin
        for j in 0 to 3 loop --  columns
            for i in 0 to 3 loop --  rows
                -- Calculate the range of bits in the vector for mat(i, j):
                -- (3 - j): Reverses column order to match the vector organization
                -- (3 - j) * 32: Offset for the start of the column in the vector
                -- (3 - i): Reverses row order to match the vector organization
                -- (3 - i) * 8: Offset within the column for the row
                -- + 7: Ensures we include all 8 bits of the element
                mat(i, j) := vec(((3 - j) * 32) + ((3 - i) * 8) + 7 downto ((3 - j) * 32) + ((3 - i) * 8));
            end loop;
        end loop;
        return mat;
    end function;

begin
    mat_out <= VecToMat(vec_in);   
end Behavioral;
