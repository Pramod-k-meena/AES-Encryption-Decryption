library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_write_fsm_tb is
end read_write_fsm_tb;

architecture Behavioral of read_write_fsm_tb is
    -- Component Declaration
    component read_write_fsm
        Port (
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            start : in  STD_LOGIC;
            round_number : in STD_LOGIC_VECTOR(3 downto 0);
            done : out STD_LOGIC;
            cipher_row1 : out STD_LOGIC_VECTOR (31 downto 0);
            cipher_row2 : out STD_LOGIC_VECTOR (31 downto 0);
            cipher_row3 : out STD_LOGIC_VECTOR (31 downto 0);
            cipher_row4 : out STD_LOGIC_VECTOR (31 downto 0);
            round_row1 : out STD_LOGIC_VECTOR (31 downto 0);
            round_row2 : out STD_LOGIC_VECTOR (31 downto 0);
            round_row3 : out STD_LOGIC_VECTOR (31 downto 0);
            round_row4 : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

    -- Signal declarations
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start : std_logic := '0';
    signal round_number : std_logic_vector(3 downto 0) := (others => '0');
    signal done : std_logic;
    signal cipher_row1, cipher_row2, cipher_row3, cipher_row4 : std_logic_vector(31 downto 0);
    signal round_row1, round_row2, round_row3, round_row4 : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: read_write_fsm 
    port map (
        clk => clk,
        rst => rst,
        start => start,
        round_number => round_number,
        done => done,
        cipher_row1 => cipher_row1,
        cipher_row2 => cipher_row2,
        cipher_row3 => cipher_row3,
        cipher_row4 => cipher_row4,
        round_row1 => round_row1,
        round_row2 => round_row2,
        round_row3 => round_row3,
        round_row4 => round_row4
    );

    -- Clock process
    process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    process
    begin
        -- Initial reset
        rst <= '1';
        wait for CLK_PERIOD * 5;
        
        -- Release reset
        rst <= '0';
        wait for CLK_PERIOD * 2;

        -- Test case 1: Round 0
        round_number <= "0000";
        wait for CLK_PERIOD;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD * 5;

         
        round_number <= "0001";
        wait for CLK_PERIOD;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD * 5;

        round_number <= "0010";
        wait for CLK_PERIOD;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD * 5;
        
        round_number <= "0011";
        wait for CLK_PERIOD;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD * 5;
        
        round_number <= "1010";
        wait for CLK_PERIOD;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD * 10;

        -- End simulation
        wait;
    end process;

end Behavioral;