----------------------------------------------------------------
-- Arquivo   : estado7seg.vhd
-- Projeto   : Jogo do Desafio da Memoria
----------------------------------------------------------------
-- Descricao : decodificador estado para 
--             display de 7 segmentos 
-- 
-- entrada: estado - codigo binario de 5 bits
-- saida:   sseg - codigo de 7 bits para display de 7 segmentos
----------------------------------------------------------------
-- dica de uso: mapeamento para displays da placa DE0-CV
--              bit 6 mais significativo eh o bit a esquerda
--              p.ex. sseg(6) -> HEX0[6] ou HEX06
----------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/02/2021  1.0     Edson Midorikawa  criacao
--     04/02/2022  1.1     Edson Midorikawa  revisao
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity estado7seg is
    port (
        estado : in  std_logic_vector(4 downto 0);
        sseg   : out std_logic_vector(6 downto 0)
    );
end entity estado7seg;

architecture comportamental of estado7seg is
begin

  sseg <= "1000000" when estado="00000" else  -- 0
          "1111001" when estado="00001" else  -- 1
          "0100100" when estado="00010" else  -- 2
          "0110000" when estado="00011" else  -- 3
          "0011001" when estado="00100" else  -- 4
          "0010010" when estado="00101" else  -- 5
          "0000010" when estado="00110" else  -- 6
          "1111000" when estado="00111" else  -- 7
          "0000000" when estado="01000" else  -- 8
          "0010000" when estado="01001" else  -- 9
          "0001000" when estado="01010" else  -- A
          "0000011" when estado="01011" else  -- B
          "1000110" when estado="01100" else  -- C
          "0100001" when estado="01101" else  -- D
          "0000110" when estado="01110" else  -- E
          "0001110" when estado="01111" else  -- F
          "1111110" when estado="10000" else  -- 10
          "1111101" when estado="10001" else  -- 11
          "1111011" when estado="10010" else  -- 12
          "1110111" when estado="10011" else  -- 13
          "1101111" when estado="10100" else  -- 14
          "1011111" when estado="10101" else  -- 15
          "0111111" when estado="10110" else  -- 16
          "1111100" when estado="10111" else  -- 17
          "0111100" when estado="11000" else  -- 18
          "0011100" when estado="11001" else  -- 19
          "1110011" when estado="11010" else  -- 1A
          "1100011" when estado="11011" else  -- 1B
          "0100011" when estado="11100" else  -- 1C
          "1011101" when estado="11101" else  -- 1D
          "1101011" when estado="11110" else  -- 1E
          "1001001" when estado="11111" else  -- 1F
          "1111111";

end architecture comportamental;



