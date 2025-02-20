library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aes_decrypt_fsm_tb is
end aes_decrypt_fsm_tb;

architecture Behavioral of aes_decrypt_fsm_tb is
    -- Component declaration
    component aes_decrypt_fsm
        Port (
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            start : in  STD_LOGIC;
            ciphertext : in  STD_LOGIC_VECTOR(127 downto 0);
            roundkey : in  STD_LOGIC_VECTOR(127 downto 0);
            done : out STD_LOGIC;
            plaintext : out STD_LOGIC_VECTOR(127 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk_tb : STD_LOGIC := '0';
    signal rst_tb : STD_LOGIC := '0';
    signal start_tb : STD_LOGIC := '0';
    signal ciphertext_tb : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal roundkey_tb : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal done_tb : STD_LOGIC := '0';
    signal plaintext_tb : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the AES decryption FSM
    uut: aes_decrypt_fsm
        Port map (
            clk => clk_tb,
            rst => rst_tb,
            start => start_tb,
            ciphertext => ciphertext_tb,
            roundkey => roundkey_tb,
            done => done_tb,
            plaintext => plaintext_tb
        );

    -- Clock generation process
    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize the reset
        rst_tb <= '1';
        wait for clk_period;
        rst_tb <= '0';
        
        -- Set ciphertext and round key for decryption
        ciphertext_tb <= x"69C4E0D86A7B0430D8CDB78070B4C55A";  -- Example ciphertext
        roundkey_tb <= x"000102030405060708090A0B0C0D0E0F";  -- Example round key

        -- Start decryption
        wait for clk_period;
        start_tb <= '1';
        wait for clk_period;
        start_tb <= '0';

        -- Wait for decryption to complete
        wait until done_tb = '1';
        
        -- Check the output plaintext
            
        -- Finish simulation
        wait;
    end process;
end Behavioral;
