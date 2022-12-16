library ieee;
use ieee.std_logic_1164.all;

entity servo_tatu_tb is
end entity;

architecture tb of servo_tatu_tb is
  
    -- Componente a ser testado (Device Under Test -- DUT)
    component servo_tatu is
        port (
            clock : in  std_logic;
            reset : in  std_logic;
            tatus : in  std_logic_vector(2 downto 0);
            pwm0  : out std_logic;
            pwm1  : out std_logic;
            pwm2  : out std_logic
        );
    end component; 
  
    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
    signal clock_in : std_logic := '0';
    signal reset_in : std_logic := '0';
    signal tatus_in : std_logic_vector(2 downto 0) := "000";
    signal pwm0_out : std_logic := '0';
    signal pwm1_out : std_logic := '0';
    signal pwm2_out : std_logic := '0';

    -- Configurações do clock
    constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
    signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock
    
    -- Array de casos de teste
    type caso_teste_type is record
        id    : natural; 
        tempo : integer;     
    end record;

begin
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
    -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
    -- simulação de eventos
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
    
    -- Conecta DUT (Device Under Test)
    dut: servo_tatu
      port map (
          clock => clock_in,
          reset => reset_in,
          tatus => tatus_in,
          pwm0  => pwm0_out,
          pwm1  => pwm1_out,
          pwm2  => pwm2_out
      );

    -- geracao dos sinais de entrada (estimulos)
    stimulus: process is
    begin
      
        assert false report "Inicio das simulacoes" severity note;
        keep_simulating <= '1';
        
        ---- valores iniciais ----------------
        tatus_in  <= "000";

        ---- inicio: reset ----------------
        wait for 2*clockPeriod;
        reset_in <= '1'; 
        wait for 2 us;
        reset_in <= '0';
        wait until falling_edge(clock_in);

        ---- espera de 100us
        wait for 10000 us;

        tatus_in  <= "100";
        wait for 20000 us;

        tatus_in  <= "010";
        wait for 20000 us;

        tatus_in  <= "001";
        wait for 20000 us;

        tatus_in  <= "110";
        wait for 20000 us;

        tatus_in  <= "101";
        wait for 20000 us;

        tatus_in  <= "011";
        wait for 20000 us;

        tatus_in  <= "111";
        wait for 20000 us;

        ---- final dos casos de teste da simulacao
        assert false report "Fim das simulacoes" severity note;
        keep_simulating <= '0';
        
        wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
    end process;

end architecture;
