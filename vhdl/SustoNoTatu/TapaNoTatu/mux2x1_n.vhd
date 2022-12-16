--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2020  1.0     Edson Midorikawa  criacao
--     04/02/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity mux2x1_n is
    generic (
        constant BITS: integer := 4
    );
    port(
        D0      : in  std_logic_vector (BITS-1 downto 0);
        D1      : in  std_logic_vector (BITS-1 downto 0);
        SEL     : in  std_logic;
        MUX_OUT : out std_logic_vector (BITS downto 0)
    );
end entity;

architecture comportamental of mux2x1_n is
begin

    MUX_OUT <= SEL & D0 when (SEL = '0') else
               SEL & D1 when (SEL = '1') else
               (others => '1');

end architecture;
