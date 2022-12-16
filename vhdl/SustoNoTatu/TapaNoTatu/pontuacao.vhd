-------------------------------------------------------------------
-- Arquivo   : pontuacao.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------
-- Descricao : Contador da pontuacao
--             Aumenta a cada vez que acerta o tatu
--             Saidas: numero de pontos em binario
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pontuacao is
	generic (
        constant limMax: integer := 100 -- Limite da pontuação
    );
	port (
        clock     : in  std_logic;
        clr       : in  std_logic;
        enp       : in  std_logic;
	    acertou   : in  std_logic;
        pontos    : out std_logic_vector (natural(ceil(log2(real(limMax)))) - 1 downto 0);
		end_ponts : out std_logic
   );
end pontuacao;

architecture comportamental of pontuacao is
    signal contaPontos: integer range 0 to limMax - 1; -- Declaração do sinal interno de contagem
begin
    process (clock)
    begin
        if clock'event and clock = '1' then -- Se o clock altera o sinal para 1 (1)
		    if clr = '0' then
		        contaPontos <= 0;    -- Se o clear foi ativado (Ativo baixo), reseta a contagem (2)
		    elsif enp = '1' and acertou = '1' then 
				if contaPontos = limMax -1 then
					contaPontos <= contaPontos; -- Caso esteja na pontuacao maxima, mantem o valor
				else
					contaPontos <= contaPontos + 1; -- senão, incrementa a contagem
				end if;
            else
		        contaPontos <= contaPontos; -- senão, mantém contagem anterior
		    end if; -- Fim do if 2
	    end if; -- Fim do if 1
    end process;
    -- saida pontos
    pontos <= std_logic_vector(to_unsigned(contaPontos, pontos'length)); -- Converte para binario
	end_ponts <= '1' when contaPontos = limMax-1 else '0';
end comportamental;
