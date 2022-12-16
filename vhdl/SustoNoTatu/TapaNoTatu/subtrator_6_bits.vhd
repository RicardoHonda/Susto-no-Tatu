-------------------------------------------------------------------
-- Arquivo   : subtrator_6_bits.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------
-- Descricao : Subtrator binario de 6 bits, usado para
--             remover uma toupeira apos uma jogada valida.
--             Realiza a operacao A - B
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity subtrator_6_bits is
  port (
    i_A          : in  std_logic_vector(5 downto 0);
    i_B          : in  std_logic_vector(5 downto 0);
    resultado    : out std_logic_vector(5 downto 0); -- Resultado da subtracao
    tem_toupeira : out std_logic -- Booleana que indica se restou alguma toupeira
  );
end entity subtrator_6_bits;

architecture dataflow of subtrator_6_bits is
  signal s_res : std_logic_vector(5 downto 0);
begin
  subtracao: for i in 5 downto 0 generate
    s_res(i) <= (i_A(i) xor i_B(i)) and i_A(i);
  end generate;

  resultado <= s_res;
  tem_toupeira <= s_res(5) or s_res(4) or s_res(3) or s_res(2) or s_res(1) or s_res(0);
end architecture dataflow;
