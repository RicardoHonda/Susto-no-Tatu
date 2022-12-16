-------------------------------------------------------------------
-- Arquivo   : comparador_85.vhd
-- Projeto   : Experiencia 02 - Um Fluxo de Dados Simples
-------------------------------------------------------------------
-- Descricao : comparador binario de 4 bits 
--             similar ao CI 7485
--             baseado em descricao criada por Edson Gomi (11/2017)
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     02/01/2021  1.0     Edson Midorikawa  criacao
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity comparador_85 is
  port (
    A : in std_logic_vector(3 downto 0);
    B : in std_logic_vector(3 downto 0);
    i_AGTB : in  std_logic;
    i_ALTB : in  std_logic;
    i_AEQB : in  std_logic;
    o_AGTB : out std_logic;
    o_ALTB : out std_logic;
    o_AEQB : out std_logic
  );
end entity comparador_85;

architecture dataflow of comparador_85 is
  signal agtb : std_logic; -- Sinal interno para armazenar se A > B
  signal aeqb : std_logic; -- Sinal interno para armazenar se A = B
  signal altb : std_logic; -- Sinal interno para armazenar se A < B
begin
  -- equacoes dos sinais: pagina 462, capitulo 6 do livro-texto
  -- Wakerly, J.F. Digital Design - Principles and Practice, 4th Edition
  -- veja tambem datasheet do CI SN7485 (Function Table)

  -- A condição estabelecida para A ser maior que B é dado uma determinada posição n, o Bit An deve ser 1, 
  -- o bit Bn deve ser 0 e os bits mais significativos devem ser equivalentes.
  agtb <= (A(3) and not(B(3))) or
          (not(A(3) xor B(3)) and A(2) and not(B(2))) or
          (not(A(3) xor B(3)) and not(A(2) xor B(2)) and A(1) and not(B(1))) or
          (not(A(3) xor B(3)) and not(A(2) xor B(2)) and not(A(1) xor B(1)) and A(0) and not(B(0)));

  -- A averiguação da equivalência é dada através de um ou exclusivo entre os bits correspondentes.
  -- Caso alguma dupla de bit for diferente, aeqb recebe 0, e caso contrário, recebe 1
  aeqb <= not((A(3) xor B(3)) or (A(2) xor B(2)) or (A(1) xor B(1)) or (A(0) xor B(0)));
  altb <= not(agtb or aeqb); -- A será menor que B se ele não for maior nem igual

  -- saidas
  o_AGTB <= agtb or (aeqb and (not(i_AEQB) and not(i_ALTB))); -- Recebe 1 caso A > B ou A = B com as entradas comparativas em baixo, exceto a de maioridade
  o_ALTB <= altb or (aeqb and (not(i_AEQB) and not(i_AGTB))); -- Recebe 1 caso A < B ou A = B com as entradas comparativas em baixo, exceto a de menoridade 
  o_AEQB <= aeqb and i_AEQB; -- Recebe 1 caso A = B e a entrade comparativa de equivalência seja 1 
  
end architecture dataflow;
