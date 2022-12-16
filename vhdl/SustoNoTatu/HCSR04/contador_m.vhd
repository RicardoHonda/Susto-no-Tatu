------------------------------------------------------------------
-- Arquivo   : contador_m.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : contador binario  
--             > parametro M: modulo de contagem
--             > parametro N: numero de bits da saida
--
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic
    );
end entity contador_m;

architecture contador_m_arch of contador_m is
    signal IQ: integer range 0 to M-1;
begin
  
    process (clock,zera,conta,IQ)
    begin
        if zera='1' then IQ <= 0; 
        elsif clock'event and clock='1' then
            if conta='1' then 
                if IQ=M-1 then
                    IQ <= 0; 
                else
                    IQ <= IQ + 1; 
                end if;
            end if;
        end if;
        
        if IQ=M-1 then
            fim <= '1'; 
        else
            fim <= '0'; 
        end if;
	    
        Q <= std_logic_vector(to_unsigned(IQ, Q'length));
    
    end process;
end architecture contador_m_arch;