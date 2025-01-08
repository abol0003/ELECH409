-- Ce module repr�sente un segment individuel. 
-- Ici on g�re le mapping entre 4 bits d'input et la valeur de CB,CA,... pour afficher ce nombre en hexad�cimal

-- Librairies --------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
----------------------------------------------------------------------------------------------------


-- D�finition du module
----------------------------------------------------------------------------------------------------
entity sevenSegmentDisplay is
Port (
    clk : in std_logic ;
    segment : out std_logic_vector(6 downto 0) ;
    anode : out std_logic ; -- we'll link this to an[x] when we do port map
    inputNumber : in std_logic_vector (3 downto 0) ;
    enable : in std_logic 
 );
end sevenSegmentDisplay;
----------------------------------------------------------------------------------------------------

-- D�finition de l'architecture : on d�finit les signaux utiles et les submodules
----------------------------------------------------------------------------------------------------
architecture Behavioral of sevenSegmentDisplay is

-- Architecture
----------------------------------------------------------------------------------------------------
begin

-- Convertir l'input en hexad�cimal -> case

convertBitToLed : process(clk,inputNumber,enable) begin -- attention sensitivity list

    if (rising_edge (clk)) then 
        if (enable='1') then    -- Si j'autorise l'affichage, je mets l'anode � 0 et selon l'input, je choisis CB,CA,...
        anode <='0';
            case inputNumber is
                when "0000" => segment <= "1000000"; --GFEDCBA
                when "0001" => segment <= "1111001";
                when "0010" => segment <= "0100100";
                when "0011" => segment <= "0110000";
                when "0100" => segment <= "0011001";
                when "0101" => segment <= "0010010";
                when "0110" => segment <= "0000010";
                when "0111" => segment <= "1111000";
                when "1000" => segment <= "0000000";
                when "1001" => segment <= "0010000";
                when "1010" => segment <= "0001000";
                when "1011" => segment <= "0000011";
                when "1100" => segment <= "1000110";
                when "1101" => segment <= "0100001";
                when "1110" => segment <= "0000110";
                when "1111" => segment <= "0001110";
                when others => segment <= "0000001";     
            end case;
        else anode <='1'; -- tr�s important de remettre ceci � 1 si on n'affiche rien
        end if;
    end if;        

end process;
end Behavioral;
----------------------------------------------------------------------------------------------------