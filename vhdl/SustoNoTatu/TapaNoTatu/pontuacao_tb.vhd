--------------------------------------------------------------------------
-- Arquivo   : pontuacao_tb.vhd
-- Projeto   : Tapa no tatu
--                              
--------------------------------------------------------------------------
-- Descricao : testbench para atestar o funcionamento do componente 
-- pontuacao
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pontuacao_tb is
end entity;

architecture arch OF pontuacao_tb is
    component pontuacao is
        generic (
            constant limMax: integer := 100 -- limite para a contagem dos pontos
        );
        port (
            clock   : in  std_logic;
            clr     : in  std_logic;
            enp     : in  std_logic;
            acertou : in  std_logic;
            pontos  : out std_logic_vector (natural(ceil(log2(real(limMax)))) - 1 downto 0)
       );
    end component;

    ---- Declaracao de sinais de entrada para conectar o componente
    signal clk_in : std_logic := '0';
    signal rst_in : std_logic := '0';
    signal enp_in : std_logic := '0';
    signal acertou_in : std_logic := '0';

    ---- Declaracao dos sinais de saida
    signal pontos_out : std_logic_vector(natural(ceil(log2(real(100)))) - 1 downto 0);

    -- Configurações do clock
    signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod : time := 20 ns;     -- frequencia 50MHz

    -- Sinais auxiliares
    signal caso : integer := 0;

begin

    clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;

    dut: pontuacao
    port map (
        clock   => clk_in,
        clr     => rst_in,
        enp     => enp_in,
        acertou => acertou_in,
        pontos  => pontos_out
    );

stimulus: process is
begin

    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    caso <= 1;
    rst_in <= '0';
    wait for 5 ns;
    rst_in <= '1';

    -- clock 1x
    caso <= 2;
    wait for clockPeriod;
    
    -- clock 3x
    caso <= 3;
    enp_in <= '1';
    acertou_in <= '1';
    wait for clockPeriod;
    wait for clockPeriod;
    wait for clockPeriod;

    -- clock 1x
    caso <= 4;
    enp_in <= '1';
    acertou_in <= '0';
    wait for clockPeriod;

    -- clock 1x
    caso <= 5;
    enp_in <= '0';
    acertou_in <= '1';
    wait for clockPeriod;

    -- clock 1x
    caso <= 6;
    enp_in <= '1';
    acertou_in <= '1';
    rst_in <= '0';
    wait for clockPeriod;
    rst_in <= '1';

    -- Caso extra (teste pontuacao maxima)

    -- Zera pontuacao e clock 105x
    caso <= 7;
    rst_in <= '0';
    wait for clockPeriod;
    rst_in <= '1';
    enp_in <= '1';
    acertou_in <= '1';
    wait for 105*clockPeriod;

    -- Zera pontuacao
    caso <= 8;
    rst_in <= '0';
    wait for clockPeriod;
    rst_in <= '1';

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;
end architecture;
