-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : subtrator_m.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity subtrador_m is
    port (
        clock      : in  std_logic;
        load       : in  std_logic;
        load_value : in integer;
        conta      : in  std_logic;
        Q          : out integer;
        fim        : out std_logic
    );
end entity subtrador_m;

architecture comportamental of subtrador_m is
    signal IQ: integer;
begin
  
    process (clock,load,conta,IQ)
    begin
        if load='1' then    IQ <= load_value;   
        elsif rising_edge(clock) then
            if conta='1' then 
                if IQ=0 then IQ <= 0; 
                else         IQ <= IQ - 1000000; 
                end if;
            else             IQ <= IQ;
            end if;
        end if;
    end process;

    -- saida fim
    fim <= '1' when IQ=0 else
           '0';

    Q <= IQ;

end architecture comportamental;
