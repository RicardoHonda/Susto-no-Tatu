-------------------------------------------------------------------
-- Arquivo   : contador_decrescente.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------
-- Descricao : Contador do tempo da jogada
--             Diminui a cada rodada (pelo input)
--             Saidas: timeout se o limite foi alcancado
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_decrescente is
	port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        conta       : in  std_logic;
		limite      : in  integer;
		timeout     : out std_logic;
        -- sinal de depuracao
        db_contagem : out integer
    );
end contador_decrescente;

architecture comportamental of contador_decrescente is
    signal tempo: integer;
begin
    process (clock, reset, limite)
	begin
        if reset = '1' then    
		    tempo <= 0;   
        
		elsif rising_edge(clock) then
			if conta = '1' then 
                if tempo = limite - 1 then 
				    tempo <= 0; 
				else           
				    tempo <= tempo + 1; 
                end if;
			else               
			    tempo <= tempo;
            end if;
        end if;
	end process;

    -- saida timeout
    timeout <= '1' when tempo = limite - 1 else
               '0';
    -- saida de depuracao
    db_contagem <= tempo;
end comportamental;
