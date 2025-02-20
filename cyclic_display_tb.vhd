library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cyclic_display is
end tb_cyclic_display;

architecture Behavioral of tb_cyclic_display is
    -- Testbench signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal digit_sel : std_logic_vector(3 downto 0);
    signal segments : std_logic_vector(6 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- 128-bit data to display
    signal data_128bit : std_logic_vector(127 downto 0) := x"1234ABCD56789E0F1234ABCD56789E0F";
    
    -- Signals to hold expected values for verification
    signal display_digit : std_logic_vector(3 downto 0);
    
begin
    -- Instantiate the cyclic_display module
    uut: entity work.cyclic_display
        port map (
            clk => clk,
            reset => reset,
            digit_sel => digit_sel,
            segments => segments
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process to test the cyclic display functionality
    stim_proc: process
    begin
        -- Reset the circuit
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';
        
        -- Loop over the 128 bits (16 digits) and display 4 at a time
        for i in 0 to 12 loop  -- 16 digits / 4 = 4 shifts; loop until all 16 digits are displayed
            wait until rising_edge(clk);
            -- Check that the correct 4 digits are shown on each 7-segment display cycle
            for j in 0 to 3 loop
                display_digit <= data_128bit(127 - (4 * i + j) * 4 downto 124 - (4 * i + j) * 4);
                wait for clk_period;
            end loop;
        end loop;
        
        -- End simulation
        wait;
    end process;
    
end Behavioral;
