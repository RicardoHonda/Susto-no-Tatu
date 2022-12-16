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

entity mux_8x1 is
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
end entity;

architecture behav of mux_8x1 is
begin
    MUX_OUT <= D7 when (SEL = "111") else
               D6 when (SEL = "110") else
               D5 when (SEL = "101") else
               D4 when (SEL = "100") else
               D3 when (SEL = "011") else
               D2 when (SEL = "010") else
               D1 when (SEL = "001") else
               D0 when (SEL = "000") else
               '1';
end architecture behav;
