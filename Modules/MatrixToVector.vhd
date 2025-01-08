library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.myDataMatrix.all;

entity MatrixToVector is
    -- Transform a 4x4 matrix into a 128-bit vector
    Port (
        mat_in  : in  dataMatrix;
        vec_out : out std_logic_vector(127 downto 0)
    );
end MatrixToVector;

architecture Behavioral of MatrixToVector is
    -- Function to convert matrix to vector
    function MatToVec(mat: dataMatrix) return std_logic_vector is
        variable vec: std_logic_vector(127 downto 0) := (others => '0'); 
    begin
        for j in 0 to 3 loop -- Columns
            for i in 0 to 3 loop -- Rows
                vec(((3 - j) * 32) + ((3 - i) * 8) + 7 downto ((3 - j) * 32) + ((3 - i) * 8)) := mat(i, j);
            end loop;
        end loop;
        return vec; 
    end function;

begin
    vec_out <= MatToVec(mat_in);
end Behavioral;
