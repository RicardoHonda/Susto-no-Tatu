--------------------------------------------------------------------------
-- Arquivo   : contador_decrescente_tb.vhd
-- Projeto   : Tapa no tatu
--                              
--------------------------------------------------------------------------
-- Descricao : testbench para atestar o funcionamento do componente 
--             contador_decrescente
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity contador_decrescente_tb is
end entity;

architecture arch OF contador_decrescente_tb is
  component contador_decrescente is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        conta       : in  std_logic;
		    limite      : in  integer;
		    timeout     : out std_logic;
        db_contagem : out integer
    );
  end component;

  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in    : std_logic := '0';
  signal rst_in    : std_logic := '0';
  signal conta_in  : std_logic := '0';
  signal limite_in : integer   := 2;

  ---- Declaracao dos sinais de saida
  signal timeout_out     : std_logic := '0';
  signal db_contagem_out : integer := 0;

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 50MHz

  -- Sinais auxiliares
  signal caso : integer := 0;    -- Caso de teste do cenario

begin

    clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;

    dut: contador_decrescente
    port map (
        clock       => clk_in,
        reset       => rst_in,
        conta       => conta_in,
		limite      => limite_in,
		timeout     => timeout_out,
        db_contagem => db_contagem_out
    );

stimulus: process is
begin

    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    caso <= 1;
    rst_in <= '1';
    wait for 5 ns;
    rst_in <= '0';

    -- muda limite para 4
    caso <= 2;
    limite_in <= 4;
    wait for 5 ns;
    
    -- Conta 3x
    caso <= 3;
    conta_in <= '1';
    wait for 3*clockPeriod;

    -- Para de contar
    caso <= 4;
    conta_in <= '0';
    wait for clockPeriod;

    -- Conta 1x
    caso <= 5;
    conta_in <= '1';
    wait for clockPeriod;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;
end architecture;
