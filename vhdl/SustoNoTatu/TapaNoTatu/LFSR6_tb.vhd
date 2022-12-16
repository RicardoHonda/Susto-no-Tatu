--------------------------------------------------------------------------
-- Arquivo   : LSFR6_tb.vhd
-- Projeto   : Tapa no tatu
--                              
--------------------------------------------------------------------------
-- Descricao : testbench para atestar o funcionamento do componente LFSR6
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity LSFR6_tb is
end entity;

architecture arch OF LSFR6_tb is
  component LFSR6 is
    port (
        clk    : in  std_logic; 
        rst    : in  std_logic;
        output : out std_logic_vector (5 downto 0)
    );
  end component;

  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in : std_logic := '0';
  signal rst_in : std_logic := '0';

  ---- Declaracao dos sinais de saida
  signal output_out : std_logic_vector(5 downto 0) := "000000";

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 50MHz

  -- Sinais auxiliares
  signal caso : integer := 0;    -- Caso de teste do cenario

begin

    clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;

    dut: LFSR6
    port map (
        clk    => clk_in, 
        rst    => rst_in, 
        output => output_out
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

    -- clock 1x
    caso <= 2;
    wait for clockPeriod;
    
    -- clock 1x
    caso <= 3;
    wait for clockPeriod;

    -- clock 1x
    caso <= 4;
    wait for clockPeriod;

    -- clock 1x
    caso <= 5;
    wait for clockPeriod;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;
end architecture;
