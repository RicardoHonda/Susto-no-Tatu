--------------------------------------------------------------------------
-- Arquivo   : circuito_final_tb.vhd
-- Projeto   : Tapa no Tatu
--
-- Atenção   : Este testbench foi utilizado em fases iniciais do projeto,
--             estando desatualizado em relação ao funcionamento da 
--             versão final do projeto
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity susto_no_tatu_tb is
end entity;

architecture tb of susto_no_tatu_tb is

    -- Componente a ser testado (Device Under Test -- DUT)
    component susto_no_tatu is
        port (
            clock       : in  std_logic;
            reset       : in  std_logic;
            iniciar     : in  std_logic;
            echo_01     : in  std_logic;
            echo_02     : in  std_logic;
            echo_11     : in  std_logic;
            echo_12     : in  std_logic;
            dificuldade : in  std_logic;
            botoes      : in  std_logic_vector(5 downto 0);
            trigger_01  : out std_logic;
            trigger_02  : out std_logic;
            trigger_11  : out std_logic;
            trigger_12  : out std_logic;
            pwm_tatu_00 : out std_logic;
            pwm_tatu_01 : out std_logic;
            pwm_tatu_02 : out std_logic;
            pwm_tatu_10 : out std_logic;
            pwm_tatu_11 : out std_logic;
            pwm_tatu_12 : out std_logic;
            serial      : out std_logic;
            vidas       : out std_logic_vector (1 downto 0);
            pontuacao1  : out std_logic_vector (6 downto 0);
            pontuacao2  : out std_logic_vector (6 downto 0)
        );
    end component susto_no_tatu;

    ---- Declaracao de sinais de entrada
    signal clock_in           : std_logic := '0';
    signal reset_in           : std_logic := '0';
    signal iniciar_in         : std_logic := '0';
    signal echo_01_in         : std_logic := '0';
    signal echo_02_in         : std_logic := '0';
    signal echo_11_in         : std_logic := '0';
    signal echo_12_in         : std_logic := '0';
    signal dificuldade_in     : std_logic := '0';
    signal botoes_in          : std_logic_vector(5 downto 0) := "000000";

    ---- Declaracao dos sinais de saida
    signal trigger_01_out      : std_logic := '0';
    signal trigger_02_out      : std_logic := '0';
    signal trigger_11_out      : std_logic := '0';
    signal trigger_12_out      : std_logic := '0';
    signal pwm_tatu_00_out     : std_logic := '0';
    signal pwm_tatu_01_out     : std_logic := '0';
    signal pwm_tatu_02_out     : std_logic := '0';
    signal pwm_tatu_10_out     : std_logic := '0';
    signal pwm_tatu_11_out     : std_logic := '0';
    signal pwm_tatu_12_out     : std_logic := '0';
    signal vidas_out           : std_logic_vector(1 downto 0) := "00";
    signal pontuacao1_out      : std_logic_vector(6 downto 0) := "0000000";
    signal pontuacao2_out      : std_logic_vector(6 downto 0) := "0000000";
    signal serial_out          : std_logic := '0';

    -- Identificacao de casos de teste
    signal caso     : integer := 0;

    -- Configurações do clock
    signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod   : time := 1 ms;     -- frequencia 1 KHz

begin
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado.
    -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

    ---- DUT para Caso de Teste 2
    dut: susto_no_tatu
        port map (
            clock       => clock_in,
            reset       => reset_in,
            iniciar     => iniciar_in,
            echo_01     => echo_01_in,
            echo_02     => echo_02_in,
            echo_11     => echo_11_in,
            echo_12     => echo_12_in,
            dificuldade => dificuldade_in,
            botoes      => botoes_in,
            trigger_01  => trigger_01_out,
            trigger_02  => trigger_02_out,
            trigger_11  => trigger_11_out,
            trigger_12  => trigger_12_out,
            pwm_tatu_00 => pwm_tatu_00_out,
            pwm_tatu_01 => pwm_tatu_01_out,
            pwm_tatu_02 => pwm_tatu_02_out,
            pwm_tatu_10 => pwm_tatu_10_out,
            pwm_tatu_11 => pwm_tatu_11_out,
            pwm_tatu_12 => pwm_tatu_12_out,
            serial      => serial_out,
            vidas       => vidas_out,
            pontuacao1  => pontuacao1_out,
            pontuacao2  => pontuacao2_out

    --------------------------------------------------------
    -- Cenario de Teste #1: acerta as primeiras 2 jogadas --
    --                      e erra as 3 jogadas seguintes --
    --------------------------------------------------------
    stimulus: process is
        begin

            -- inicio da simulacao
            assert false report "inicio da simulacao" severity note;
            keep_simulating <= '1';

            -- Caso 1 - Reset
            caso <= 1;
            reset_in <= '1';
            wait for clockPeriod;
            reset_in <= '0';

            -- Caso 2 - Inicio do jogo
            caso <= 2;
            wait until falling_edge(clock_in);
            -- pulso do sinal de Iniciar
            iniciar_in <= '1';
            wait until falling_edge(clock_in);
            iniciar_in <= '0';

            -- Caso 3 - Escolhe dificuldade
            caso <= 3;
            dificuldade_in <= "01";

            -- Caso 4 - Mostra jogada
            caso <= 4;
            wait for 4*clockPeriod; -- preparacaoGeral, geraJogada(000001) e mostraJogada

            -- Caso 5 - Faz jogada certa (1a jogada)
            caso <= 5;
            botoes_in <= "000001"; -- mostraJogada, registraJogada, avaliaJogada, somaPontaucao, removeTatu, reduzTempo, mostraApagado (5 clocks)
            wait for 11*clockPeriod;
            botoes_in <= "000000";
            wait for 2*clockPeriod; -- geraJogada(100000), mostraJogada

            -- Caso 6 - Faz jogada certa (2a jogada)
            caso <= 6;
            botoes_in <= "100000";
            wait for 11*clockPeriod; -- mostraJogada, registraJogada, avaliaJogada, somaPontaucao, removeTatu, reduzTempo, mostraApagado (5 clocks)
            botoes_in <= "000000";
            wait for 2*clockPeriod; -- geraJogada(010000), mostraJogada

            -- Caso 7 - Faz jogada errada (1/3)
            caso <= 7;
            botoes_in <= "100000";
            wait for 11*clockPeriod; -- registraJogada, avaliaJogada, reduzVida, verificaVida, reduzTempo, mostraApagado (5 clocks)
            botoes_in <= "000000";
            wait for 2*clockPeriod; -- geraJogada(101000), mostraJogada
            
            -- Caso 8 - Faz jogada errada (2/3)
            caso <= 8;
            botoes_in <= "000001";
            wait for 11*clockPeriod; -- registraJogada, avaliaJogada, reduzVida, verificaVida, reduzTempo, mostraApagado (5 clocks)
            botoes_in <= "000000";
            wait for 2*clockPeriod; -- geraJogada(110100), mostraJogada

            -- Caso 9 - Faz jogada errada (3/3)
            caso <= 9;
            botoes_in <= "000010";
            wait for 6*clockPeriod; -- mostraJogada, registraJogada, avaliaJogada, reduzVida, verificaVida, fimJogo

        ---- final do testbench
        assert false report "fim da simulacao" severity note;
        keep_simulating <= '0';

        wait; -- fim da simulação: processo aguarda indefinidamente
    end process;
end architecture;
