--------------------------------------------------------------------
-- Arquivo   : hex7seg.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
--------------------------------------------------------------------
-- Descricao : decodificador hexadecimal para display de 7 segmentos
--             entrada hexa: valor binario de 4 bits
--             saida sseg: codigo 7 segmentos 
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     03/09/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity hex7seg is
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end entity;

architecture comportamental of hex7seg is
begin
    process (hexa)
    begin
        case hexa is
            when "0000" => sseg <= "1000000"; -- 0 40 
            when "0001" => sseg <= "1111001"; -- 1 79
            when "0010" => sseg <= "0100100"; -- 2 24
            when "0011" => sseg <= "0110000"; -- 3 30
            when "0100" => sseg <= "0011001"; -- 4 19
            when "0101" => sseg <= "0010010"; -- 5 12
            when "0110" => sseg <= "0000010"; -- 6 02
            when "0111" => sseg <= "1011000"; -- 7 58
            when "1000" => sseg <= "0000000"; -- 8 00
            when "1001" => sseg <= "0010000"; -- 9 10
            when "1010" => sseg <= "0001000"; -- A 08
            when "1011" => sseg <= "0000011"; -- B 03
            when "1100" => sseg <= "1000110"; -- C 46
            when "1101" => sseg <= "0100001"; -- D 21
            when "1110" => sseg <= "0000110"; -- E 06
            when others => sseg <= "0001110"; -- F 0E
        end case;
    end process;
end architecture comportamental;
