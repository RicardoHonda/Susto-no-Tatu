-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : mux_8x1_n.vhd
-- Projeto   : Experiencia 6 - Sistema de Sonar
-------------------------------------------------------------------------
-- Descricao : 
--             multiplexador 8x1 com entradas de BITS bits (generic)
--
-- adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL" 
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/09/2022  1.1     Edson Midorikawa  revisao
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity mux_8x1_n is
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
end entity;

architecture behav of mux_8x1_n is
begin
    MUX_OUT <= D7 when (SEL = "111") else
               D6 when (SEL = "110") else
               D5 when (SEL = "101") else
               D4 when (SEL = "100") else
               D3 when (SEL = "011") else
               D2 when (SEL = "010") else
               D1 when (SEL = "001") else
               D0 when (SEL = "000") else
               (others => '1');
end architecture behav;
