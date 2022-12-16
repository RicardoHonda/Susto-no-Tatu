library ieee;
use ieee.std_logic_1164.all;

entity somador_10_bcd is
    port (
        val_in  : in  std_logic_vector(11 downto 0);
        val_out : out std_logic_vector(11 downto 0)
    );
end entity;

architecture comportamental of somador_10_bcd is
    signal dezena_in, centena_in, unidade_in    : std_logic_vector(3 downto 0);
    signal dezena_out, centena_out, unidade_out : std_logic_vector(3 downto 0);
    signal centena_9                            : std_logic_vector(3 downto 0);
begin
    process (dezena_in, centena_in, unidade_in, centena_9)
    begin
        case centena_in is
            when "0000" => centena_out <= "0001";  
            when "0001" => centena_out <= "0010";
            when "0010" => centena_out <= "0011";
            when "0011" => centena_out <= "0100";
            when "0100" => centena_out <= "0101";
            when "0101" => centena_out <= "0110";
            when "0110" => centena_out <= "0111";
            when "0111" => centena_out <= "1000";
            when "1000" => centena_out <= "1001";
            when "1001" => centena_out <= centena_9;
	        when others => centena_out <= "0000";
        end case;

        if(centena_in = "1001") then

            case dezena_in is
                when "0000" => dezena_out <= "0001";  
                when "0001" => dezena_out <= "0010";
                when "0010" => dezena_out <= "0011";
                when "0011" => dezena_out <= "0100";
                when "0100" => dezena_out <= "0101";
                when "0101" => dezena_out <= "0110";
                when "0110" => dezena_out <= "0111";
                when "0111" => dezena_out <= "1000";
                when "1000" => dezena_out <= "1001";
                when others => dezena_out <= "0000";
            end case;
        else
            dezena_out <= dezena_in;
        end if;

        if(centena_in = "1001" and dezena_in = "1001") then
            dezena_out <= dezena_in;
            unidade_out <= "1001";
        else
            unidade_out <= unidade_in;
        end if;
    end process;
    
    centena_9 <= "1001" when dezena_in = "1001" else "0000";

    unidade_in <= val_in(3 downto 0);
    centena_in <= val_in(7 downto 4);
    dezena_in  <= val_in(11 downto 8);

    val_out <= dezena_out & centena_out & unidade_out;

end architecture comportamental;