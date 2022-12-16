library ieee;
use ieee.std_logic_1164.all;

entity contador_cm_uc is 
    port ( 
        clock        : in  std_logic;
        reset        : in  std_logic;
        pulso        : in  std_logic; -- echo
        tick         : in  std_logic;
        arredonda    : in  std_logic;
        fim_cont_bcd : in  std_logic;
        s_zera_tick  : out std_logic;
        s_conta_tick : out std_logic;
        s_zera_bcd   : out std_logic;
        s_conta_bcd  : out std_logic;
        pronto       : out std_logic;
        db_estado    : out std_logic_vector(3 downto 0) 
    );
end contador_cm_uc;

architecture fsm_arch of contador_cm_uc is
    type tipo_estado is (inicial, conta_tick, conta_bcd, verifica_arredonda, 
                         verifica_maximo, valor_maximo, final);
    signal Eatual, Eprox: tipo_estado;
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
    process (pulso, tick, arredonda, Eatual, fim_cont_bcd) 
    begin
        case Eatual is
            when inicial            => if pulso='1'                 then Eprox <= conta_tick;
                                       else                              Eprox <= inicial;
                                       end if;
            when conta_tick         => if    pulso='1' and tick='1' then Eprox <= verifica_maximo;
                                       elsif pulso='0'              then Eprox <= verifica_arredonda;
                                       else                              Eprox <= conta_tick;
                                       end if;
            when conta_bcd          => if pulso='0'                 then Eprox <= final;
                                       else                              Eprox <= conta_tick;
                                       end if;
            when verifica_arredonda => if arredonda='0'             then Eprox <= final;
                                       else                              Eprox <= verifica_maximo;
                                       end if;
            when verifica_maximo    => if fim_cont_bcd='0'          then Eprox <= conta_bcd;
                                       else                              Eprox <= valor_maximo;
                                       end if;
            when valor_maximo       => if pulso='0'                 then Eprox <= final;
                                       else                              Eprox <= valor_maximo;
                                       end if;
            when final              => Eprox <= inicial;
            when others             => Eprox <= inicial;
        end case;
    end process;

    -- saidas de controle
    with Eatual select 
        s_zera_tick  <= '1' when inicial | conta_bcd, 
                        '0' when others;
    with Eatual select
        s_conta_tick <= '1' when conta_tick, 
                        '0' when others;
    with Eatual select
        s_zera_bcd   <= '1' when inicial, 
                        '0' when others;
    with Eatual select
        s_conta_bcd  <= '1' when conta_bcd, 
                        '0' when others;
    with Eatual select
        pronto       <= '1' when final, 
                        '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when conta_tick, 
                   "0010" when conta_bcd, 
                   "0011" when verifica_arredonda,
                   "0100" when valor_maximo,
                   "0101" when final, 
                   "0110" when verifica_maximo,
                   "0111" when others;
end architecture fsm_arch;
