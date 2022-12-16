library IEEE;
use IEEE.std_logic_1164.all;

entity exp4_sensor is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        trigger    : out std_logic;
        hex0       : out std_logic_vector(6 downto 0); -- digitos da medida
        hex1       : out std_logic_vector(6 downto 0);
        hex2       : out std_logic_vector(6 downto 0);
        pronto     : out std_logic;
        db_medir   : out std_logic;
        db_echo    : out std_logic;
        db_trigger : out std_logic;
        db_estado  : out std_logic_vector(6 downto 0) -- estado da UC
    );
   end entity exp4_sensor;

architecture rtl of exp4_sensor is

    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            medir     : in  std_logic;
            echo      : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0) -- estado da UC
        );
    end component interface_hcsr04;

    component hex7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    component edge_detector is
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component edge_detector;

    signal s_trigger, s_registra, s_pronto, s_medir : std_logic;
    signal s_db_estado                              : std_logic_vector(3 downto 0);
    signal s_medida                                 : std_logic_vector(11 downto 0);

begin

    HCSR04: interface_hcsr04 
        port map (
            clock      => clock,
            reset      => reset,
            medir      => s_medir,
            echo       => echo,
            trigger    => s_trigger,
            medida     => s_medida,
            pronto     => s_pronto,
            db_estado  => s_db_estado
        );

    EDGEDETECTOR: edge_detector
        port map(  
            clock     => clock,
            signal_in => medir,
            output    => s_medir
        );

    STATE_HEX: hex7seg
        port map (
            hexa => s_db_estado,
            sseg => db_estado
        );

    DIST_HEX0: hex7seg
        port map (
            hexa => s_medida(3 downto 0),
            sseg => hex0
        );

    DIST_HEX1: hex7seg
        port map (
            hexa => s_medida(7 downto 4),
            sseg => hex1
        );

    DIST_HEX2: hex7seg
        port map (
            hexa => s_medida(11 downto 8),
            sseg => hex2
        );

    db_medir   <= medir;
    db_trigger <= s_trigger;
    trigger    <= s_trigger;
    db_echo    <= echo;

end architecture rtl;
