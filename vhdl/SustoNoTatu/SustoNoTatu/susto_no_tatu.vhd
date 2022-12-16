library IEEE;
use IEEE.std_logic_1164.all;

entity susto_no_tatu is
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        iniciar       : in  std_logic;
		  iniciar_mqtt  : in std_logic; 
        echo_01       : in  std_logic;
        echo_02       : in  std_logic;
        echo_11       : in  std_logic;
        echo_12       : in  std_logic;
        dificuldade   : in  std_logic;
		dificuldade_mqtt   : in  std_logic;
        botoes_mqtt        : in  std_logic_vector(5 downto 0);
        debug_seletor : in  std_logic_vector(2 downto 0);
		  init_fpga:    out std_logic;
		reset_mqtt    : out std_logic;
        trigger_01    : out std_logic;
        trigger_02    : out std_logic;
        trigger_11    : out std_logic;
        trigger_12    : out std_logic;
        pwm_tatu_00   : out std_logic;
        pwm_tatu_01   : out std_logic;
        pwm_tatu_02   : out std_logic;
        pwm_tatu_10   : out std_logic;
        pwm_tatu_11   : out std_logic;
        pwm_tatu_12   : out std_logic;
        serial        : out std_logic;
        vidas         : out std_logic_vector (1 downto 0);
		  vidas_hex     : out std_logic_vector (6 downto 0); -- Ativo baixo
        pontuacao0    : out std_logic_vector (6 downto 0); -- Ativo alto
        pontuacao1    : out std_logic_vector (6 downto 0); -- Ativo baixo
        db_display0   : out std_logic_vector (6 downto 0);
        db_display1   : out std_logic_vector (6 downto 0);
        db_display2   : out std_logic_vector (6 downto 0);
        db_display3   : out std_logic_vector (6 downto 0);
        db_display4   : out std_logic_vector (6 downto 0);
        db_display5   : out std_logic_vector (6 downto 0);
        db_tatus      : out std_logic_vector(5 downto 0);
        db_led8       : out std_logic;
        db_led9       : out std_logic;
		fim_de_jogo   : out std_logic;
		fim_de_jogo_mqtt: out std_logic
    );
end entity susto_no_tatu;

architecture rtl of susto_no_tatu is

    component circuito_tapa_no_tatu is
        port (
            clock           : in  std_logic;
            reset           : in  std_logic;
            iniciar         : in  std_logic;
            botoes          : in  std_logic_vector(5 downto 0);
            dificuldade     : in  std_logic;
            leds            : out std_logic_vector(5 downto 0);
            fimDeJogo       : out std_logic;
            vidas           : out std_logic_vector (1 downto 0);
            display1        : out std_logic_vector (6 downto 0);
            display2        : out std_logic_vector (6 downto 0);
            serial          : out std_logic;
			hex_pontuacao0  : out std_logic_vector (3 downto 0);
			hex_pontuacao1  : out std_logic_vector (3 downto 0);
            -- Sinais de depuração
            db_estado       : out std_logic_vector (4 downto 0);
            db_jogadaFeita  : out std_logic;
            db_jogadaValida : out std_logic;
            db_timeout      : out std_logic;
            db_ini          : out std_logic
        );
    end component;

    component servo_tatu is
        port (
            clock : in  std_logic;
            reset : in  std_logic;
            tatus : in  std_logic_vector(2 downto 0);
            pwm0  : out std_logic;
            pwm1  : out std_logic;
            pwm2  : out std_logic
        );
    end component servo_tatu;

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

    component mux_8x1_n is
        generic (
            constant BITS: integer := 4
        );
        port ( 
            D0      : in  std_logic_vector (BITS-1 downto 0);
            D1      : in  std_logic_vector (BITS-1 downto 0);
            D2      : in  std_logic_vector (BITS-1 downto 0);
            D3      : in  std_logic_vector (BITS-1 downto 0);
            D4      : in  std_logic_vector (BITS-1 downto 0);
            D5      : in  std_logic_vector (BITS-1 downto 0);
            D6      : in  std_logic_vector (BITS-1 downto 0);
            D7      : in  std_logic_vector (BITS-1 downto 0);
            SEL     : in  std_logic_vector (2 downto 0);
            MUX_OUT : out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    component mux_8x1 is
        port ( 
            D0      : in  std_logic;
            D1      : in  std_logic;
            D2      : in  std_logic;
            D3      : in  std_logic;
            D4      : in  std_logic;
            D5      : in  std_logic;
            D6      : in  std_logic;
            D7      : in  std_logic;
            SEL     : in  std_logic_vector (2 downto 0);
            MUX_OUT : out std_logic
        );
    end component;

    signal s_fim_de_jogo                                              : std_logic;
    signal s_tatus                                                    : std_logic_vector(5 downto 0);
    signal s_tatus_aux0, s_tatus_aux1                                 : std_logic_vector(2 downto 0);
    signal s_tatus_selecionados, s_botoes_selecionados                : std_logic_vector(5 downto 0);
    signal s_db_medida01, s_db_medida02, s_db_medida11, s_db_medida12 : std_logic_vector(11 downto 0);
    signal s_db_mux0, s_db_mux1, s_db_mux2,
           s_db_mux3, s_db_mux4, s_db_mux5                            : std_logic_vector(3 downto 0);
    signal s_db_estado_hcsr04_01, s_db_estado_hcsr04_02,
           s_db_estado_hcsr04_11, s_db_estado_hcsr04_12               : std_logic_vector(3 downto 0);
    signal s_db_estado_medidor_jogada_0, s_db_estado_medidor_jogada_1 : std_logic_vector(3 downto 0);
    signal s_db_pronto_estado_hcsr04_01, s_db_pronto_estado_hcsr04_02,
           s_db_pronto_estado_hcsr04_11, s_db_pronto_estado_hcsr04_12 : std_logic;
    signal s_db_estado_tapa_no_tatu                                   : std_logic_vector(4 downto 0);
	signal s_pontuacao0                                               : std_logic_vector(6 downto 0);
	signal s_hex_pontuacao0, s_hex_pontuacao1                         : std_logic_vector(3 downto 0);
    signal s_vidas                                                    : std_logic_vector(1 downto 0);
	
	 -- sinais mqtt
	 signal s_iniciar, s_reset: std_logic;
	 
begin

    TAPA_NO_TATU: circuito_tapa_no_tatu
        port map (
        clock           => clock,
        reset           => reset,
        iniciar         => s_iniciar,
        botoes          => s_botoes_selecionados,
        dificuldade     => dificuldade or dificuldade_mqtt,
        leds            => s_tatus,
        fimDeJogo       => s_fim_de_jogo,
        vidas           => s_vidas,
        display1        => open,
        display2        => open,
        serial          => serial,
		hex_pontuacao0  => s_hex_pontuacao0,
		hex_pontuacao1  => s_hex_pontuacao1,
        -- Sinais de depuração
        db_estado       => s_db_estado_tapa_no_tatu,
        db_jogadaFeita  => open,
        db_jogadaValida => open,
        db_timeout      => open,
        db_ini          => open
        );

	s_tatus_aux0 <= s_tatus(2 downto 0) when s_fim_de_jogo = '0' else "000";
	s_tatus_aux1 <= s_tatus(5 downto 3) when s_fim_de_jogo = '0' else "000";
		  
    SERVO_TATU_0: servo_tatu
        port map (
            clock => clock,
            reset => reset,
            tatus => s_tatus_aux0, -- s_tatus_selecionados
            pwm0  => pwm_tatu_00,
            pwm1  => pwm_tatu_01,
            pwm2  => pwm_tatu_02
        );

    SERVO_TATU_1: servo_tatu
        port map (
            clock => clock,
            reset => reset,
            tatus => s_tatus_aux1, -- s_tatus_selecionados
            pwm0  => pwm_tatu_10,
            pwm1  => pwm_tatu_11,
            pwm2  => pwm_tatu_12
        );

    MEDIDOR_JOGADA_0: medidor_jogada
        port map (
            clock                     => clock,
            reset                     => reset,
            inicia                    => s_iniciar,
            fim_de_jogo               => s_fim_de_jogo,
            echo1                     => echo_01,
            echo2                     => echo_02,
            trigger1                  => trigger_01,
            trigger2                  => trigger_02,
            tatus                     => s_tatus_selecionados(2 downto 0),
            db_estado_hcsr04_1        => s_db_estado_hcsr04_01,
            db_estado_hcsr04_2        => s_db_estado_hcsr04_02,
            db_pronto_estado_hcsr04_1 => s_db_pronto_estado_hcsr04_01,
            db_pronto_estado_hcsr04_2 => s_db_pronto_estado_hcsr04_02,
            db_medida1                => s_db_medida01,
            db_medida2                => s_db_medida02,
            db_estado                 => s_db_estado_medidor_jogada_0 -- estado da UC
        );

    MEDIDOR_JOGADA_1: medidor_jogada
        port map (
            clock                     => clock,
            reset                     => reset,
            inicia                    => s_iniciar,
            fim_de_jogo               => s_fim_de_jogo,
            echo1                     => echo_11,
            echo2                     => echo_12,
            trigger1                  => trigger_11,
            trigger2                  => trigger_12,
            tatus                     => s_tatus_selecionados(5 downto 3),
            db_estado_hcsr04_1        => s_db_estado_hcsr04_11,
            db_estado_hcsr04_2        => s_db_estado_hcsr04_12,
            db_pronto_estado_hcsr04_1 => s_db_pronto_estado_hcsr04_11,
            db_pronto_estado_hcsr04_2 => s_db_pronto_estado_hcsr04_12,
            db_medida1                => s_db_medida11,
            db_medida2                => s_db_medida12,
            db_estado                 => s_db_estado_medidor_jogada_1 -- estado da UC
        );

    MUX0: mux_8x1_n
        generic map (
            BITS => 4
        )
        port map ( 
            D0      => s_db_medida01(3 downto 0),
            D1      => s_db_estado_hcsr04_01,
            D2      => s_db_medida11(3 downto 0),
            D3      => s_db_estado_hcsr04_11,
            D4      => s_db_estado_tapa_no_tatu(3 downto 0),
            D5      => "0000",
            D6      => "0000",
            D7      => "0000",
            SEL     => debug_seletor,
            MUX_OUT => s_db_mux0
        );

    HEX7SEG0: hex7seg
        port map (
            hexa => s_db_mux0,
            sseg => db_display0
        );

    MUX1: mux_8x1_n
        generic map (
            BITS => 4
        )
        port map ( 
            D0      => s_db_medida01(7 downto 4),
            D1      => s_db_estado_hcsr04_02,
            D2      => s_db_medida11(7 downto 4),
            D3      => s_db_estado_hcsr04_12,
            D4      => "000" & s_db_estado_tapa_no_tatu(4),
            D5      => "0000",
            D6      => "0000",
            D7      => "0000",
            SEL     => debug_seletor,
            MUX_OUT => s_db_mux1
        );

    HEX7SEG1: hex7seg
        port map (
            hexa => s_db_mux1,
            sseg => db_display1
        );

    MUX2: mux_8x1_n
        generic map (
            BITS => 4
        )
        port map ( 
            D0      => s_db_medida01(11 downto 8),
            D1      => "0000",
            D2      => s_db_medida11(11 downto 8),
            D3      => "0000",
            D4      => "0000",
            D5      => "0000",
            D6      => "0000",
            D7      => "0000",
            SEL     => debug_seletor,
            MUX_OUT => s_db_mux2
        );

    HEX7SEG2: hex7seg
        port map (
            hexa => s_db_mux2,
            sseg => db_display2
        );

    MUX3: mux_8x1_n
        generic map (
            BITS => 4
        )
        port map ( 
            D0      => s_db_medida02(3 downto 0),
            D1      => s_db_estado_hcsr04_02,
            D2      => s_db_medida12(3 downto 0),
            D3      => s_db_estado_hcsr04_12,
            D4      => s_hex_pontuacao0,
            D5      => "0000",
            D6      => "0000",
            D7      => "0000",
            SEL     => debug_seletor,
            MUX_OUT => s_db_mux3
        );

    HEX7SEG3: hex7seg
        port map (
            hexa => s_db_mux3,
            sseg => db_display3
        );

    MUX4: mux_8x1_n
        generic map (
            BITS => 4
        )
        port map ( 
            D0      => s_db_medida02(7 downto 4),
            D1      => "0000",
            D2      => s_db_medida12(7 downto 4),
            D3      => "0000",
            D4      => s_hex_pontuacao1,
            D5      => "0000",
            D6      => "0000",
            D7      => "0000",
            SEL     => debug_seletor,
            MUX_OUT => s_db_mux4
        );

    HEX7SEG4: hex7seg
        port map (
            hexa => s_db_mux4,
            sseg => db_display4
        );

    MUX5: mux_8x1_n
        generic map (
            BITS => 4
        )
        port map ( 
            D0      => s_db_medida02(11 downto 8),
            D1      => s_db_estado_medidor_jogada_0,
            D2      => s_db_medida12(11 downto 8),
            D3      => s_db_estado_medidor_jogada_1,
            D4      => "00" & s_vidas,
            D5      => "0000",
            D6      => "0000",
            D7      => "0000",
            SEL     => debug_seletor,
            MUX_OUT => s_db_mux5
        );

    HEX7SEG5: hex7seg
        port map (
            hexa => s_db_mux5,
            sseg => db_display5
        );

    LED8: mux_8x1
        port map ( 
            D0      => '0',
            D1      => s_db_pronto_estado_hcsr04_01,
            D2      => '0',
            D3      => s_db_pronto_estado_hcsr04_11,
            D4      => reset,
            D5      => '0',
            D6      => '0',
            D7      => '0',
            SEL     => debug_seletor,
            MUX_OUT => db_led8
        );

    LED9: mux_8x1
        port map ( 
            D0      => '0',
            D1      => s_db_pronto_estado_hcsr04_02,
            D2      => '0',
            D3      => s_db_pronto_estado_hcsr04_12,
            D4      => iniciar,
            D5      => '0',
            D6      => '0',
            D7      => '0',
            SEL     => debug_seletor,
            MUX_OUT => db_led9
        );
		  
	 -- Sinais displays
    displayVidas: hex7seg
        port map(
            hexa   => "00" & s_vidas,
            sseg   => vidas_hex
        );
		  
	displayPontuacao0: hex7seg
        port map(
            hexa   => s_hex_pontuacao0,
            sseg   => s_pontuacao0
        );

	pontuacao0 <= not s_pontuacao0; -- catodo, precisa inverter
		  
    displayPontuacao1: hex7seg
        port map(
            hexa   => s_hex_pontuacao1,
            sseg   => pontuacao1
        );

	 -- Sinais de saída
    s_botoes_selecionados(5) <= s_tatus_selecionados(5) or botoes_mqtt(5); -- or botoes;
	s_botoes_selecionados(4) <= s_tatus_selecionados(4) or botoes_mqtt(4); -- or botoes;
	s_botoes_selecionados(3) <= s_tatus_selecionados(3) or botoes_mqtt(3); -- or botoes;
	s_botoes_selecionados(2) <= s_tatus_selecionados(2) or botoes_mqtt(2); -- or botoes;
	s_botoes_selecionados(1) <= s_tatus_selecionados(1) or botoes_mqtt(1); -- or botoes;
	s_botoes_selecionados(0) <= s_tatus_selecionados(0) or botoes_mqtt(0); -- or botoes;
	fim_de_jogo           <= s_fim_de_jogo;
    db_tatus              <= s_tatus; -- s_botoes_selecionados;
    vidas                 <= s_vidas;
	 
	 -- sinais mqtt
	 s_iniciar <= iniciar or iniciar_mqtt;
	 init_fpga <= iniciar;
	 fim_de_jogo_mqtt   <= s_fim_de_jogo;
	 
	reset_mqtt <= reset;
	 
	-- Teste displays
	--vidas_hex <= "0000000";
	--pontuacao1 <= "0000000";
	--pontuacao0 <= "1111111";

end architecture rtl;
