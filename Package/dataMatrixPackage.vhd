-- This package is used to implement matrix of 4x4 bytes as valid type port
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package myDataMatrix is
    
    -- We declare the type here
    type dataMatrix is array(0 to 3,0 to 3) of std_logic_vector (7 downto 0);
    type dataColumn is array(0 to 3) of std_logic_vector (7 downto 0);
    type dataText is array(0 to 3) of std_logic_vector (127 downto 0);

end package myDataMatrix;

package body myDataMatrix is -- leave this empty
end package body myDataMatrix;
