library ieee;
use ieee.std_logic_1164.all;

entity comparador_distancia is
    port (
        A        : in std_logic_vector(11 downto 0);
        B        : in std_logic_vector(11 downto 0);
        add_2    : in std_logic;
        is_close : out std_logic -- A está proximo de B com intervalo de erro
    );
end entity comparador_distancia;

architecture dataflow of comparador_distancia is

    component comparador_85 is
        port (
            A      : in  std_logic_vector(3 downto 0);
            B      : in  std_logic_vector(3 downto 0);
            i_AGTB : in  std_logic;
            i_ALTB : in  std_logic;
            i_AEQB : in  std_logic;
            o_AGTB : out std_logic;
            o_ALTB : out std_logic;
            o_AEQB : out std_logic
        );
    end component;

    component somador_10_bcd is
        port (
            val_in  : in  std_logic_vector(11 downto 0);
            val_out : out std_logic_vector(11 downto 0)
        );
    end component;

    component subtrator_10_bcd is
        port (
            val_in  : in  std_logic_vector(11 downto 0);
            val_out : out std_logic_vector(11 downto 0)
        );
    end component;

    signal AGTB_2, ALTB_2, AEQB_2, AGTB_1, ALTB_1, AEQB_1, AGTB_0, ALTB_0, AEQB_0 : std_logic;
    signal AGTC_2, ALTC_2, AEQC_2, AGTC_1, ALTC_1, AEQC_1, AGTC_0, ALTC_0, AEQC_0 : std_logic;
    signal B_more_1, B_more_2, B_minus_1, B_minus_2, B_min, B_max                 : std_logic_vector(11 downto 0);

begin

    somador1: somador_10_bcd
        port map (
            val_in  => B,
            val_out => B_more_1
        );

    somador2: somador_10_bcd
        port map (
            val_in  => B_more_1,
            val_out => B_more_2
        );

    B_max <= B_more_2 when add_2='1' else B_more_1;

    subtrator1: subtrator_10_bcd
        port map (
            val_in  => B,
            val_out => B_minus_1
        );

    subtrator2: subtrator_10_bcd
        port map (
            val_in  => B_minus_1,
            val_out => B_minus_2
        );

    B_min <= B_minus_2 when add_2='1' else B_minus_1;

    COMPARADOR_B_0: comparador_85
        port map (
            A      => A(3 downto 0),
            B      => B_min(3 downto 0),
            i_AGTB => '0',
            i_ALTB => '0',
            i_AEQB => '0',
            o_AGTB => AGTB_0,
            o_ALTB => ALTB_0,
            o_AEQB => AEQB_0
        );
      
    COMPARADOR_B_1: comparador_85
        port map (
            A      => A(7 downto 4),
            B      => B_min(7 downto 4),
            i_AGTB => AGTB_0,
            i_ALTB => ALTB_0,
            i_AEQB => AEQB_0,
            o_AGTB => AGTB_1,
            o_ALTB => ALTB_1,
            o_AEQB => AEQB_1
        );
      
    COMPARADOR_B_2: comparador_85
        port map (
            A      => A(11 downto 8),
            B      => B_min(11 downto 8),
            i_AGTB => AGTB_1,
            i_ALTB => ALTB_1,
            i_AEQB => AEQB_1,
            o_AGTB => AGTB_2,
            o_ALTB => open,
            o_AEQB => AEQB_2
        );

    COMPARADOR_C_2: comparador_85
        port map (
            A      => A(11 downto 8),
            B      => B_max(11 downto 8),
            i_AGTB => AGTC_1,
            i_ALTB => ALTC_1,
            i_AEQB => AEQC_1,
            o_AGTB => open,
            o_ALTB => ALTC_2,
            o_AEQB => AEQC_2
        );

    COMPARADOR_C_1: comparador_85
        port map (
            A      => A(7 downto 4),
            B      => B_max(7 downto 4),
            i_AGTB => AGTC_0,
            i_ALTB => ALTC_0,
            i_AEQB => AEQC_0,
            o_AGTB => AGTC_1,
            o_ALTB => ALTC_1,
            o_AEQB => AEQC_1
        );

    COMPARADOR_C_0: comparador_85
        port map (
            A      => A(3 downto 0),
            B      => B_max(3 downto 0),
            i_AGTB => '0',
            i_ALTB => '0',
            i_AEQB => '0',
            o_AGTB => AGTC_0,
            o_ALTB => ALTC_0,
            o_AEQB => AEQC_0
        );

    -- Para A estar entre B e C (B<C), ele deve ser maior ou igual a B e menor ou igual a C
    is_close <= (AGTB_2 or AEQB_2) and (ALTC_2 or AEQC_2);
  
end architecture dataflow;
