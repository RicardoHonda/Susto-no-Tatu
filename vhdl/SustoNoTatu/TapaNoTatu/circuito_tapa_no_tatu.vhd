------------------------------------------------------------------
-- Arquivo   : circuito_tapa_no_tatu.vhd
-- Projeto   : Tapa no Tatu
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2022  1.0     Henrique Matheus  versao inicial
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity circuito_tapa_no_tatu is
    port (
    clock       : in std_logic;
    reset       : in std_logic;
    iniciar     : in std_logic;
    botoes      : in std_logic_vector(5 downto 0);
    dificuldade : in std_logic;
    leds        : out std_logic_vector(5 downto 0);
    fimDeJogo   : out std_logic;
    vidas       : out std_logic_vector (1 downto 0);
    display1    : out std_logic_vector (6 downto 0);
    display2    : out std_logic_vector (6 downto 0);
    serial      : out std_logic;
	hex_pontuacao0 : out std_logic_vector (3 downto 0);
	hex_pontuacao1 : out std_logic_vector (3 downto 0);
    -- Sinais de depuração
    db_estado       : out std_logic_vector (4 downto 0);
    db_jogadaFeita  : out std_logic;
    db_jogadaValida : out std_logic;
    db_timeout      : out std_logic;
	db_ini          : out std_logic
    );
end entity;

architecture estrutural of circuito_tapa_no_tatu is
    signal s_registraM, s_limpaM, s_registraR, s_limpaR   : std_logic;
    signal s_jogada_valida, s_tem_tatu, s_en_FLSR         : std_logic;
    signal s_conta_jog_TMR, s_timeout_TMR,
           s_zeraJogTMR, s_zeraVida, s_apagaTatu          : std_logic;
    signal s_limite_TMR, s_contagem                       : integer;
    signal s_contaDelTMR, s_timeout_Del_TMR, s_zeraDelTMR : std_logic;
    signal s_fim_vidas, s_not_fim_vidas, s_anulaTatus     : std_logic;
    signal s_conta_vida                                   : std_logic;
    signal s_vidas                                        : std_logic_vector(1 downto 0);
    signal s_conta_ponto                                  : std_logic;
    signal s_pontos                                       : std_logic_vector(6 downto 0);
    signal s_estado                                       : std_logic_vector(4 downto 0);
    signal s_fimJogo, s_tem_jogada, s_escolheuDificuldade : std_logic;
    signal s_loadSub, s_contaSub                          : std_logic;
    signal s_hexa1, s_hexa2                               : std_logic_vector(3 downto 0);
    signal s_emJogo                                       : std_logic;
    signal s_tatus                                        : std_logic_vector(5 downto 0);
    signal s_enReg, s_end_ponts                           : std_logic;
    signal s_dado_tatus, s_dado_tatus2                    : std_logic_vector(6 downto 0);
    signal s_whichTX                                      : std_logic; -- Tatus (1), Pontos (0)
    signal s_prontoTX, s_enTX, s_serial                   : std_logic;
    signal s_dado_tx                                      : std_logic_vector(7 downto 0);
	signal s_contaSprTMR, s_zeraSprTMR,
           s_fimSprTMR, s_limpa_pontos                    : std_logic;

    -- Fluxo de dados
    component fluxo_dados is
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
          pontos        : out std_logic_vector (6 downto 0);
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
      end component fluxo_dados;

    -- Unidade de controle
    component unidade_controle is 
    port ( 
        clock               : in  std_logic; 
        reset               : in  std_logic; 
        iniciar             : in  std_logic;
        EscolheuDificuldade : in  std_logic;
        timeout             : in  std_logic;
        fezJogada           : in  std_logic;
        temVida             : in  std_logic;
		zeraVida            : out std_logic;
        jogadaValida        : in  std_logic;
        temTatu             : in  std_logic;
        timeOutDelTMR       : in  std_logic;
        end_points          : in  std_logic;
        prontoTX            : in  std_logic;
        fimJogo             : out std_logic; 
        registraR           : out std_logic; 
        limpaR              : out std_logic; 
        registraM           : out std_logic; 
        limpaM              : out std_logic; 
        zeraJogTMR          : out std_logic; 
        contaJogTMR         : out std_logic;
        zeraDelTMR          : out std_logic;
        contaDelTMR         : out std_logic;
        loadSub             : out std_logic;
        contaSub            : out std_logic;
        en_FLSR             : out std_logic; 
        emJogo              : out std_logic;
        contaPonto          : out std_logic;
        contaVida           : out std_logic;
        db_estado           : out std_logic_vector(4 downto 0);
        en_Reg              : out std_logic;
        enTX                : out std_logic;
		anulaTatus          : out std_logic;
		whichTX             : out std_logic;
		apagaTatu           : out std_logic;
	    -- TMR Sperano
		contaSprTMR         : out std_logic;
		zeraSprTMR          : out std_logic;
		fimSprTMR           : in std_logic;
		limpa_pontos        : out std_logic
    );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos
    component hexa7seg is
        port (
            hexa   : in  std_logic_vector(3 downto 0);
            enable : in std_logic;
            sseg   : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos para os estados
    component estado7seg is
        port (
            estado : in  std_logic_vector(4 downto 0);
            sseg   : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Mux 2x1 para escolha (pontuacao, tatus)
    component mux2x1_n is
        generic (
            constant bits: integer := 7
        );
        port(
            D0      : in  std_logic_vector (bits-1 downto 0);
            D1      : in  std_logic_vector (bits-1 downto 0);
            SEL     : in  std_logic; -- Tatus (1), Pontacao (0)
            MUX_OUT : out std_logic_vector (bits downto 0)
        );
    end component;

    -- Saida serial
    component tx is
        generic (baudrate : integer := 9600);
        port (
            clock    : in  std_logic;							
            reset	 : in  std_logic;							
            partida  : in  std_logic;							
            dado	 : in  std_logic_vector(7 downto 0);	
            sout	 : out std_logic;							
            out_dado : out std_logic_vector(7 downto 0);	
            pronto   : out std_logic							
        );
    end component;

begin
    fd: fluxo_dados
    port map (
        clock         => clock,
		anulaTatus    => s_anulaTatus,
        -- Registrador 6 bits
        registraM     => s_registraM,
        limpaM        => s_limpaM,
        registraR     => s_registraR,
        limpaR        => s_limpaR,
        jogada        => botoes,
        en_reg        => s_enReg,
        -- Comparador 6 bits
        jogada_valida => s_jogada_valida,
        -- Subtrator 6 bits
        tem_tatu      => s_tem_tatu,
        tatus         => s_tatus,
        -- Contador decrescente
        conta_jog_TMR => s_conta_jog_TMR,
        timeout_TMR   => s_timeout_TMR,
        db_contagem   => s_contagem,
        -- Contador de vidas
        zera_vida     => s_zeraVida,
        conta_vida    => s_conta_vida,
        vidas         => s_vidas,
        fim_vidas     => s_fim_vidas,
        -- Pontuacao
        zera_ponto    => s_limpa_pontos,
        conta_ponto   => s_conta_ponto,
        pontos        => s_pontos,
        end_ponts     => s_end_ponts,
        -- LFSR6
        zera_LFSR6    => reset,
        en_LFSR       => s_en_FLSR,
        -- Edge detector
        tem_jogada    => s_tem_jogada,
        dificuldade   => dificuldade,
        -- TMR apagado
        contaDelTMR   => s_contaDelTMR,
        zeraDelTMR    => s_zeraDelTMR,
        fimDelTMR     => s_timeout_Del_TMR,
        -- Subtrator
        loadSub       => s_loadSub,
        contaSub      => s_contaSub,
		-- TMR Sperano
		contaSprTMR   => s_contaSprTMR,
		zeraSprTMR    => s_zeraSprTMR,
		fimSprTMR     => s_fimSprTMR
    );

    uc: unidade_controle
    port map (
        clock                => clock,
        reset                => reset, 
        iniciar              => iniciar,
        EscolheuDificuldade  => iniciar,
        timeout              => s_timeout_TMR,
        fezJogada            => s_tem_jogada,
        temVida              => s_not_fim_vidas,
		zeraVida             => s_zeraVida,
        jogadaValida         => s_jogada_valida,
        temTatu              => s_tem_tatu,
        timeOutDelTMR        => s_timeout_Del_TMR,
        end_points           => s_end_ponts,
        prontoTX             => s_prontoTX,
        fimJogo              => s_fimJogo,
        registraR            => s_registraR,
        limpaR               => s_limpaR,
        registraM            => s_registraM,
        limpaM               => s_limpaM,
        zeraJogTMR           => s_zeraJogTMR,
        contaJogTMR          => s_conta_jog_TMR,
        zeraDelTMR           => s_zeraDelTMR,
        contaDelTMR          => s_contaDelTMR,
        loadSub              => s_loadSub,
        contaSub             => s_contaSub,
        en_FLSR              => s_en_FLSR,
        emJogo               => s_emJogo,
        contaPonto           => s_conta_ponto,
        contaVida            => s_conta_vida,
        db_estado            => db_estado,
        en_Reg               => s_enReg,
        enTX                 => s_enTX,
		anulaTatus           => s_anulaTatus,
        whichTX              => s_whichTX,
		apagaTatu            => s_apagaTatu,
		-- TMR Sperano
        contaSprTMR          => s_contaSprTMR,
        zeraSprTMR           => s_zeraSprTMR,
        fimSprTMR            => s_fimSprTMR,
        limpa_pontos         => s_limpa_pontos
    );
	 
	process(s_vidas, s_emJogo, s_pontos) 
	begin
        if s_emJogo='1' then
            s_hexa1 <= "00" & s_vidas;
            s_hexa2 <= "0000";
        else
            s_hexa1 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_pontos)) rem 10, 4));
            s_hexa2 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_pontos)) / 10, 4));
        end if;
		  
		  hex_pontuacao0 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_pontos)) rem 10, 4));
		  hex_pontuacao1 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_pontos)) / 10, 4));
	end process;
	 
    process(s_apagaTatu, s_dado_tatus) 
	begin
		if s_apagaTatu='1' then
			s_dado_tatus2 <= "0000000";
		else
			s_dado_tatus2 <= s_dado_tatus;
		end if;
	end process;

	
    mux2_1: mux2x1_n 
        port map(
            D0      => s_pontos,
            D1      => s_dado_tatus,
            SEL     => s_whichTX,
            MUX_OUT => s_dado_tx
        );

    tx_serial : tx
        port map(
            clock		 => clock,				
            reset		 => reset,						
            partida      => s_enTX,						
            dado		 => s_dado_tx,
            sout		 => s_serial,							
            out_dado	 => Open,	
            pronto	     => s_prontoTX					
        );

    displayOne: hexa7seg
        port map(
            hexa   => s_hexa1,
            enable => '1',
            sseg   => display1
        );

    displayTwo: hexa7seg
        port map(
            hexa   => s_hexa2,
            enable => s_fimJogo,
            sseg   => display2
        );

    -- estado7s: estado7seg
    --     port map(
    --         estado => s_estado,
    --         sseg   => db_estado
    --     );

    -- Sinais auxiliares
    s_not_fim_vidas <= not s_fim_vidas;
    s_dado_tatus    <= '0' & s_tatus;

    -- Saídas
    leds        <= s_tatus;
    fimDeJogo   <= s_fimJogo;
    vidas       <= s_vidas;
	serial      <= s_serial;
    
    -- Saídas (depuração)
    db_jogadaFeita  <= s_tem_jogada;
    db_jogadaValida <= s_jogada_valida;
    db_timeout      <= s_timeout_TMR;
	db_ini          <= s_apagaTatu;
end architecture;
   
