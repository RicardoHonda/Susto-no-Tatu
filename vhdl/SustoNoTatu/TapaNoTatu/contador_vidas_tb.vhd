--------------------------------------------------------------------------
-- Arquivo   : contador_vidas_tb.vhd
-- Projeto   : Tapa no tatu
--                              
--------------------------------------------------------------------------
-- Descricao : testbench para atestar o funcionamento do componente 
--             contador_vidas
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity contador_vidas_tb is
end entity;

architecture arch OF contador_vidas_tb is
  component contador_vidas is
    generic (
        constant nVidas: integer := 3 -- Quantidade de vidas
    );
	
	port (
        clock    : in  std_logic;
        clr      : in  std_logic;
        enp      : in  std_logic;
		acertou  : in  std_logic;
        vidasBin : out std_logic_vector (natural(ceil(log2(real(3)))) - 1 downto 0);
        fimVidas : out std_logic
   );
  end component;

  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in    : std_logic := '0';
  signal clr_in    : std_logic := '0';
  signal enp_in    : std_logic := '0';
  signal acertou_in: std_logic := '0';

  ---- Declaracao dos sinais de saida
  signal vidasBin_out : std_logic_vector (natural(ceil(log2(real(3)))) - 1 downto 0) := "00";
  signal fimVidas_out : std_logic := '0';

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 50MHz

  -- Sinais auxiliares
  signal caso : integer := 0;    -- Caso de teste do cenario

begin

    clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;

    dut: contador_vidas
    port map (
        clock    => clk_in,
        clr      => clr_in,
        enp      => enp_in,
		acertou  => acertou_in,
		vidasBin => vidasBin_out,
        fimVidas => fimVidas_out
    );

stimulus: process is
begin

    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de clear (1 periodo de clock)
    caso <= 1;
    clr_in <= '0';
    wait for clockPeriod;
    clr_in <= '1';

    -- acertou = 1
    caso <= 2;
    enp_in <= '1';
    acertou_in <= '1';
    wait for clockPeriod;
    
    -- erra primeira vez
    caso <= 3;
    acertou_in <= '0';
    wait for clockPeriod;

    -- erra segunda vez
    caso <= 4;
    acertou_in <= '0';
    wait for clockPeriod;

    -- erra terceira vez
    caso <= 5;
    acertou_in <= '0';
    wait for clockPeriod;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;
end architecture;
