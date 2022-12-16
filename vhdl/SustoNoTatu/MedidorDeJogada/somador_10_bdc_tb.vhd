library ieee;
use ieee.std_logic_1164.all;

entity somador_10_bcd_tb is
end entity;

architecture tb of somador_10_bcd_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component somador_10_bcd is
    port (
        val_in  : in  std_logic_vector(11 downto 0);
        val_out : out std_logic_vector(11 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal val_in  : std_logic_vector(11 downto 0) := "000000000000";
  signal val_out : std_logic_vector(11 downto 0) := "000000000000";

begin
  
  -- Conecta DUT (Device Under Test)
  dut: somador_10_bcd
    port map (
        val_in     => val_in,
        val_out    => val_out
    );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    
    ---- valores iniciais ----------------
    val_in  <= "0000" & "0000" & "0000"; -- 000

    ---- espera de 100us
    wait for 100 us;

    val_in  <= "0001" & "0001" & "0001"; -- 111
    wait for 100 us;

    val_in  <= "0001" & "0010" & "0001"; -- 121
    wait for 100 us;

    val_in  <= "0001" & "0011" & "0001"; -- 131
    wait for 100 us;

    val_in  <= "0001" & "0100" & "0001"; -- 141
    wait for 100 us;

    val_in  <= "0001" & "0101" & "0001"; -- 151
    wait for 100 us;

    val_in  <= "0001" & "0110" & "0001"; -- 161
    wait for 100 us;

    val_in  <= "0001" & "0111" & "0001"; -- 171
    wait for 100 us;

    val_in  <= "0001" & "1000" & "0001"; -- 181
    wait for 100 us;

    val_in  <= "0000" & "1001" & "0001"; -- 091
    wait for 100 us;

    val_in  <= "0001" & "1001" & "0001"; -- 191
    wait for 100 us;

    val_in  <= "0010" & "1001" & "0001"; -- 291
    wait for 100 us;

    val_in  <= "0011" & "1001" & "0001"; -- 391
    wait for 100 us;

    val_in  <= "0100" & "1001" & "0001"; -- 491
    wait for 100 us;

    val_in  <= "0101" & "1001" & "0001"; -- 591
    wait for 100 us;

    val_in  <= "0110" & "1001" & "0001"; -- 691
    wait for 100 us;

    val_in  <= "0111" & "1001" & "0001"; -- 791
    wait for 100 us;

    val_in  <= "1000" & "1001" & "0001"; -- 891
    wait for 100 us;

    val_in  <= "1001" & "1001" & "0001"; -- 991
    wait for 100 us;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
