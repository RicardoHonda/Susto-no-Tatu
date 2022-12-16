------------------------------------------------------------------
-- Arquivo   : fluxo_dados.vhd
-- Projeto   : Tapa no tatu
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
  port (
    clock         : in  std_logic;
	  anulaTatus    : in  std_logic;
    -- Registrador 6 bits
    registraM     : in  std_logic;
    limpaM        : in  std_logic;
    registraR     : in  std_logic;
    limpaR        : in  std_logic;
    jogada        : in  std_logic_vector(5 downto 0);
	  en_reg        : in  std_logic;
    -- Comparador 6 bits
    jogada_valida : out std_logic;
    -- Subtrator 6 bits
    tem_tatu      : out std_logic;
    tatus         : out std_logic_vector(5 downto 0);
    -- Contador decrescente
    conta_jog_TMR : in  std_logic;
    timeout_TMR   : out std_logic;
    db_contagem   : out integer;
    -- Contador de vidas
    zera_vida     : in  std_logic;
    conta_vida    : in  std_logic;
    vidas         : out std_logic_vector(1 downto 0);
    fim_vidas     : out std_logic;
    -- Pontuacao
    zera_ponto    : in  std_logic;
    conta_ponto   : in  std_logic;
    pontos        : out std_logic_vector (natural(ceil(log2(real(100)))) - 1 downto 0);
	  end_ponts     : out std_logic;
    -- LFSR6
    zera_LFSR6    : in  std_logic;
    en_LFSR       : in  std_logic;
    -- Edge detector
    tem_jogada    : out std_logic;
    dificuldade   : in std_logic;
    -- TMR apagado
    contaDelTMR   : in std_logic;
    zeraDelTMR    : in std_logic;
    fimDelTMR     : out std_logic;
    -- Subtrator
    loadSub       : in std_logic;
    contaSub      : in std_logic;
	 -- TMR Sperano
    contaSprTMR   : in std_logic;
    zeraSprTMR    : in std_logic;
    fimSprTMR     : out std_logic
  );
end entity fluxo_dados;
 
architecture estrutural of fluxo_dados is
  ----------------------------------
  -- Declaracao dos sinais usados --
  ----------------------------------
  signal s_jogadaR, s_jogada  : std_logic_vector(5 downto 0);
  signal s_tatusR, s_tatus    : std_logic_vector(5 downto 0);

  signal s_not_registraM  : std_logic;
  signal s_not_registraR  : std_logic;
  signal s_not_zera_vida  : std_logic;
  signal s_not_zera_ponto : std_logic;

  signal s_jogada_valida : std_logic;
  signal s_tem_tatu      : std_logic;
  signal s_not_tem_tatu  : std_logic;

  signal s_temJogada, s_escolheuDificuldade : std_logic;
  signal s_limite_TMR, s_load_sub: integer;
  ---------------------------------------
  -- Declaracao dos componentes usados --
  ---------------------------------------
  -- Comparador de 6 bits
  component	comparador_6_bits is
    port (
      i_A5    : in  std_logic;
      i_B5    : in  std_logic;
      i_A4    : in  std_logic;
      i_B4    : in  std_logic;
      i_A3    : in  std_logic;
      i_B3    : in  std_logic;
      i_A2    : in  std_logic;
      i_B2    : in  std_logic;
      i_A1    : in  std_logic;
      i_B1    : in  std_logic;
      i_A0    : in  std_logic;
      i_B0    : in  std_logic;
      o_ASEQB : out std_logic -- A "semiequal" B, indicando que Ai == Bi == 1, para algum i
    );
  end component;

  -- Subtrator 6 bits
  component subtrator_6_bits is
    port (
      i_A          : in  std_logic_vector(5 downto 0);
      i_B          : in  std_logic_vector(5 downto 0);
      resultado    : out std_logic_vector(5 downto 0);
      tem_toupeira : out std_logic
    );
  end component;

  -- Registrador 6 bits (para jogada)
  component registrador_173 is
    port (
        clock : in  std_logic;
        clear : in  std_logic; -- Ativo ALTO
        en1   : in  std_logic; -- Ativo BAIXO
        en2   : in  std_logic;
        D     : in  std_logic_vector (5 downto 0);
        Q     : out std_logic_vector (5 downto 0)
    );
  end component;
  
  -- Registrador modificado (para os tatus)
  component regis2 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D1    : in  std_logic_vector (5 downto 0);
		    D2    : in  std_logic_vector (5 downto 0);
        Q     : out std_logic_vector (5 downto 0)
   );
end component;

  -- Contador decrescente
  component contador_decrescente is
    port (
      clock       : in  std_logic;
      reset       : in  std_logic; -- Ativo ALTO
      conta       : in  std_logic; -- Ativo ALTO
      limite      : in  integer;
      timeout     : out std_logic;
      db_contagem : out integer
    );
  end component;

  -- Contador de vidas
  component contador_vidas is
    generic (
      constant nVidas: integer := 3 -- Número de vidas
    );
    port (
      clock    : in  std_logic;
      clr      : in  std_logic; -- Ativo BAIXO
      enp      : in  std_logic;
      acertou  : in  std_logic;
      vidasBin : out std_logic_vector (natural(ceil(log2(real(nVidas)))) - 1 downto 0);
      fimVidas : out std_logic
    );
  end component;

  -- Pontuacao
  component pontuacao is
    generic (
      constant limMax: integer := 100 -- Limite da pontuação
    );
    port (
      clock     : in  std_logic;
      clr       : in  std_logic; -- Ativo BAIXO
      enp       : in  std_logic;
      acertou   : in  std_logic;
      pontos    : out std_logic_vector (natural(ceil(log2(real(limMax)))) - 1 downto 0);
		  end_ponts : out std_logic
    );
  end component;

  -- Gerador de jogadas aleatorias
  component LFSR6 is
    port (
        clk   : in  std_logic; 
        rst   : in  std_logic; -- Ativo ALTO
        en    : in  std_logic;
        output: out std_logic_vector (5 downto 0)
    );
  end component;

  component edge_detector is
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
  end component;

  component contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic
    );
end component contador_m;

  component subtrador_m is
    port (
        clock      : in  std_logic;
        load       : in  std_logic;
        load_value : in integer;
        conta      : in  std_logic;
        Q          : out integer;
        fim        : out std_logic
    );
  end component subtrador_m;

begin
  -- Sinais ativos baixo
  s_not_registraM  <= not registraM;
  s_not_registraR  <= not registraR;
  s_not_zera_vida  <= not zera_vida;
  s_not_zera_ponto <= not zera_ponto;

  s_temJogada <= jogada(0) or jogada(1) or jogada(2) or jogada(3) or jogada(4) or jogada(5);
  ---------------------------------------
  -- Instancias dos componentes usados --
  ---------------------------------------
  geradorJogadas: LFSR6
  port map (
    clk    => clock,
    rst    => '0', --zera_LFSR6,
    en     => en_LFSR,
    output => s_jogada
  );

  registraTatus: regis2
  port map (
    clock => clock,
    clear => limpaM or anulaTatus,
    en1   => s_not_registraM,
    en2   => en_reg,
    D1    => s_jogada,
	  D2    => s_tatus,
    Q     => s_tatusR
  );

  registraJogada: registrador_173
  port map (
    clock => clock,
    clear => limpaR,
    en1   => s_not_registraR,
    en2   => '0',
    D     => jogada, 
    Q     => s_jogadaR
  );

  comparaTatusJogada: comparador_6_bits
  port map (
    i_A5    => s_tatusR(5),
    i_B5    => s_jogadaR(5),
    i_A4    => s_tatusR(4),
    i_B4    => s_jogadaR(4),
    i_A3    => s_tatusR(3),
    i_B3    => s_jogadaR(3),
    i_A2    => s_tatusR(2),
    i_B2    => s_jogadaR(2),
    i_A1    => s_tatusR(1),
    i_B1    => s_jogadaR(1),
    i_A0    => s_tatusR(0),
    i_B0    => s_jogadaR(0),
    o_ASEQB => s_jogada_valida
  );

  conta_vidas: contador_vidas
  port map (
    clock    => clock,
    clr      => s_not_zera_vida,
    enp      => conta_vida,
    acertou  => s_jogada_valida,
    vidasBin => vidas,
    fimVidas => fim_vidas
  );

  conta_pontos: pontuacao
  port map (
    clock     => clock,
    clr       => s_not_zera_ponto,
    enp       => '1',
    acertou   => conta_ponto,
    pontos    => pontos,
	  end_ponts => end_ponts
  );

  remove_tatu: subtrator_6_bits
  port map (
    i_A          => s_tatusR,
    i_B          => s_jogadaR,
    resultado    => s_tatus,
    tem_toupeira => s_tem_tatu
  );

  reduzTempo: contador_decrescente
  port map (
    clock       => clock,
    reset       => s_not_tem_tatu,
    conta       => conta_jog_TMR,
    limite      => s_limite_TMR,
    timeout     => timeout_TMR,
    db_contagem => db_contagem
  );

  jogadaEdgeDetector: edge_detector 
    port map (  
        clock     => clock,
        signal_in => s_temJogada,
        output    => tem_jogada
    );

  DelTMR: contador_m 
    generic map (
        M => 100000000, 
        N => 27
    )
    port map (
        clock => clock,
        zera  => zeraDelTMR,
        conta => contaDelTMR,
        Q     => open,
        fim   => fimDelTMR
    );
	 
  SperanoTMR: contador_m 
    generic map (
        M => (50000000/(9600)) * 10, 
        N => 16
    )
    port map (
        clock => clock,
        zera  => zeraSprTMR,
        conta => contaSprTMR,
        Q     => open,
        fim   => fimSprTMR
    );

  sub: subtrador_m
    port map(
        clock      => clock,
        load       => loadSub,
        load_value => s_load_sub,
        conta      => contaSub,
        Q          => s_limite_TMR,
        fim        => open
    );

  s_load_sub <= 1000000000 when dificuldade='1' else  -- antes 2500000000
                1500000000; -- Default e dificuldade facil (01)

  s_not_tem_tatu <= not s_tem_tatu;

  -- Sinais de saida
  jogada_valida <= s_jogada_valida;
  tem_tatu <= s_tem_tatu;
  tatus <= s_tatusR;
end estrutural;
