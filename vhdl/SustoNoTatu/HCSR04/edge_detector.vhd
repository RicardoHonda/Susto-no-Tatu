------------------------------------------------------------------
-- Arquivo   : edge_detector.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : detector de borda de subida 
--             > usado para tratar pulsos largos de entrada
--             > 
-- baseado em codigo disponivel na url
-- http://fpgacenter.com/examples/basic/edge_detector.php
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
end entity edge_detector;

architecture Behavioral of edge_detector is
    signal signal_d : std_logic;
begin
    process(clock)
    begin
        if clock= '1' and clock'event then
           signal_d <= signal_in;
        end if;
    end process;

    output <= (not signal_d) and signal_in; 

end architecture Behavioral;