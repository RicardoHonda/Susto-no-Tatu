------------------------------------------------------------------
-- Arquivo   : analisa_m.vhd
-- Projeto   : Experiencia 4 - Interface com Sensor de Distancia
------------------------------------------------------------------
-- Descricao : analisa valor binario de entrada
--             > parametro M: modulo
--
--             saidas zera, meio, fim e metade_superior
--
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2022  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity analisa_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        valor            : in  std_logic_vector (N-1 downto 0);
        zero             : out std_logic;
        meio             : out std_logic;
        fim              : out std_logic;
        metade_superior  : out std_logic
    );
end entity analisa_m;

architecture comportamental of analisa_m is
    signal v: integer range 0 to M-1;
begin
  
    v <= to_integer(unsigned(valor));

    zero            <= '1' when v=0 else '0';
    meio            <= '1' when v=M/2 else '0';
    fim             <= '1' when v=M-1 else '0';
    metade_superior <= '1' when v>=M/2 else '0';

end architecture;