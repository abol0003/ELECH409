library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.myDataMatrix.all;  

entity AddRoundKey is
    Port (
        clk : in std_logic;
        enable : in std_logic; 
        data_in : in dataMatrix;
        round_key : in dataMatrix;
        data_out : out dataMatrix;
        rst : in std_logic 
    );
end AddRoundKey;

architecture Behavioral of AddRoundKey is

signal AddKeyMatrix : dataMatrix := (others => (others => x"00"));

begin
    
    data_out <= AddKeyMatrix ;  -- Makes sure that initial output is at zero if we don't use rst when init
    
    AddKey : process(clk) begin
        
        if rising_edge(clk) then
            -- Syncrhonous reset      
            if rst='1' then
                AddKeyMatrix <= (others => (others => x"00"));
                
            elsif enable = '1' and rst = '0' then    
                --  Application of XOR through each matrix element
                for i in 0 to 3 loop
                    for j in 0 to 3 loop
                        AddKeyMatrix(i, j) <= data_in(i, j) XOR round_key(i, j);
                    end loop;
                end loop;
            end if ;
        end if;  
    end process;
end Behavioral;