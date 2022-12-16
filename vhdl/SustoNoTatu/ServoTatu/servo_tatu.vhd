library IEEE;
use IEEE.std_logic_1164.all;

entity servo_tatu is
    port (
        clock : in  std_logic;
        reset : in  std_logic;
        tatus : in  std_logic_vector(2 downto 0);
        pwm0  : out std_logic;
        pwm1  : out std_logic;
        pwm2  : out std_logic
    );
end entity servo_tatu;

architecture rtl of servo_tatu is

    component controle_servo is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            posicao    : in  std_logic;  
            pwm        : out std_logic
        );
    end component;

begin

    servo_0: controle_servo
        port map (
            clock   => clock,
            reset   => reset,
            posicao => tatus(0),  
            pwm     => pwm0
        );

    servo_1: controle_servo
        port map (
            clock   => clock,
            reset   => reset,
            posicao => tatus(1),  
            pwm     => pwm1
        );

    servo_2: controle_servo
        port map (
            clock   => clock,
            reset   => reset,
            posicao => tatus(2),  
            pwm     => pwm2
        );

end architecture rtl;
