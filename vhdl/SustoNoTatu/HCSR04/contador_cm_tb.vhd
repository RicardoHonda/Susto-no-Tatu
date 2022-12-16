--------------------------------------------------------------------
-- Arquivo   : contador_cm_tb.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : testbench para circuito de conversao de
--             largura de pulso para centimetros 
--
--             1) array de casos de teste contém valores de  
--                largura de pulso de echo do sensor
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2022  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity contador_cm_tb is
end entity;

architecture tb of contador_cm_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component contador_cm is
    generic (
        constant R : integer;
        constant N : integer
    );
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        pulso     : in  std_logic;
        digito0   : out std_logic_vector(3 downto 0);
        digito1   : out std_logic_vector(3 downto 0);
        digito2   : out std_logic_vector(3 downto 0);
        fim       : out std_logic;
        pronto    : out std_logic;
        db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in      : std_logic := '0';
  signal reset_in      : std_logic := '0';
  signal pulso_in      : std_logic := '0';
  signal digito0_out   : std_logic_vector (3 downto 0) := "0000";
  signal digito1_out   : std_logic_vector (3 downto 0) := "0000";
  signal digito2_out   : std_logic_vector (3 downto 0) := "0000";
  signal fim_out       : std_logic := '0';
  signal pronto_out    : std_logic := '0';
  signal db_estado_out : std_logic_vector (3 downto 0) := "0000";

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod:   time := 20 ns;    -- clock de 50MHz
  
  -- Array de casos de teste
  type caso_teste_type is record
      id    : integer; 
      tempo : integer;     
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        (1, 5882),  -- 5882us (100cm)
        (2, 4353),  -- 4353us (74cm)
        (3, 5899),  -- 5899us (100,29cm) truncar para 100cm 
        (4, 4399),  -- 4399us (74,79cm)  arredondar para 75cm
        -- inserir aqui outros casos de teste
        (5, 4381),  -- 4381us (74,48cm)  truncar para 74cm
        (6, 58789), -- 58789us (999,47cm) truncar para 999cm
        (7, 59000)  -- 59000us (1003,06cm) Valor acima do permitido (10,03m > 10m). Truncar para 999cm e ativar sinal de 'fim' no contador
      );
  signal caso  : integer := 0;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: contador_cm
       generic map ( R=>2941, N=>12 ) 
       port map (
           clock   => clock_in,
           reset   => reset_in,
           pulso   => pulso_in,   
           digito0 => digito0_out,
           digito1 => digito1_out,
           digito2 => digito2_out,
           fim     => fim_out,
           pronto  => pronto_out,
           db_estado => db_estado_out
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
      variable larguraPulso: time := 1 ns;
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    reset_in <= '0';
    pulso_in <= '0';
    caso     <= 0;

    ---- inicio: reset ----------------
    wait for 2*clockPeriod;
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    wait until falling_edge(clock_in);

    ---- espera de 100us
    wait for 100 us;

    ---- loop pelos casos de teste
    for i in casos_teste'range loop

        -- 1) determina largura do pulso echo
        assert false report "Caso de teste " & integer'image(casos_teste(i).id) & ": " &
            integer'image(casos_teste(i).tempo) & " us" severity note;
        larguraPulso := casos_teste(i).tempo * 1 us; -- caso de teste "i"
        caso <= casos_teste(i).id;

        -- 2) gera pulso de echo (largura = larguraPulso)
        pulso_in <= '1';
        wait for larguraPulso;
        pulso_in <= '0';

        -- 3) final do caso de teste
        assert false report "Fim do caso " & integer'image(casos_teste(i).id) severity note;
     
        -- 4) espera entre casos de tese
        wait for 100 us;

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
