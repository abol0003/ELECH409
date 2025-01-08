-- Ce module est un compteur param�trisable, impl�menter avec une state machine

-- Librairies --------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
----------------------------------------------------------------------------------------------------


-- D�finition du module
----------------------------------------------------------------------------------------------------
entity BitCounter is
generic(N : integer :=2);
Port ( 
    Clk : in std_logic ;
    En : in std_logic ;
    Rst : in std_logic ;                    
    Q : out std_logic_vector (N-1 downto 0) -- L'output, la valeur que le compteur incr�mente
);
end BitCounter;
----------------------------------------------------------------------------------------------------

-- D�finition de l'architecture : on d�finit les signaux utiles
----------------------------------------------------------------------------------------------------
architecture Behavioral of BitCounter is

    type stateType is (increment,idle,reset);
    signal currentState,nextState : stateType;
    signal prevCount : std_logic_vector (N-1 downto 0):=std_logic_vector (TO_UNSIGNED (0,N)); 
    signal Count : std_logic_vector (N-1 downto 0);
    
-- Architecture
----------------------------------------------------------------------------------------------------
begin
    Q <= Count;
    fsm1 : process(En, currentState,prevCount) begin -- Attention � la sensitivity list
        case currentState is
        
            when idle => Count <= prevCount; --add memory for prev and next count
                case En is
                    when '1' => nextState <= increment;
                    when '0' => nextState <= idle;
                    when others => nextState <= reset;
                end case;
                
            when increment => Count <= std_logic_vector(unsigned (prevCount)+1);
                case En is
                    when '1' => nextState <= increment;
                    when '0' => nextState <= idle;
                    when others => nextState <= reset;
                end case;
                
            when reset => Count <= std_logic_vector (TO_UNSIGNED (0,N));
                case En is
                    when '1' => nextState <= increment;
                    when '0' => nextState <= idle;
                    when others => nextState <= reset;
                end case;
            
        end case;
    end process;

    fsm2 : process(Rst,Clk) begin
        if (Rst='1') then 
            currentState <= reset;
            prevCount <=std_logic_vector (TO_UNSIGNED (0,N));
              
        elsif (rising_edge (Clk)) then 
            currentState <= nextState;
            prevCount <= Count;
               
        end if;
    end process;
end Behavioral;
----------------------------------------------------------------------------------------------------