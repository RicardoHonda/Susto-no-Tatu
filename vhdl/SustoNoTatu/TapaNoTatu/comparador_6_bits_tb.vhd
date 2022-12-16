--------------------------------------------------------------------------
-- Arquivo   : comparador_6_bits_tb.vhd
-- Projeto   : Tapa no tatu
--                              
--------------------------------------------------------------------------
-- Descricao : testbench para atestar o funcionamento do comparador de 6
--             bits
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity comparador_6_bits_tb is
end entity;

architecture tb of comparador_6_bits_tb is

    -- Componente a ser testado (Device Under Test -- DUT)
    component comparador_6_bits
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
            o_ASEQB : out std_logic
        );
    end component;
  
    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
    signal toupeiras_in     : std_logic_vector (5 downto 0) := "000000";
    signal jogada_in        : std_logic_vector (5 downto 0) := "000000";
    signal db_ASEQB_out     : std_logic := '0';

    constant wait_period   : time := 20 ns;
    
    begin

    -- Conecta DUT (Device Under Test)
    dut: comparador_6_bits
        port map( 
            i_A5    => toupeiras_in(5),
            i_B5    => jogada_in(5),
            i_A4    => toupeiras_in(4),
            i_B4    => jogada_in(4),
            i_A3    => toupeiras_in(3),
            i_B3    => jogada_in(3),
            i_A2    => toupeiras_in(2),
            i_B2    => jogada_in(2),
            i_A1    => toupeiras_in(1),
            i_B1    => jogada_in(1),
            i_A0    => toupeiras_in(0),
            i_B0    => jogada_in(0),
            o_ASEQB => db_ASEQB_out
        );

    -- geracao dos sinais de entrada (estimulos)
    stimulus: process is
    begin
        report "BOT"; --indica o começo do teste
        
        ---- Teste 0 (Caso dummy - sem jogada)
        toupeiras_in <= "000001";
        jogada_in <= "000000";
        wait for wait_period;
        assert db_ASEQB_out = '0' report "Caso 0 falhou" severity warning;

        ---- Teste 1 (Acerta a toupeira)
        toupeiras_in <= "000010";
        jogada_in <= "000010";
        wait for wait_period;
        assert db_ASEQB_out = '1' report "Caso 1 falhou" severity warning;

        ---- Teste 2 (Erra a toupeira)
        toupeiras_in <= "001100";
        jogada_in <= "000010";
        wait for wait_period;
        assert db_ASEQB_out = '0' report "Caso 2 falhou" severity warning;
        
        ---- Teste 3 (Acerta a toupeira da "direita")
        toupeiras_in <= "110000";
        jogada_in <= "010000";
        wait for wait_period;
        assert db_ASEQB_out = '1' report "Caso 3 falhou" severity warning;
        
        ---- Teste 4 (Acerta a toupeira da "esquerda")
        toupeiras_in <= "110000";
        jogada_in <= "100000";
        wait for wait_period;
        assert db_ASEQB_out = '1' report "Caso 4 falhou" severity warning;

        report "EOT"; --indica o fim do teste    
        wait; 
    end process;
end architecture;
