-------------------------------------------------------------------
-- Arquivo   : comparador_6_bits.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------
-- Descricao : comparador binario de 6 bits, que verifica se
--             a jogada realizada eh valida
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity comparador_6_bits is
  port (
    i_A5    : in  std_logic;
    i_B5    : in  std_logic;
    i_A4    : in  std_logic;
    i_B4    : in  std_logic;
    i_A3    : in  std_logic;
    i_B3    : in  std_logic;
    i_A2    : in  std_logic;
    i_B2    : in  std_logic;
    i_A1    : in  std_logic;
    i_B1    : in  std_logic;
    i_A0    : in  std_logic;
    i_B0    : in  std_logic;
    o_ASEQB : out std_logic -- A "semiequal" B, indicando que Ai == Bi == 1, para algum i
  );
end entity comparador_6_bits;

architecture dataflow of comparador_6_bits is
begin

  o_ASEQB <= (i_A5 and i_B5) or (i_A4 and i_B4) or (i_A3 and i_B3) or
             (i_A2 and i_B2) or (i_A1 and i_B1) or (i_A0 and i_B0);
  
end architecture dataflow;
