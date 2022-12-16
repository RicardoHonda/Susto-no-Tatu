-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : registrador_n.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
-------------------------------------------------------------------------
-- Descricao : registrador com numero de bits N como generic
--             com clear assincrono e carga sincrona
--             baseado no codigo vreg16.vhd do livro
--             J. Wakerly, Digital design: principles and practices 4e
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao
--     08/06/2020  1.1     Edson Midorikawa  revisao e melhoria de codigo 
--     09/09/2020  1.2     Edson Midorikawa  revisao 
--     09/09/2021  1.3     Edson Midorikawa  revisao 
--     03/09/2022  1.4     Edson Midorikawa  revisao do codigo
-------------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_n is
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
end entity registrador_n;

architecture registrador_n of registrador_n is
    signal IQ: std_logic_vector(N-1 downto 0);
begin

process(clock, clear, enable, IQ)
    begin
        if (clear = '1') then IQ <= (others => '0');
        elsif (clock'event and clock='1') then
            if (enable='1') then IQ <= D; 
            else IQ <= IQ;
            end if;
        end if;
        Q <= IQ;
    end process;
  
end architecture registrador_n;
