library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cyclic_display is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        digit_sel : out STD_LOGIC_VECTOR(3 downto 0);
        segments : out STD_LOGIC_VECTOR(6 downto 0)
    );
end cyclic_display;

architecture Behavioral of cyclic_display is
    -- Internal signals
    signal digit_count : unsigned(3 downto 0) := "0000";  -- 4-bit counter for 16 digits
    signal value_to_display : std_logic_vector(3 downto 0);
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');  -- Adjust this if necessary for faster testing
    
begin
    -- Counter process for digit selection
    process(clk, reset)
    begin
        if reset = '1' then
            digit_count <= "0000";
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
            if refresh_counter = 0 then  -- This refreshes the digit every time the counter overflows
                if digit_count = "1111" then
                    digit_count <= "0000";
                else
                    digit_count <= digit_count + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Digit selection and value assignment based on digit_count
    process(digit_count)
    begin
        case digit_count is
            when "0000" => digit_sel <= "1110"; value_to_display <= x"0";
            when "0001" => digit_sel <= "1101"; value_to_display <= x"1";
            when "0010" => digit_sel <= "1011"; value_to_display <= x"2";
            when "0011" => digit_sel <= "0111"; value_to_display <= x"3";
            when "0100" => digit_sel <= "1110"; value_to_display <= x"4";
            when "0101" => digit_sel <= "1101"; value_to_display <= x"5";
            when "0110" => digit_sel <= "1011"; value_to_display <= x"6";
            when "0111" => digit_sel <= "0111"; value_to_display <= x"7";
            when "1000" => digit_sel <= "1110"; value_to_display <= x"8";
            when "1001" => digit_sel <= "1101"; value_to_display <= x"9";
            when "1010" => digit_sel <= "1011"; value_to_display <= x"A";
            when "1011" => digit_sel <= "0111"; value_to_display <= x"B";
            when "1100" => digit_sel <= "1110"; value_to_display <= x"C";
            when "1101" => digit_sel <= "1101"; value_to_display <= x"D";
            when "1110" => digit_sel <= "1011"; value_to_display <= x"E";
            when "1111" => digit_sel <= "0111"; value_to_display <= x"F";
            when others => digit_sel <= "1111"; value_to_display <= x"0";
        end case;
    end process;
    
    -- Seven segment decoder for hexadecimal values
    process(value_to_display)
    begin
        case value_to_display is
            when x"0" => segments <= "1000000"; -- 0
            when x"1" => segments <= "1111001"; -- 1
            when x"2" => segments <= "0100100"; -- 2
            when x"3" => segments <= "0110000"; -- 3
            when x"4" => segments <= "0011001"; -- 4
            when x"5" => segments <= "0010010"; -- 5
            when x"6" => segments <= "0000010"; -- 6
            when x"7" => segments <= "1111000"; -- 7
            when x"8" => segments <= "0000000"; -- 8
            when x"9" => segments <= "0010000"; -- 9
            when x"A" => segments <= "0001000"; -- A
            when x"B" => segments <= "0000011"; -- B
            when x"C" => segments <= "1000110"; -- C
            when x"D" => segments <= "0100001"; -- D
            when x"E" => segments <= "0000110"; -- E
            when x"F" => segments <= "0001110"; -- F
            when others => segments <= "1111111";
        end case;
    end process;
    
end Behavioral;
