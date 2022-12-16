--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_uc.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : unidade de controle do circuito de interface com
--             sensor de distancia
--             
--             implementa arredondamento da medida
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     03/09/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity medidor_jogada_uc is 
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
end medidor_jogada_uc;

architecture fsm_arch of medidor_jogada_uc is
    type tipo_estado is (inicial, medida1, espera_medida1, registra1, espera1, reseta1,
                                  medida2, espera_medida2, registra2, espera2, reseta2);
    signal Eatual, Eprox : tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (inicia, pronto_hcsr04_1, pronto_hcsr04_2, fim_espera, fim_de_jogo, fim_timeout, Eatual) 
    begin
        case Eatual is
            when inicial        => if inicia='1'                            then Eprox <= medida1;
                                   else                                          Eprox <= inicial;
                                   end if;
            when medida1        => Eprox <= espera_medida1;
            when espera_medida1 => if    pronto_hcsr04_1='1'                then Eprox <= registra1;
                                   elsif fim_timeout='1'                    then Eprox <= reseta1;
                                   else                                          Eprox <= espera_medida1;
                                   end if;
            when reseta1        => Eprox <= espera1;
            when registra1      => Eprox <= espera1;
            when espera1        => if    fim_espera='0' and fim_de_jogo='0' then Eprox <= espera1;
                                   elsif fim_espera='1' and fim_de_jogo='0' then Eprox <= medida2;
                                   else                                          Eprox <= inicial;
                                   end if;
            when medida2        => Eprox <= espera_medida2;
            when espera_medida2 => if    pronto_hcsr04_2='1'                then Eprox <= registra2;
                                   elsif fim_timeout='1'                    then Eprox <= reseta2;
                                   else                                          Eprox <= espera_medida2;
                                   end if;
            when reseta2        => Eprox <= espera2;
            when registra2      => Eprox <= espera2;
            when espera2        => if    fim_espera='0' and fim_de_jogo='0' then Eprox <= espera2;
                                   elsif fim_espera='1' and fim_de_jogo='0' then Eprox <= medida1;
                                   else                                          Eprox <= inicial;
                                   end if;
            when others         => Eprox <= inicial;
        end case;
    end process;

    -- saidas de controle
    with Eatual select
        medir_1              <= '1' when medida1,
                                '0' when others;
    with Eatual select
        medir_2              <= '1' when medida2,
                                '0' when others;
    with Eatual select
        zera_espera          <= '1' when medida1 | medida2,
                                '0' when others;
    with Eatual select
        conta_espera         <= '1' when espera1 | espera2,
                                '0' when others;
	with Eatual select
        zera_timeout         <= '1' when medida1 | medida2,
                                '0' when others;
    with Eatual select
        conta_timeout        <= '1' when espera_medida1 | espera_medida2,
                                '0' when others;
    with Eatual select
        registra_distancia_1 <= '1' when registra1,
                                '0' when others;
    with Eatual select
        registra_distancia_2 <= '1' when registra2,
                                '0' when others;
	with Eatual select
        reset_1              <= '1' when reseta1,
                                '0' when others;
	with Eatual select
        reset_2              <= '1' when reseta2,
                                '0' when others;

    with Eatual select
        db_estado <= "0001" when inicial, 
                     "0010" when medida1, 
                     "0011" when espera_medida1,
                     "0100" when registra1,
                     "0101" when espera1,
                     "0110" when medida2,
                     "0111" when espera_medida2,
                     "1000" when registra2,
                     "1001" when espera2,
					 "1010" when reseta1,
					 "1011" when reseta2,
                     "0000" when others;

end architecture fsm_arch;
