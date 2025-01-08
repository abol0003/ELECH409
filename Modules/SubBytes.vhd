library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all; 

entity SubBytes is
    Port (
        clk : in STD_LOGIC;
        data_in : in dataMatrix; 
        data_out : out dataMatrix;
        enable : in std_logic;
        rst : in std_logic 
    );
end SubBytes;

architecture Behavioral of SubBytes is

    -- Import component
    component S_box is
        Port ( 
            byte_in : in STD_LOGIC_VECTOR(7 downto 0);
            byte_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal sbox_out : dataMatrix;   -- Sbox out signal
    signal SubMatrix : dataMatrix := (others => (others => x"00"));

begin

    S_box_gen: for i in 0 to 3 generate     -- Use generate with Sbox for dataMatrix
        S_box_row: for j in 0 to 3 generate
            S_box_inst : S_box
                port map (
                    byte_in => data_in(i,j),            
                    byte_out => sbox_out(i,j)          
                );
        end generate S_box_row;
    end generate S_box_gen;
    
    data_out <= SubMatrix ;     -- Makes sure that output is at zero at init

    SubBytes : process (clk) begin
        if rising_edge(clk) then
        -- Synchronous reset
            if rst = '1' then
                SubMatrix <= (others => (others => x"00"));     -- output at zero
            elsif enable = '1' and rst ='0' then
                SubMatrix <= sbox_out;
            end if;
        end if;
    end process;

end Behavioral;
