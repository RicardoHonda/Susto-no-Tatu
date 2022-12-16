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
entity circuito_final_tb is
end entity;

architecture tb of circuito_final_tb is

    -- Componente a ser testado (Device Under Test -- DUT)
    component circuito_tapa_no_tatu
        port (
            clock       : in std_logic;
            reset       : in std_logic;
            iniciar     : in std_logic;
            botoes      : in std_logic_vector(5 downto 0);
            dificuldade : in std_logic_vector(1 downto 0);
            leds        : out std_logic_vector(5 downto 0);
            fimDeJogo   : out std_logic;
            pontuacao   : out std_logic_vector (6 downto 0);
            vidas       : out std_logic_vector (1 downto 0);
            display1    : out std_logic_vector (6 downto 0);
            display2    : out std_logic_vector (6 downto 0);
            -- Sinais de depuração
            db_estado       : out std_logic_vector (6 downto 0);
            db_jogadaFeita  : out std_logic;
            db_jogadaValida : out std_logic;
            db_timeout      : out std_logic
        );
    end component;

    ---- Declaracao de sinais de entrada
    signal clock_in           : std_logic := '0';
    signal reset_in           : std_logic := '0';
    signal iniciar_in         : std_logic := '0';
    signal botoes_in          : std_logic_vector(5 downto 0) := "000000";
    signal dificuldade_in     : std_logic_vector(1 downto 0) := "00";

    ---- Declaracao dos sinais de saida
    signal leds_out           : std_logic_vector(5 downto 0) := "000000";
    signal fimDeJogo_out      : std_logic := '0';
    signal pontuacao_out      : std_logic_vector(6 downto 0) := "0000000";
    signal vidas_out          : std_logic_vector(1 downto 0) := "00";
    signal display1_out       : std_logic_vector(6 downto 0) := "0000000";
    signal display2_out       : std_logic_vector(6 downto 0) := "0000000";
    signal db_estado_out      : std_logic_vector(6 downto 0) := "0000000";
    signal db_jogadaFeita_out : std_logic := '0';
    signal db_jogadaValida_out: std_logic := '0';
    signal db_timeout_out     : std_logic := '0';

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
    dut: circuito_tapa_no_tatu
         port map
         (
            clock           => clock_in,
            reset           => reset_in,
            iniciar         => iniciar_in,
            botoes          => botoes_in,
            dificuldade     => dificuldade_in,
            leds            => leds_out,
            fimDeJogo       => fimDeJogo_out,
            pontuacao       => pontuacao_out,
            vidas           => vidas_out,
            display1        => display1_out,
            display2        => display2_out,
            db_estado       => db_estado_out,
            db_jogadaFeita  => db_jogadaFeita_out,
            db_jogadaValida => db_jogadaValida_out,
            db_timeout      => db_timeout_out
         );

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
