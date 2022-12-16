--------------------------------------------------------------------
-- Arquivo   : tx.vhd
-- Projeto   : Tapa no Tatu
--------------------------------------------------------------------
-- Descricao : Saída serial de 8 bits
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx is
	generic (baudrate     : integer := 9600);
	port (
		clock		: in  std_logic;							
		reset		: in  std_logic;							
		partida  	: in  std_logic;							
		dado		: in  std_logic_vector(7 downto 0);	
		sout		: out std_logic;							
		out_dado	: out std_logic_vector(7 downto 0);	
		pronto		: out std_logic							
	);
end tx;

architecture exemplo of tx is 
	signal clockdiv  : std_logic;
	signal IQ		 : unsigned(25 downto 0);
	signal buff		 : std_logic_vector(7 downto 0);
	
	type tipo_estado is (inicial, carrega, d0, d1, d2, d3, d4, d5, d6, d7, s0, s1, final);
	signal estado   : tipo_estado;

begin 
	
	-- ===========================
	-- Divisor de clock
	-- ===========================
	process(clock, reset, IQ, clockdiv)
	begin
		if reset = '1' then
			IQ <= (others => '0');
		elsif clock'event and clock = '1' then
			if IQ = 50000000/(baudrate*2) then
				clockdiv <= not(clockdiv);
				IQ <= (others => '0');
			else
				IQ <= IQ + 1;
			end if;
		end if;
	end process;
	
	-- ===========================
	-- Maquina de Estados do Transmissor
	-- ===========================
	process(clockdiv, reset, partida, estado)
	begin
		if reset = '1' then
			estado <= inicial;
			
		elsif clockdiv'event and clockdiv = '1' then
			case estado is
				when inicial =>
					if partida = '1' then
						estado <= carrega;
					else
						estado <= inicial;
					end if;
				
				when carrega =>
					buff <= dado;
					--buff <= "10101010";
					estado <= d0;
				
				when d0 => estado <= d1;
				when d1 => estado <= d2;
				when d2 => estado <= d3;
				when d3 => estado <= d4;
				when d4 => estado <= d5;
				when d5 => estado <= d6;
				when d6 => estado <= d7;
				when d7 => estado <= s0;
				when s0 => estado <= s1;
				when s1 => estado <= final;
				
				when final =>
					if partida = '0' then
						estado <= inicial;
					else
						estado <= final;
					end if;
				
			end case;
		end if;
	end process;

	-- ===========================
	-- Logica de saida
	-- ===========================
	with estado select sout <=
		--'0'      when carrega,
		'0'      when carrega,
		buff(0)  when d0,
		buff(1)  when d1,
		buff(2)  when d2,
		buff(3)  when d3,
		buff(4)  when d4,
		buff(5)  when d5,
		buff(6)  when d6,
		buff(7)  when d7,
		'1'      when others;
		
	with estado select pronto <=
		'1' when final,
		'0' when others;
			
	out_dado <= dado;
	
end exemplo;
