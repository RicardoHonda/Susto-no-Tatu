library IEEE;
use IEEE.std_logic_1164.all;

entity medidor_jogada_fd is
    port (
        clock                : in  std_logic;
        reset                : in  std_logic;
        zera_espera          : in  std_logic;
        conta_espera         : in  std_logic;
		zera_timeout         : in  std_logic;
        conta_timeout        : in  std_logic;
        medir_1              : in  std_logic;
        medir_2              : in  std_logic;
		reset_1              : in  std_logic;
        reset_2              : in  std_logic;
        echo1                : in  std_logic;
        echo2                : in  std_logic;
        registra_distancia_1 : in  std_logic;
        registra_distancia_2 : in  std_logic;
        trigger1             : out std_logic;
        trigger2             : out std_logic;
        pronto_hcsr04_1      : out std_logic;
        pronto_hcsr04_2      : out std_logic;
        fim_espera           : out std_logic;
		fim_timeout          : out std_logic;
        tatus                : out std_logic_vector(2 downto 0);
        medida1              : out std_logic_vector(11 downto 0);
        medida2              : out std_logic_vector(11 downto 0);
        db_estado_hcsr04_1   : out std_logic_vector(3 downto 0);
        db_estado_hcsr04_2   : out std_logic_vector(3 downto 0);
		db_timeout_1         : out std_logic;
		db_timeout_2         : out std_logic
    );
end entity;

architecture rtl of medidor_jogada_fd is

    component interface_hcsr04 is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            medir      : in  std_logic;
            echo       : in  std_logic;
            trigger    : out std_logic;
            medida     : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0); -- estado da UC
			db_timeout : out std_logic
        );
    end component interface_hcsr04;

    component comparador_distancia is
        port (
            A        : in std_logic_vector(11 downto 0);
            B        : in std_logic_vector(11 downto 0);
            add_2    : in std_logic;
            is_close : out std_logic -- A está proximo de B com intervalo de erro
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
    end component;

    component registrador_n is
        generic (
           constant N: integer := 8 
        );
        port (
           clock  : in  std_logic;
           clear  : in  std_logic;
           enable : in  std_logic;
           D      : in  std_logic_vector (N-1 downto 0);
           Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component;

    signal s_medida1, s_medida2, s_medida_registrada1, s_medida_registrada2 : std_logic_vector(11 downto 0);
    signal s_dist_0D, s_dist_1D, s_dist_2D                                  : std_logic_vector(11 downto 0);
    signal s_dist_0E, s_dist_1E, s_dist_2E                                  : std_logic_vector(11 downto 0);
    signal s_tatu_0D, s_tatu_1D, s_tatu_2D                                  : std_logic;
    signal s_tatu_0E, s_tatu_1E, s_tatu_2E                                  : std_logic;
    signal s_interface_hcsr04_reset1, s_interface_hcsr04_reset2             : std_logic;

begin

    s_dist_0D <= "0000" & "0110" & "1000"; -- 068

    s_dist_1D <= "0001" & "0111" & "0000"; -- 170

    s_dist_2D <= "0011" & "0000" & "0000"; -- 300

    s_dist_0E <= "0010" & "1000" & "0000"; -- 280

    s_dist_1E <= "0001" & "0111" & "0101"; -- 175

    s_dist_2E <= "0000" & "0110" & "0111"; -- 067

    s_interface_hcsr04_reset1 <= reset or reset_1;
	s_interface_hcsr04_reset2 <= reset or reset_2;

    MEDIDOR_1: interface_hcsr04
        port map (
            clock      => clock,
            reset      => s_interface_hcsr04_reset1,
            medir      => medir_1,
            echo       => echo1,
            trigger    => trigger1,
            medida     => s_medida1, -- 3 digitos BCD
            pronto     => pronto_hcsr04_1,
            db_estado  => db_estado_hcsr04_1,
			db_timeout => db_timeout_1
        );

    MEDIDOR_2: interface_hcsr04
        port map (
            clock      => clock,
            reset      => s_interface_hcsr04_reset2,
            medir      => medir_2,
            echo       => echo2,
            trigger    => trigger2,
            medida     => s_medida2, -- 3 digitos BCD
            pronto     => pronto_hcsr04_2,
            db_estado  => db_estado_hcsr04_2,
			db_timeout => db_timeout_2
        );

    REGISTRADOR_1: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra_distancia_1,
            D      => s_medida1,
            Q      => s_medida_registrada1
        );

    REGISTRADOR_2: registrador_n
        generic map (
            N => 12 
        )
        port map (
            clock  => clock,
            clear  => '0',
            enable => registra_distancia_2,
            D      => s_medida2,
            Q      => s_medida_registrada2
        );

        comparador_0_D: comparador_distancia
        port map (
            A        => s_medida_registrada1,
            B        => s_dist_0D,
            add_2    => '0',
            is_close => s_tatu_0D
        );

    comparador_1_D: comparador_distancia
        port map (
            A        => s_medida_registrada1,
            B        => s_dist_1D,
            add_2    => '0',
            is_close => s_tatu_1D
        );

    comparador_2_D: comparador_distancia
        port map (
            A        => s_medida_registrada1,
            B        => s_dist_2D,
            add_2    => '0',
            is_close => s_tatu_2D
        );

    comparador_0_E: comparador_distancia
        port map (
            A        => s_medida_registrada2,
            B        => s_dist_0E,
            add_2    => '0',
            is_close => s_tatu_0E
        );

    comparador_1_E: comparador_distancia
        port map (
            A        => s_medida_registrada2,
            B        => s_dist_1E,
            add_2    => '0',
            is_close => s_tatu_1E
        );

    comparador_2_E: comparador_distancia
        port map (
            A        => s_medida_registrada2,
            B        => s_dist_2E,
            add_2    => '0',
            is_close => s_tatu_2E
        );

    CONTADOR_ESPERA: contador_m
        generic map (
            M => 3000000,
            N => 22
        )
        port map (
            clock => clock,
            zera  => zera_espera,
            conta => conta_espera,
            Q     => open,
            fim   => fim_espera
        );
		  
	  CONTADOR_TIMEOUT: contador_m
        generic map (
            M => 6000000,
            N => 22
        )
        port map (
            clock => clock,
            zera  => zera_timeout,
            conta => conta_timeout,
            Q     => open,
            fim   => fim_timeout
        );
		  
	 
	 
    tatus(0) <= s_tatu_0D; --or s_tatu_0E;
    tatus(1) <= s_tatu_1D or s_tatu_1E;
    tatus(2) <= s_tatu_2E; -- s_tatu_2D or s_tatu_2E;

    medida1 <= s_medida_registrada1;
    medida2 <= s_medida_registrada2;

end architecture rtl;
