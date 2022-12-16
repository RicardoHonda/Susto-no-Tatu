-----------------------------------------------------------------
-- Arquivo   : LFSR6.vhd
-- Projeto   : Tapa no tatu
-----------------------------------------------------------------
-- Descricao : gerador de códigos de 6 bits não nulos
-----------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/03/2022  1.0     Henrique Matheus  versao inicial
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LFSR6 is
  port (
    clk    : in  std_logic; 
    rst    : in  std_logic;
    en     : in  std_logic;
    output : out std_logic_vector (5 downto 0)
  );
end LFSR6;

architecture arch of LFSR6 is
  signal currstate, nextstate : std_logic_vector (5 downto 0);
  signal feedback             : std_logic;
begin

  StateReg: process (clk, rst)
  begin
    if (rst = '1') and nextstate = "000000" then
      currstate <= (0 => '1', others =>'0');
    elsif (clk = '1' and clk'EVENT and en='1') then
      currstate <= nextstate;
    end if;
  end process;
  
  feedback  <= currstate(4) xor currstate(3) xor currstate(2) xor currstate(0);
  nextstate <= feedback & currstate(5 downto 1);
  output    <= currstate;

end architecture;
