library ieee;
use ieee.std_logic_1164.all;

entity medidor_jogada_tb is
end entity;

architecture tb of medidor_jogada_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component medidor_jogada is
    port (
        clock                     : in  std_logic;
        reset                     : in  std_logic;
        inicia                    : in  std_logic;
        fim_de_jogo               : in  std_logic;
        echo1                     : in  std_logic;
        echo2                     : in  std_logic;
        trigger1                  : out std_logic;
        trigger2                  : out std_logic;
        tatus                     : out std_logic_vector(2 downto 0);
        db_estado_hcsr04_1        : out std_logic_vector(3 downto 0);
        db_estado_hcsr04_2        : out std_logic_vector(3 downto 0);
        db_pronto_estado_hcsr04_1 : out std_logic;
        db_pronto_estado_hcsr04_2 : out std_logic;
        db_medida1                : out std_logic_vector(11 downto 0);
        db_medida2                : out std_logic_vector(11 downto 0);
        db_estado                 : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component medidor_jogada;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in                      : std_logic := '0';
  signal reset_in                      : std_logic := '0';
  signal inicia_in                     : std_logic := '0';
  signal fim_de_jogo_in                : std_logic := '0';
  signal echo1_in                      : std_logic := '0';
  signal echo2_in                      : std_logic := '0';
  signal trigger1_out                  : std_logic := '0';
  signal trigger2_out                  : std_logic := '0';
  signal tatus_out                     : std_logic_vector(2 downto 0) := "000";
  signal db_pronto_estado_hcsr04_1_out : std_logic := '0';
  signal db_pronto_estado_hcsr04_2_out : std_logic := '0';
  signal db_estado_hcsr04_1_out        : std_logic_vector (3 downto 0)  := "0000";
  signal db_estado_hcsr04_2_out        : std_logic_vector (3 downto 0)  := "0000";
  signal db_estado_out                 : std_logic_vector (3 downto 0)  := "0000";
  signal db_medida1_out                : std_logic_vector(11 downto 0) := "000000000000";
  signal db_medida2_out                : std_logic_vector(11 downto 0) := "000000000000";

  -- Configurações do clock
  constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
  signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock
  
  -- Array de casos de teste
  type caso_teste_type is record
      id    : natural; 
      tempo : integer;     
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type; -- 5882us (100cm)
  constant casos_teste_1 : casos_teste_array :=
      (
        (1,  472),   -- ( 80mm) tatu 0
        (2,  944),   -- (160mm) tatu 1
        (3, 1416),   -- (240mm) tatu 2
        (4,  236),   -- ( 40mm) sem tatu
        (5,  236),   -- ( 40mm) sem tatu
        (6,  236),   -- ( 40mm) sem tatu
        (7,  472),   -- ( 80mm) tatu 0
        (8,  472),   -- ( 80mm) tatu 0
        (9,  944),   -- (160mm) tatu 1
        (10,  472)   -- ( 80mm) tatu 0
      );

  constant casos_teste_2 : casos_teste_array :=
      (
        (1,  236),   -- ( 40mm) sem tatu
        (2,  236),   -- ( 40mm) sem tatu
        (3,  236),   -- ( 40mm) sem tatu
        (4,  472),   -- ( 80mm) tatu 2
        (5,  944),   -- (160cm) tatu 1
        (6, 1416),   -- (240cm) tatu 0
        (7,  944),   -- (160cm) tatu 1
        (8,  472),   -- ( 80cm) tatu 2
        (9,  472),   -- ( 80cm) tatu 2
        (10,  236)   -- ( 40mm) sem tatu
      );

  signal larguraPulso_min, larguraPulso_max: time := 1 ns;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: medidor_jogada
    port map (
        clock     => clock_in,
        reset     => reset_in,
        inicia    => inicia_in,
        fim_de_jogo => fim_de_jogo_in,
        echo1     => echo1_in,
        echo2     => echo2_in,
        trigger1  => trigger1_out,
        trigger2  => trigger2_out,
        tatus     => tatus_out,
        db_estado_hcsr04_1 => db_estado_hcsr04_1_out,
        db_estado_hcsr04_2 => db_estado_hcsr04_2_out,
        db_pronto_estado_hcsr04_1 => db_pronto_estado_hcsr04_1_out,
        db_pronto_estado_hcsr04_2 => db_pronto_estado_hcsr04_2_out,
        db_medida1 => db_medida1_out,
        db_medida2 => db_medida2_out,
        db_estado => db_estado_out
    );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    echo1_in  <= '0';
    echo2_in  <= '0';
    inicia_in <= '0';

    ---- inicio: reset ----------------
    wait for 2*clockPeriod;
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    wait until falling_edge(clock_in);

    ---- inicio ----------------
    wait for 2*clockPeriod;
    inicia_in <= '1'; 
    wait for 2 us;
    inicia_in <= '0';
    wait until falling_edge(clock_in);

    ---- espera de 100us
    wait for 100 us;

    ---- loop pelos casos de teste
    for i in casos_teste_1'range loop
        -- 1) determina largura do pulso echo
        assert false report "Caso de teste " & integer'image(casos_teste_1(i).id) & ": " &
            integer'image(casos_teste_1(i).tempo) & "us" severity note;
        larguraPulso_min <= casos_teste_1(i).tempo * 1 us;
        larguraPulso_max <= casos_teste_2(i).tempo * 1 us;
     
        -- 3) espera por 400us (tempo entre trigger e echo)
        wait for 100 us;
     
        -- 4.1) gera pulso de echo pro sensor 1 (largura = larguraPulso)
        echo1_in <= '1';
        wait for larguraPulso_min;
        echo1_in <= '0';
        -- wait for larguraPulso_max - larguraPulso_min;

        -- 4.2) gera pulso de echo pro sensor 2 (largura = larguraPulso) 
        -- espera por 400us (tempo entre trigger e echo)
        wait until falling_edge(trigger2_out);
        wait for 100 us;


        echo2_in <= '1';
        wait for larguraPulso_max;
        echo2_in <= '0';

        -- 5) espera final da medida
      	wait for 10 us;
        assert false report "Fim do caso " & integer'image(casos_teste_1(i).id) severity note;
     
        -- 6) espera entre casos de tese
        wait for 100 us;

    end loop;

    ---- fim de jogo ----------------
    wait for 2*clockPeriod;
    fim_de_jogo_in <= '1'; 
    wait for 2 us;
    fim_de_jogo_in <= '0';
    wait until falling_edge(clock_in);

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
