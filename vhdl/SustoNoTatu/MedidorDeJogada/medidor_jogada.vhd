library IEEE;
use IEEE.std_logic_1164.all;

entity medidor_jogada is
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
        db_estado                 : out std_logic_vector(3 downto 0); -- estado da UC
		db_timeout_1              : out std_logic;
		db_timeout_2              : out std_logic
    );
end entity medidor_jogada;


architecture rtl of medidor_jogada is

    component medidor_jogada_uc is 
        port ( 
            clock                : in  std_logic;
            reset                : in  std_logic;
            inicia               : in  std_logic;
            pronto_hcsr04_1      : in  std_logic;
            pronto_hcsr04_2      : in  std_logic;
            fim_espera           : in  std_logic;
            fim_timeout          : in  std_logic;
            fim_de_jogo          : in  std_logic;
            zera_espera          : out std_logic;
            conta_espera         : out std_logic;
            zera_timeout         : out std_logic;
            conta_timeout        : out std_logic;
            medir_1              : out std_logic;
            medir_2              : out std_logic;
            reset_1              : out std_logic;
            reset_2              : out std_logic;
            registra_distancia_1 : out std_logic;
            registra_distancia_2 : out std_logic;
            db_estado            : out std_logic_vector(3 downto 0) 
        );
    end component;

    component medidor_jogada_fd is
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
    end component;

    signal s_fim_espera, s_zera_medida, s_zera_espera, s_conta_espera, s_medir_1, s_medir_2     : std_logic;
    signal s_pronto_hcsr04_1, s_pronto_hcsr04_2, s_registra_distancia_1, s_registra_distancia_2 : std_logic;
    signal s_medida1, s_medida2                                                                 : std_logic_vector(11 downto 0);
	signal s_zera_timeout, s_conta_timeout, s_fim_timeout, s_reset_1, s_reset_2                 : std_logic;

begin

    UC: medidor_jogada_uc 
        port map ( 
            clock                => clock,
            reset                => reset,
            inicia               => inicia,
            pronto_hcsr04_1      => s_pronto_hcsr04_1,
            pronto_hcsr04_2      => s_pronto_hcsr04_2,
            fim_espera           => s_fim_espera,
            fim_de_jogo          => fim_de_jogo,
            zera_espera          => s_zera_espera,
            conta_espera         => s_conta_espera,
			zera_timeout         => s_zera_timeout,  
			conta_timeout        => s_conta_timeout,
            medir_1              => s_medir_1,
            medir_2              => s_medir_2,
			reset_1              => s_reset_1,
			reset_2              => s_reset_2,
            registra_distancia_1 => s_registra_distancia_1,
            registra_distancia_2 => s_registra_distancia_2,
			fim_timeout          => s_fim_timeout,
            db_estado            => db_estado
        );

    db_pronto_estado_hcsr04_1 <= s_pronto_hcsr04_1;
    db_pronto_estado_hcsr04_2 <= s_pronto_hcsr04_2;

    FD: medidor_jogada_fd
        port map (
            clock                => clock,
            reset                => reset,
            zera_espera          => s_zera_espera,
            conta_espera         => s_conta_espera,
			zera_timeout         => s_zera_timeout,
			conta_timeout        => s_conta_timeout,
            medir_1              => s_medir_1,
            medir_2              => s_medir_2,
			reset_1              => s_reset_1,
			reset_2              => s_reset_2,
            echo1                => echo1,
            echo2                => echo2,
            registra_distancia_1 => s_registra_distancia_1,
            registra_distancia_2 => s_registra_distancia_2, 
            trigger1             => trigger1,
            trigger2             => trigger2,
            pronto_hcsr04_1      => s_pronto_hcsr04_1,
            pronto_hcsr04_2      => s_pronto_hcsr04_2,
            fim_espera           => s_fim_espera,
			fim_timeout          => s_fim_timeout,
            tatus                => tatus,
            medida1              => db_medida1,
            medida2              => db_medida2,
            db_estado_hcsr04_1   => db_estado_hcsr04_1,
            db_estado_hcsr04_2   => db_estado_hcsr04_2,
			db_timeout_1         => db_timeout_1,
			db_timeout_2         => db_timeout_2
        );

end architecture rtl;
