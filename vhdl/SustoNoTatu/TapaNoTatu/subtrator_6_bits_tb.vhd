--------------------------------------------------------------------------
-- Arquivo   : subtrator_6_bits_tb.vhd
-- Projeto   : Tapa no tatu
--                              
--------------------------------------------------------------------------
-- Descricao : testbench para atestar o funcionamento do subtrator de 6
--             bits, usado no projeto "Tapa no tatu"
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity subtrator_6_bits_tb is
end entity;

architecture tb of subtrator_6_bits_tb is

    -- Componente a ser testado (Device Under Test -- DUT)
    component subtrator_6_bits
        port (
            i_A          : in  std_logic_vector(5 downto 0);
            i_B          : in  std_logic_vector(5 downto 0);
            resultado    : out std_logic_vector(5 downto 0);
            tem_toupeira : out std_logic
        );
    end component;
  
    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    -- valores iniciais para fins de simulacao (GHDL ou ModelSim)
    signal toupeiras_in     : std_logic_vector(5 downto 0) := "000000";
    signal jogada_in        : std_logic_vector(5 downto 0) := "000000";
    signal resultado_out    : std_logic_vector(5 downto 0) := "000000";
    signal tem_toupeira_out : std_logic := '0';

    constant wait_period   : time := 20 ns;

    begin

    -- Conecta DUT (Device Under Test)
    dut: subtrator_6_bits
        port map(
            i_A          => toupeiras_in,
            i_B          => jogada_in,
            resultado    => resultado_out,
            tem_toupeira => tem_toupeira_out
        );

    -- geracao dos sinais de entrada (estimulos)
    stimulus: process is
    begin
        report "BOT"; --indica o começo do teste

        ---- Teste 0 (dummy - sem jogada)
        toupeiras_in <= "000001";
        jogada_in <= "000000";
        wait for wait_period;
        assert resultado_out = "000001" report "Caso 0 falhou (resultado)" severity warning;
        assert tem_toupeira_out = '1' report "Caso 0 falhou (tem_toupeira)" severity warning;

        ---- Teste 1 (estado final sem toupeiras)
        toupeiras_in <= "000010";
        jogada_in <= "000010";
        wait for wait_period;
        assert resultado_out = "000000" report "Caso 1 falhou (resultado)" severity warning;
        assert tem_toupeira_out = '0' report "Caso 1 falhou (tem_toupeira)" severity warning;

        ---- Teste 2 (estado final sem a toupeira da "direita")
        toupeiras_in <= "001100";
        jogada_in <= "000100";
        wait for wait_period;
        assert resultado_out = "001000" report "Caso 2 falhou (resultado)" severity warning;
        assert tem_toupeira_out = '1' report "Caso 2 falhou (tem_toupeira)" severity warning;
        
        ---- Teste 3 (estado final sem a toupeira da "esquerda")
        toupeiras_in <= "001100";
        jogada_in <= "001000";
        wait for wait_period;
        assert resultado_out = "000100" report "Caso 3 falhou (resultado)" severity warning;
        assert tem_toupeira_out = '1' report "Caso 3 falhou (tem_toupeira)" severity warning;

        report "EOT"; --indica o fim do teste    
        wait; 
    end process;
end architecture;
