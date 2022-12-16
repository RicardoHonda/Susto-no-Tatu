--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Tapa no Tatu
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2022  1.0     Henrique Matheus  versao inicial
--     25/03/2022  2.0     Eduardo Hiroshi   versao adaptada
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
    port ( 
        clock                  : in  std_logic; 
        reset                  : in  std_logic; 
        iniciar                : in  std_logic;
        EscolheuDificuldade    : in  std_logic;
        timeout                : in  std_logic;
        fezJogada              : in  std_logic;
        temVida                : in  std_logic;
		zeraVida               : out std_logic;
        jogadaValida           : in  std_logic;
        temTatu                : in  std_logic;
        timeOutDelTMR          : in  std_logic;
        end_points             : in  std_logic;
        prontoTX               : in  std_logic;
        fimJogo                : out std_logic; 
        zeraR                  : out std_logic; 
        registraR              : out std_logic; 
        limpaR                 : out std_logic; 
        registraM              : out std_logic; 
        limpaM                 : out std_logic; 
        zeraJogTMR             : out std_logic; 
        contaJogTMR            : out std_logic;
        zeraDelTMR             : out std_logic; 
        contaDelTMR            : out std_logic;
        loadSub                : out std_logic;
        contaSub               : out std_logic;
        en_FLSR                : out std_logic;
        emJogo                 : out std_logic;
        contaPonto             : out std_logic;
        contaVida              : out std_logic;
        db_estado              : out std_logic_vector(4 downto 0);
        en_Reg                 : out std_logic;
		anulaTatus             : out std_logic;
		enTX                   : out std_logic;
		whichTX                : out std_logic;
		apagaTatu              : out std_logic;
		-- TMR Sperano
        contaSprTMR            : out std_logic;
        zeraSprTMR             : out std_logic;
        fimSprTMR              : in  std_logic;
        limpa_pontos           : out std_logic
    );
end entity;

architecture fsm of unidade_controle is
    -- Declaração dos estados
    type t_estado is (inicial,
                      esperaDificuldade,
                      preparacaoGeral,
                      geraJogada,
                      mostraJogada,
                      reduzVida,
                      fimDoJogo,
                      registraJogada,
                      avaliaJogada,
                      somaPontuacao,
                      removeTatu,
                      reduzTempo,
                      mostraApagado,
                      verificaVida,
                      enviaJogada,
					  enviaApagado,
					  sperano,
					  sperano2,
                      enviaPontos);
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset) -- Processo sensível à mudança do clock e reset
    begin
        if reset='1' then -- Reset possui preferência sobre o clock e é ativo alto
            Eatual <= inicial;
        elsif clock'event and clock = '1' then -- Ocorre na borda de subida do clock
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    -- Aqui foram adicionadas as transicoes entre os novos estados
    Eprox <=
        -- Transições de origem nos estados gerais
        inicial           when Eatual=inicial           and iniciar='0'             else
        preparacaoGeral   when Eatual=inicial           and iniciar='1'             else
        geraJogada        when Eatual=preparacaoGeral                               else
        
        enviaJogada       when Eatual=geraJogada                                    else
        enviaJogada       when Eatual=enviaJogada       and ProntoTX='0'            else
        mostraJogada      when Eatual=enviaJogada       and ProntoTX='1'            else 
          
        mostraJogada      when Eatual=mostraJogada      and timeout='0'
                                                        and fezJogada='0'           else
        registraJogada    when Eatual=mostraJogada      and fezJogada='1'           else
        reduzVida         when Eatual=mostraJogada      and timeout='1'             else
        verificaVida      when Eatual=reduzVida                                     else
        fimDoJogo         when Eatual=verificaVida      and temVida='0'             else 
        fimDoJogo         when Eatual=fimDoJogo         and iniciar='0'             else 
        preparacaoGeral   when Eatual=fimDoJogo         and iniciar='1'             else 
            
        -- Transições jogadas
        avaliaJogada   when Eatual=registraJogada                       else
        reduzVida      when Eatual=avaliaJogada   and jogadaValida='0'  else
        somaPontuacao  when Eatual=removeTatu                           else
        reduzTempo     when Eatual=verificaVida   and temVida='1'       else
        removeTatu     when Eatual=avaliaJogada   and jogadaValida='1'  else
        enviaPontos    when Eatual=somaPontuacao  and end_points = '0'  else                                                                  
        fimDoJogo      when Eatual=somaPontuacao  and end_points = '1'  else
        sperano2       when Eatual=reduzTempo                           else
		  
		enviaApagado   when Eatual=enviaApagado   and prontoTX='0'      else
		mostraApagado  when Eatual=enviaApagado   and prontoTX='1'      else
		  
        mostraApagado  when Eatual=mostraApagado  and timeOutDelTMR='0' else
        geraJogada     when Eatual=mostraApagado  and timeOutDelTMR='1' else
		  
        sperano        when Eatual=enviaPontos    and temTatu='1'       
                                                  and prontoTX='1'      else
        reduzTempo     when Eatual=enviaPontos    and temTatu='0'
                                                  and prontoTX='1'      else
        enviaPontos    when Eatual=enviaPontos    and prontoTX='0'      else
		  
		enviaJogada    when Eatual=sperano        and fimSprTMR='1'     else
		sperano        when Eatual=sperano        and fimSprTMR='0'     else
		  
		enviaApagado   when Eatual=sperano2       and fimSprTMR='1'     else
		sperano2       when Eatual=sperano2       and fimSprTMR='0'     else
        
        -- Estado padrão
        inicial;

    -- logica de saída (maquina de Moore)
    -- As saídas correspondentes recebem 1 nos estados declarados, e 0 caso contrário
    with Eatual select
        limpaR     <= '1' when preparacaoGeral,
                      '0' when others;
    with Eatual select
        limpaM     <= '1' when preparacaoGeral | reduzTempo,
                      '0' when others;

    with Eatual select
        zeraJogTMR <= '1' when geraJogada,
                      '0' when others;

    with Eatual select
        registraM  <= '1' when geraJogada | removeTatu,
                      '0' when others;

    with Eatual select
        contaJogTMR <= '1' when mostraJogada,
                       '0' when others;

    with Eatual select
        fimJogo  <= '1' when fimDoJogo,
                    '0' when others;

    with Eatual select
        registraR  <= '1' when registraJogada,
                      '0' when others;

    with Eatual select
        zeraDelTMR <= '1' when reduzTempo | enviaPontos,
                      '0' when others;

    with Eatual select
        contaDelTMR <= '1' when mostraApagado | sperano,
                       '0' when others;

    with Eatual select
        loadSub <= '1' when preparacaoGeral,
                   '0' when others;

    with Eatual select
        contaSub <= '1' when reduzTempo,
                    '0' when others;
    
    with Eatual select
        en_FLSR <= '1' when geraJogada,
                   '0' when others;

    with Eatual select
        emJogo <= '1' when geraJogada | mostraJogada | registraJogada | avaliaJogada | somaPontuacao | 
                           removeTatu | reduzTempo | mostraApagado | reduzVida | verificaVida | enviaJogada | 
                           sperano | enviaPontos |  sperano2,
                  '0' when others;

    with Eatual select
        contaPonto <= '1' when somaPontuacao,
                      '0' when others;
    
    with Eatual select
        contaVida <= '1' when reduzVida,
                     '0' when others;
                            
    with Eatual select
        en_Reg <= '1' when removeTatu,
                  '0' when others;
    
    with Eatual select
        enTX <= '1' when enviaJogada | enviaPontos | enviaApagado,
                '0' when others;
    
	with Eatual select
        whichTX <= '1' when enviaJogada | enviaApagado,
                   '0' when others;
	 
	 with Eatual select
        zeraVida <= '1' when preparacaoGeral | inicial,
                    '0' when others;
    
	 with Eatual select
        apagaTatu <= '1' when enviaApagado | reduzTempo,
                     '0' when others;
			 
	 with Eatual select
        contaSprTMR <= '1' when sperano | sperano2,
                       '0' when others;
						  
    with Eatual select
        zeraSprTMR <= '1' when enviaPontos | reduzTempo,
                      '0' when others;
						  
	 with Eatual select
        limpa_pontos <= '1' when preparacaoGeral | inicial,
                        '0' when others;
								
	 with Eatual select
        anulaTatus <= '1' when inicial,
                        '0' when others;

    -- Saída de depuração (db_estado)
    with Eatual select
        db_estado <= "00000" when inicial,           -- 00
                     "00010" when esperaDificuldade, -- 02
                     "00100" when preparacaoGeral,   -- 04
                     "00110" when geraJogada,        -- 06
					 "01000" when enviaJogada,       -- 08
                     "01010" when mostraJogada,      -- 0A
                     "01100" when reduzVida,         -- 0C
                     "01110" when fimDoJogo,         -- 0E
                     "10000" when registraJogada,    -- 10
                     "10010" when avaliaJogada,      -- 12
                     "10100" when somaPontuacao,     -- 14
                     "10110" when removeTatu,        -- 16
                     "11000" when reduzTempo,        -- 18
                     "11010" when mostraApagado,     -- 1A
					 "11011" when enviaPontos,       -- 1B 
                     "11100" when others;            -- 1C (verificaVida)
end fsm;
