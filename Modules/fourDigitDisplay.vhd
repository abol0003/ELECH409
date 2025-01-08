-- Ce module représente les 4 segments. On gère dans ce fichier le timing de l'affichage
-- L'explication du timing se fait just au-dessus du process

-- Librairies --------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
----------------------------------------------------------------------------------------------------

-- Définition du module
----------------------------------------------------------------------------------------------------
entity fourDigitDisplay is
Port (
    clk : in std_logic ;
    segmentFour : out std_logic_vector(6 downto 0) ; -- Ceci est le bus qui doit être connecté à CB,CA,...
    anodeFour : out std_logic_vector(3 downto 0) ; -- les anodes des quatres segments
    input16Number : in std_logic_vector (15 downto 0) -- le nombre qu'on veut afficher
 );
end fourDigitDisplay;
----------------------------------------------------------------------------------------------------

-- Définition de l'architecture : on définit les submodules et les signaux utiles
----------------------------------------------------------------------------------------------------
architecture Behavioral of fourDigitDisplay is

-- Nos segments
component sevenSegmentDisplay is port(
    clk : in std_logic ;
    segment : out std_logic_vector(6 downto 0) ;
    anode : out std_logic ; -- we'll link this to an[x] when we do port map
    inputNumber : in std_logic_vector (3 downto 0) ;
    enable : in std_logic 
);
end component;

-- utilisé pour diviser la fréquence de 100MHz à 1000Hz
component BitCounter is
generic (N : integer := 2);
port(
    Clk : in std_logic ;
    En : in std_logic ;
    Rst : in std_logic ;
    Q : out std_logic_vector (N-1 downto 0) 
);
end component;

signal rst : std_logic :='0';                          -- rst pour le compteur/diviseur de fréq.
signal selector : std_logic_vector (1 downto 0):="00"; -- compteur qui sélectionne le bon proch. segment
signal clockdividerQ : std_logic_vector (19 downto 0); -- le nombre que doit atteindre le compteur pour diviser la fréq.
signal En : std_logic :='1';                           -- Active l'incrémentation du compteur/diviseur, tjs à 1
signal enableDisplay : std_logic_vector(3 downto 0) :="0000"; -- Choisit quel segment affiche (donc anode <= '0')
signal wireSegSelec : std_logic_vector (27 downto 0);  -- Bus de chaque segment qui les à relie CB,CA,..

-- Architecture
----------------------------------------------------------------------------------------------------
begin

-- Initialise nos submodules

-- 4 segments. Remarque les downto pour le port map
Display : for i in 3 downto 0 generate
    mySevenSegment : sevenSegmentDisplay port map(clk => clk, segment => wireSegSelec(7*i+6 downto 7*i),anode=> anodeFour(i), 
    inputNumber =>input16Number( 4*i+3 downto 4*i), enable => enableDisplay(i) );    
end generate;

-- D'après le fichier sur le labo, on veut au moins 1ms de période -> 1000Hz
-- Notre clock fait 100MHz, il faut donc le diviser par 100k à l'aide d'un compteur pour obtenir une fréq de 1000Hz
-- 100MHz/1000Hz=100k
-- Pour 100k, on a besoin d'un compteur de 20 bits : log(100k)/log(2)
clockdivider : BitCounter
    generic map (N => 20) 
    port map(Clk => clk,En => En,Rst => rst,Q => clockdividerQ);

-- Process. Bien comprendre
-- Le diviseur de compteur fonctionn de la manière suivante :
-- Pour diviser la fréq, on compte jusqu'à un nombre. Ici c'est 99.999
-- Atteindre 99.999 veut dire laisser s'écouler 100k périodes de clock (pas sûr si c'est 100k ou 99k)
-- 100k qui s'écoule revient à un temps de 1ms qui s'écoule. Donc on atteint la valeur voulue !
-- Après 1ms, on affiche 4 bits sur un des segments
-- A chaque affichage, on switch de segment
-- On appelle ce procédé le clock enable, il permet d'utiliser un clk "virtuelle" au lieu de générer un vrai nouveau clk
displayProcess : process(clk,selector,clockdividerQ) begin 

    if rising_edge (clk ) then 
        if clockdividerQ=x"1869F" then  --1869F is 99.999
            rst <= '1';                 -- Il faut reset sinon le compteur compte jusque (2^20)-1
            case selector is    
                when "00" => enableDisplay <= "0001"; -- Pour le segment 3,2,1, enable vaut zéro donc pas affichage
                            segmentFour <= wireSegSelec(6 downto 0); -- multiplex, connecte les valeurs CB,CA,..
                                                                     -- calculées pour les 4 premiers bits à la sortie
                when "01" => enableDisplay <= "0010";
                            segmentFour <= wireSegSelec(13 downto 7);
                when "10" => enableDisplay <= "0100";
                            segmentFour <= wireSegSelec(20 downto 14);
                when "11" => enableDisplay <= "1000";
                            segmentFour <= wireSegSelec(27 downto 21);
                when others => enableDisplay <= "0000"; -- juste pour gérer les erreurs
                            segmentFour <= wireSegSelec(6 downto 0);
            end case;
            selector <= std_logic_vector (unsigned (selector)+1); -- select next segment
        else rst <='0';    -- on ne reset pas si on n'a pas atteint le bon nombre
        end if;
    end if;

end process;

end Behavioral;
----------------------------------------------------------------------------------------------------