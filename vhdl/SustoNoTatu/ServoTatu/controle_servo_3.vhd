-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : circuito_pwm.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
-------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL RTL gera saída digital com modulacao pwm
--
-- parametros de configuracao da saida pwm: CONTAGEM_MAXIMA e largura_pwm
-- (considerando clock de 50MHz ou periodo de 20ns)
--
-- CONTAGEM_MAXIMA=1250 gera um sinal periodo de 4 KHz (25us)
-- entrada LARGURA controla o tempo de pulso em 1:
-- 00=0 (saida nula), 01=pulso de 1us, 10=pulso de 10us, 11=pulso de 20us
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        posicao : in  std_logic;  
        pwm     : out std_logic
    );
end controle_servo;

architecture rtl of controle_servo is

    constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 50Hz ou periodo de 20ms
    constant ANGULO_MAXIMO   : integer := 180;
    
    signal contagem    : integer range 0 to CONTAGEM_MAXIMA-1;
    signal posicao_pwm : integer range 0 to CONTAGEM_MAXIMA-1;
    signal s_posicao   : integer range 0 to CONTAGEM_MAXIMA-1;
    signal s_angle     : integer range 0 to ANGULO_MAXIMO-1;
    signal s_pwm       : std_logic;

begin

    process(clock, reset, s_posicao)
    begin
        -- inicia contagem e largura
        if(reset='1') then
            contagem    <= 0;
            s_pwm       <= '0';
            posicao_pwm <= s_posicao;
        elsif(rising_edge(clock)) then
            -- saida
            if(contagem < posicao_pwm) then
                s_pwm  <= '1';
            else
                s_pwm  <= '0';
            end if;
            -- atualiza contagem e largura
            if(contagem=CONTAGEM_MAXIMA-1) then
                contagem    <= 0;
                posicao_pwm <= s_posicao;
            else
                contagem   <= contagem + 1;
            end if;
        end if;
    end process;

    process(posicao)
    begin
        case posicao is
            when '0'    => s_posicao <=  50000;  -- pulso de 1 ms (  0°)
            when '1'    => s_posicao <= 100000;  -- pulso de 2 ms (180°)
            when others => s_posicao <=      0;  -- nulo (saida 0)
        end case;
    end process;

  pwm <= s_pwm;
end rtl;
