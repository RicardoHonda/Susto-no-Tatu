--------------------------------------------------------------------
-- Arquivo   : contador_bcd_3digitos.vhd
-- Projeto   : Experiencia 4 - Interface com Sensor de Distancia
--------------------------------------------------------------------
-- Descricao : contador bcd com 3 digitos - modulo 1000
--             (descricao VHDL comportamental) 
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2020  1.2     Edson Midorikawa  revisao
--     09/09/2022  2.0     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_bcd_3digitos is 
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
end entity;

architecture comportamental of contador_bcd_3digitos is

    signal s_dig2, s_dig1, s_dig0 : unsigned(3 downto 0);

begin

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (zera = '1') then  -- reset sincrono
                s_dig0 <= "0000";
                s_dig1 <= "0000";
                s_dig2 <= "0000";
            elsif ( conta = '1' ) then
                if (s_dig0 = "1001") then
                    s_dig0 <= "0000";
                    if (s_dig1 = "1001") then
                        s_dig1 <= "0000";
                        if (s_dig2 = "1001") then
                            s_dig2 <= "0000";
                        else
                            s_dig2 <= s_dig2 + 1;
                        end if;
                    else
                        s_dig1 <= s_dig1 + 1;
                    end if;
                else
                    s_dig0 <= s_dig0 + 1;
                end if;
            end if;
        end if;
    end process;

    -- fim de contagem (comando VHDL when else)
    fim <= '1' when s_dig2="1001" and s_dig1="1001" and s_dig0="1001" else 
           '0';

    -- saidas
    digito2 <= std_logic_vector(s_dig2);
    digito1 <= std_logic_vector(s_dig1);
    digito0 <= std_logic_vector(s_dig0);

end architecture comportamental;
