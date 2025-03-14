
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Inverse Shift Rows Component
entity inv_shift_rows_transform is
    Port (
        input : in  STD_LOGIC_VECTOR (31 downto 0);
        output : out  STD_LOGIC_VECTOR (31 downto 0);
        in_row_number : in integer
    );
end inv_shift_rows_transform;

architecture Behavioral of inv_shift_rows_transform is
begin
    process(input, in_row_number)
    begin
        if in_row_number =integer(0) then
            output(31 downto 0) <= input(31 downto 0);
        elsif in_row_number = integer(1) then
            output(31 downto 24) <= input(7 downto 0);
            output(23 downto 0) <= input(31 downto 8);
        elsif in_row_number = integer(2) then
            output(31 downto 16) <= input(15 downto 0);
            output(15 downto 0) <= input(31 downto 16);
        else
            output(31 downto 8) <= input(23 downto 0);
            output(7 downto 0) <= input(31 downto 24);
        end if;
    end process;
end Behavioral;

-- Add Round Key Component
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity add_round is
    Port ( 
        state : in  STD_LOGIC_VECTOR (31 downto 0);
        round_key : in  STD_LOGIC_VECTOR (31 downto 0);
        result : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end add_round;

architecture Behavioral of add_round is
begin
    result(31 downto 24) <= state(31 downto 24) xor round_key(31 downto 24);
    result(23 downto 16) <= state(23 downto 16) xor round_key(23 downto 16);
    result(15 downto 8)  <= state(15 downto 8)  xor round_key(15 downto 8);
    result(7 downto 0)   <= state(7 downto 0)   xor round_key(7 downto 0);
end Behavioral;

---- Block Memory Generator Component for S-box
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--entity blk_mem_gen_box is
--    Port ( 
--        addra : in STD_LOGIC_VECTOR(7 downto 0);
--        douta : out STD_LOGIC_VECTOR(7 downto 0);
--        clka : in STD_LOGIC
--    );
--end blk_mem_gen_box;

--architecture Behavioral of blk_mem_gen_box is
--begin
--    -- Implementation would typically be generated by Block Memory Generator
--    -- This is a placeholder for the actual implementation
--end Behavioral;

---- Inverse SubBytes Component
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity inverse_subbytes_parallel is
--    Port ( 
--        clk : in STD_LOGIC;
--        state_in : in STD_LOGIC_VECTOR(31 downto 0);
--        state_out : out STD_LOGIC_VECTOR(31 downto 0)
--    );
--end inverse_subbytes_parallel;

--architecture Behavioral of inverse_subbytes_parallel is
----    component blk_mem_gen_box
----        port (
----            addra : in STD_LOGIC_VECTOR(7 downto 0);
----            douta : out STD_LOGIC_VECTOR(7 downto 0);
----            clka : in STD_LOGIC
----        );
----    end component;
    
--    signal state_out_reg : STD_LOGIC_VECTOR(31 downto 0);
--begin
--    state_out_reg<=state_in;
----    GEN_SBOX: for i in 0 to 3 generate
----        SBOX_INST: blk_mem_gen_box
----        port map(
----            addra => state_in((i*8 + 7) downto (i*8)),
----            douta => state_out_reg((i*8 + 7) downto (i*8)),
----            clka => clk
----        );
----    end generate;
    
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            state_out <= state_out_reg;
--        end if;
--    end process;
--end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity inverse_subbytes_parallel is
    Port ( 
        clk : in STD_LOGIC;
        state_in : in STD_LOGIC_VECTOR(31 downto 0);
        state_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end inverse_subbytes_parallel;

architecture Behavioral of inverse_subbytes_parallel is
    type inv_sbox_array is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    constant INV_SBOX : inv_sbox_array := (
        X"52", X"09", X"6a", X"d5", X"30", X"36", X"a5", X"38", X"bf", X"40", X"a3", X"9e", X"81", X"f3", X"d7", X"fb",
        X"7c", X"e3", X"39", X"82", X"9b", X"2f", X"ff", X"87", X"34", X"8e", X"43", X"44", X"c4", X"de", X"e9", X"cb",
        X"54", X"7b", X"94", X"32", X"a6", X"c2", X"23", X"3d", X"ee", X"4c", X"95", X"0b", X"42", X"fa", X"c3", X"4e",
        X"08", X"2e", X"a1", X"66", X"28", X"d9", X"24", X"b2", X"76", X"5b", X"a2", X"49", X"6d", X"8b", X"d1", X"25",
        X"72", X"f8", X"f6", X"64", X"86", X"68", X"98", X"16", X"d4", X"a4", X"5c", X"cc", X"5d", X"65", X"b6", X"92",
        X"6c", X"70", X"48", X"50", X"fd", X"ed", X"b9", X"da", X"5e", X"15", X"46", X"57", X"a7", X"8d", X"9d", X"84",
        X"90", X"d8", X"ab", X"00", X"8c", X"bc", X"d3", X"0a", X"f7", X"e4", X"58", X"05", X"b8", X"b3", X"45", X"06",
        X"d0", X"2c", X"1e", X"8f", X"ca", X"3f", X"0f", X"02", X"c1", X"af", X"bd", X"03", X"01", X"13", X"8a", X"6b",
        X"3a", X"91", X"11", X"41", X"4f", X"67", X"dc", X"ea", X"97", X"f2", X"cf", X"ce", X"f0", X"b4", X"e6", X"73",
        X"96", X"ac", X"74", X"22", X"e7", X"ad", X"35", X"85", X"e2", X"f9", X"37", X"e8", X"1c", X"75", X"df", X"6e",
        X"47", X"f1", X"1a", X"71", X"1d", X"29", X"c5", X"89", X"6f", X"b7", X"62", X"0e", X"aa", X"18", X"be", X"1b",
        X"fc", X"56", X"3e", X"4b", X"c6", X"d2", X"79", X"20", X"9a", X"db", X"c0", X"fe", X"78", X"cd", X"5a", X"f4",
        X"1f", X"dd", X"a8", X"33", X"88", X"07", X"c7", X"31", X"b1", X"12", X"10", X"59", X"27", X"80", X"ec", X"5f",
        X"60", X"51", X"7f", X"a9", X"19", X"b5", X"4a", X"0d", X"2d", X"e5", X"7a", X"9f", X"93", X"c9", X"9c", X"ef",
        X"a0", X"e0", X"3b", X"4d", X"ae", X"2a", X"f5", X"b0", X"c8", X"eb", X"bb", X"3c", X"83", X"53", X"99", X"61",
        X"17", X"2b", X"04", X"7e", X"ba", X"77", X"d6", X"26", X"e1", X"69", X"14", X"63", X"55", X"21", X"0c", X"7d"
    );
    
    signal state_out_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal byte0, byte1, byte2, byte3 : STD_LOGIC_VECTOR(7 downto 0);

begin
    -- Combinational logic for inverse S-box lookup
    byte0 <= INV_SBOX(to_integer(unsigned(state_in(7 downto 0))));
    byte1 <= INV_SBOX(to_integer(unsigned(state_in(15 downto 8))));
    byte2 <= INV_SBOX(to_integer(unsigned(state_in(23 downto 16))));
    byte3 <= INV_SBOX(to_integer(unsigned(state_in(31 downto 24))));
    
    -- Register the output
    process(clk)
    begin
        if rising_edge(clk) then
            state_out_reg <= byte3 & byte2 & byte1 & byte0;
            state_out <= state_out_reg;
        end if;
    end process;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity inv_mix_columns_transform is
    Port (
        input : in  STD_LOGIC_VECTOR (31 downto 0);
        output : out STD_LOGIC_VECTOR (31 downto 0)
    );
end inv_mix_columns_transform;

architecture Behavioral of inv_mix_columns_transform is
    -- Constants for inverse mix columns matrix
    constant INV_MIX_COL_MATRIX : std_logic_vector(127 downto 0) := 
        x"0E0B0D09" &  -- First row
        x"090E0B0D" &  -- Second row
        x"0D090E0B" &  -- Third row
        x"0B0D090E";   -- Fourth row
        
    type matrix_4x1 is array (0 to 3) of std_logic_vector(7 downto 0);
    
    function to_matrix(vec: std_logic_vector(31 downto 0)) return matrix_4x1 is
        variable matrix: matrix_4x1;
    begin
        for i in 0 to 3 loop
            matrix(i) := vec(31-8*i downto 24-8*i);
        end loop;
        return matrix;
    end function;
    
    function to_vector(matrix: matrix_4x1) return std_logic_vector is
        variable vec: std_logic_vector(31 downto 0);
    begin
        for i in 0 to 3 loop
            vec(31-8*i downto 24-8*i) := matrix(i);
        end loop;
        return vec;
    end function;
    
    function gf_mult(a, b: std_logic_vector(7 downto 0)) return std_logic_vector is
        variable p: std_logic_vector(7 downto 0) := (others => '0');
        variable hi_bit_set: std_logic;
        variable temp_a: std_logic_vector(7 downto 0);
    begin
        temp_a := a;
        for i in 0 to 7 loop
            if (b(i) = '1') then
                p := p xor temp_a;
            end if;
            hi_bit_set := temp_a(7);
            temp_a := temp_a(6 downto 0) & '0';
            if (hi_bit_set = '1') then
                temp_a := temp_a xor x"1B";  -- Irreducible polynomial for AES
            end if;
        end loop;
        return p;
    end function;

begin
    process(input)
        variable state_matrix, result: matrix_4x1;
        variable temp: std_logic_vector(7 downto 0);
        variable inv_mix_col_row: std_logic_vector(31 downto 0);
    begin
        state_matrix := to_matrix(input);
        
        for i in 0 to 3 loop
            -- Get the corresponding row from inverse mix columns matrix
            inv_mix_col_row := INV_MIX_COL_MATRIX(127-32*i downto 96-32*i);
            
            -- Calculate output for each row
            temp := gf_mult(inv_mix_col_row(31 downto 24), state_matrix(0)) xor
                   gf_mult(inv_mix_col_row(23 downto 16), state_matrix(1)) xor
                   gf_mult(inv_mix_col_row(15 downto 8), state_matrix(2)) xor
                   gf_mult(inv_mix_col_row(7 downto 0), state_matrix(3));
            result(i) := temp;
        end loop;
        
        output <= to_vector(result);
    end process;
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity aes_decrypt_fsm is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        start : in  STD_LOGIC;
        ciphertext : in  STD_LOGIC_VECTOR(127 downto 0);
        roundkey : in  STD_LOGIC_VECTOR(127 downto 0);
        done : out STD_LOGIC;
        plaintext : out STD_LOGIC_VECTOR(127 downto 0)
    );
end aes_decrypt_fsm;

architecture Behavioral of aes_decrypt_fsm is
    type state_type is (IDLE,LOAD_DATA,WAIT_DATA, FIRST_ROUND, INV_SHIFT_ROWS, INV_SUB_BYTES, 
                       ADD_ROUND_KEY, INV_MIX_COLUMNS, CHECK_ROUND, FINAL);
    signal current_state, next_state : state_type;
    -- Control signals
    signal round_count : unsigned(3 downto 0) := (others => '0');
    signal row_counter : unsigned(1 downto 0) := (others => '0');
    signal col_counter : unsigned(1 downto 0) := (others => '0');
    signal operation_done : std_logic := '0';
    signal wait_count : integer range 0 to 2 := 0;
    signal row0, row1, row2, row3 : STD_LOGIC_VECTOR(31 downto 0);
    signal col0, col1, col2, col3 : STD_LOGIC_VECTOR(31 downto 0);
    type inv_mix_cols_state_type is (LOAD_COLS, PROCESS_COLS, STORE_ROWS,ASSIGN_ROWS);
    signal inv_mix_cols_state : inv_mix_cols_state_type := LOAD_COLS;
    -- State registers for rows (renamed for consistency)
    signal state_row0, state_row1, state_row2, state_row3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal that_done : std_logic;
    -- State registers for columns (renamed for consistency)
    signal state_col0, state_col1, state_col2, state_col3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    -- Operation output registers
    signal inv_shift_rows_out0, inv_shift_rows_out1, inv_shift_rows_out2, inv_shift_rows_out3 : STD_LOGIC_VECTOR(31 downto 0);
    signal inv_sub_bytes_out0, inv_sub_bytes_out1, inv_sub_bytes_out2, inv_sub_bytes_out3 : STD_LOGIC_VECTOR(31 downto 0);
    signal add_round_out0, add_round_out1, add_round_out2, add_round_out3,add_round_out4,add_round_out5,add_round_out6,add_round_out7 : STD_LOGIC_VECTOR(31 downto 0);
    signal inv_mix_cols_out0, inv_mix_cols_out1, inv_mix_cols_out2, inv_mix_cols_out3 : STD_LOGIC_VECTOR(31 downto 0);
    signal a,b,c,d:std_logic_vector(31 downto 0);
    -- Mix columns constant matrix
--    constant mix_matrix_col0 : STD_LOGIC_VECTOR(31 downto 0) := x"0E0B0D09";
--    constant mix_matrix_col1 : STD_LOGIC_VECTOR(31 downto 0) := x"090E0B0D";
--    constant mix_matrix_col2 : STD_LOGIC_VECTOR(31 downto 0) := x"0D090E0B";
--    constant mix_matrix_col3 : STD_LOGIC_VECTOR(31 downto 0) := x"0B0D090E";

    -- Component declarations
    component aes_decryption_fsm is
        Port ( 
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            start : in STD_LOGIC;
            round_number : in STD_LOGIC_VECTOR(3 downto 0);
            done : out STD_LOGIC;
            cipher_row1 : out STD_LOGIC_VECTOR(31 downto 0);
            cipher_row2 : out STD_LOGIC_VECTOR(31 downto 0);
            cipher_row3 : out STD_LOGIC_VECTOR(31 downto 0);
            cipher_row4 : out STD_LOGIC_VECTOR(31 downto 0);
            round_row1 : out STD_LOGIC_VECTOR(31 downto 0);
            round_row2 : out STD_LOGIC_VECTOR(31 downto 0);
            round_row3 : out STD_LOGIC_VECTOR(31 downto 0);
            round_row4 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    
    component inv_shift_rows_transform is
        Port ( 
            input : in  STD_LOGIC_VECTOR(31 downto 0);
            output : out STD_LOGIC_VECTOR(31 downto 0);
            in_row_number : in integer
        );
    end component;
    
    component inverse_subbytes_parallel is
        Port ( 
            clk : in STD_LOGIC;
            state_in : in STD_LOGIC_VECTOR(31 downto 0);
            state_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component add_round is
        Port ( 
            state : in STD_LOGIC_VECTOR(31 downto 0);
            round_key : in STD_LOGIC_VECTOR(31 downto 0);
            result : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component inv_mix_columns_transform is
        Port ( 
            input : in STD_LOGIC_VECTOR(31 downto 0);
--            mix_matrix : in STD_LOGIC_VECTOR(31 downto 0);
            output : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

begin
    
    -- Component instantiations
    inv_shift_rows_inst0: inv_shift_rows_transform 
        port map (
            input => state_row0,
            output => inv_shift_rows_out0,
            in_row_number => integer(0)
        );
        
    inv_sub_bytes_inst0: inverse_subbytes_parallel 
        port map (
            clk => clk,
            state_in => inv_shift_rows_out0,
            state_out => inv_sub_bytes_out0
        );
        
    add_round_inst0: add_round 
        port map (
            state => inv_sub_bytes_out0,
            round_key => roundkey(127 downto 96),
            result => add_round_out0
        );
        
    inv_mix_cols_inst0: inv_mix_columns_transform 
        port map (
            input => state_col0,
--            mix_matrix => mix_matrix_col0,
            output => inv_mix_cols_out0
        );

    -- Column 1
    inv_shift_rows_inst1: inv_shift_rows_transform 
        port map (
            input => state_row1,
            output => inv_shift_rows_out1,
            in_row_number => integer(1)
        );
    aes_decryption_fsm_inst: aes_decryption_fsm
        port map (
            clk => clk,
            rst => rst,
            start => start,
            round_number => round_count,
            done => done,
            cipher_row1 => state_row0,
            cipher_row2 => state_row1,
            cipher_row3 => state_row2,
            cipher_row4 => state_row3,
            round_row1 => add_round_out0,
            round_row2 => add_round_out1,
            round_row3 => add_round_out2,
            round_row4 => add_round_out3
        );
    inv_sub_bytes_inst1: inverse_subbytes_parallel 
        port map (
            clk => clk,
            state_in => inv_shift_rows_out1,
            state_out => inv_sub_bytes_out1
        );
        
    add_round_inst1: add_round 
        port map (
            state => inv_sub_bytes_out1,
            round_key => roundkey(95 downto 64),
            result => add_round_out1
        );
        
    inv_mix_cols_inst1: inv_mix_columns_transform 
        port map (
            input => state_col1,
--            mix_matrix => mix_matrix_col1,
            output => inv_mix_cols_out1
        );

    -- Column 2
    inv_shift_rows_inst2: inv_shift_rows_transform 
        port map (
            input => state_row2,
            output => inv_shift_rows_out2,
            in_row_number => integer(2)
        );
        
    inv_sub_bytes_inst2: inverse_subbytes_parallel 
        port map (
            clk => clk,
            state_in => inv_shift_rows_out2,
            state_out => inv_sub_bytes_out2
        );
        
    add_round_inst2: add_round 
        port map (
            state => inv_sub_bytes_out2,
            round_key => roundkey(63 downto 32),
            result => add_round_out2
        );
        
    inv_mix_cols_inst2: inv_mix_columns_transform 
        port map (
            input => state_col2,
--            mix_matrix => mix_matrix_col2,
            output => inv_mix_cols_out2
        );

    -- Column 3
    inv_shift_rows_inst3: inv_shift_rows_transform 
        port map (
            input => state_row3,
            output => inv_shift_rows_out3,
            in_row_number => integer(3)
        );
        
    inv_sub_bytes_inst3: inverse_subbytes_parallel 
        port map (
            clk => clk,
            state_in => inv_shift_rows_out3,
            state_out => inv_sub_bytes_out3
        );
        
    add_round_inst3: add_round 
        port map (
            state => inv_sub_bytes_out3,
            round_key => roundkey(31 downto 0),
            result => add_round_out3
        );
        
    inv_mix_cols_inst3: inv_mix_columns_transform 
        port map (
            input => state_col3,
--            mix_matrix => mix_matrix_col3,
            output => inv_mix_cols_out3
        );
        
    add_round_inst4: add_round 
        port map (
            state => ciphertext(127 downto 96),
            round_key => roundkey(127 downto 96),
            result => add_round_out4
        );
    add_round_inst5: add_round 
        port map (
            state => ciphertext(95 downto 64),
            round_key => roundkey(95 downto 64),
            result => add_round_out5
        );
    add_round_inst6: add_round 
        port map (
            state => ciphertext(63 downto 32),
            round_key => roundkey(63 downto 32),
            result => add_round_out6
        );
    add_round_inst7: add_round 
        port map (
            state => ciphertext(31 downto 0),
            round_key => roundkey(31 downto 0),
            result => add_round_out7
        );

process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
            round_count <= (others => '0');
            row_counter <= (others => '0');
            col_counter <= (others => '0');
            operation_done <= '0';
            wait_count <= 0;
            
            -- Reset all state registers (updated names)
            inv_mix_cols_state <= LOAD_COLS;
            state_row0 <= (others => '0');
            state_row1 <= (others => '0');
            state_row2 <= (others => '0');
            state_row3 <= (others => '0');
            state_col0 <= (others => '0');
            state_col1 <= (others => '0');
            state_col2 <= (others => '0');
            state_col3 <= (others => '0');
        elsif rising_edge(clk) then
            -- Default assignments
            operation_done <= '0';
            
            -- State register updates
            current_state <= next_state;
            
            case current_state is

                when IDLE =>
                    if start = '1' then
                        -- Load initial state from ciphertext
                        state_row0 <= ciphertext(127 downto 96);
                        state_row1 <= ciphertext(95 downto 64);
                        state_row2 <= ciphertext(63 downto 32);
                        state_row3 <= ciphertext(31 downto 0);
                        round_count <= "1010";  -- Initialize to 10 rounds
                        operation_done <= '1';
                        that_done<='1';
                    end if;
                when LOAD_DATA=>
                    if that_done='1' then
                        next_state<=WAIT_DATA;
                    end if;
                when FIRST_ROUND =>
                    if wait_count = 0 then
                        if round_count="1010" then
                            state_row0 <= add_round_out4;
                            state_row1 <= add_round_out5;
                            state_row2 <= add_round_out6;
                            state_row3 <= add_round_out7;
                        else
                        -- Update state registers with AddRoundKey results
                            state_row0 <= add_round_out0;
                            state_row1 <= add_round_out1;
                            state_row2 <= add_round_out2;
                            state_row3 <= add_round_out3;
                        end if;
                        operation_done <= '1';
                        wait_count <= 1;  -- Add 1 wait cycle
                    else
                        wait_count <= wait_count - 1;
                    end if;
                when INV_SHIFT_ROWS =>
                
                    if row_counter = "11" then
                        row_counter <= "00";
                        
                        operation_done <= '1';
                    else
                        row_counter <= row_counter + 1;
                    end if;
                    -- Update state registers with shift results
                    
                        state_row0 <= inv_shift_rows_out0;
                        state_row1 <= inv_shift_rows_out1;
                        state_row2 <= inv_shift_rows_out2;
                        state_row3 <= inv_shift_rows_out3;
                        
                   
                when INV_SUB_BYTES =>
                    -- Wait one clock cycle for S-box lookup
                    if wait_count = 0 then
                        state_row0 <= inv_sub_bytes_out0;
                        state_row1 <= inv_sub_bytes_out1;
                        state_row2 <= inv_sub_bytes_out2;
                        state_row3 <= inv_sub_bytes_out3;
                        
                        operation_done <= '1';
                        wait_count <= 1;
                    else
                        wait_count <= wait_count - 1;
                    end if;
                
                when ADD_ROUND_KEY =>
                    if wait_count = 0 then
                        state_row0 <= add_round_out0;
                        state_row1 <= add_round_out1;
                        state_row2 <= add_round_out2;
                        state_row3 <= add_round_out3;
                        operation_done <= '1';
                        wait_count <= 1;
                    else
                        wait_count <= wait_count - 1;
                    end if;
                
                when INV_MIX_COLUMNS =>
                    case inv_mix_cols_state is
                        when LOAD_COLS =>
                            -- First load the columns from rows
                            state_col0 <= state_row0(31 downto 24) & state_row1(31 downto 24) & 
                                         state_row2(31 downto 24) & state_row3(31 downto 24);
                            state_col1 <= state_row0(23 downto 16) & state_row1(23 downto 16) & 
                                         state_row2(23 downto 16) & state_row3(23 downto 16);
                            state_col2 <= state_row0(15 downto 8) & state_row1(15 downto 8) & 
                                         state_row2(15 downto 8) & state_row3(15 downto 8);
                            state_col3 <= state_row0(7 downto 0) & state_row1(7 downto 0) & 
                                         state_row2(7 downto 0) & state_row3(7 downto 0);
                            
                            inv_mix_cols_state <= PROCESS_COLS;
                
                        when PROCESS_COLS =>
                            -- Allow one clock cycle for inv_mix_cols operation to complete
                            inv_mix_cols_state <= STORE_ROWS;
                
                        when STORE_ROWS =>
                            -- Store the results back into rows
                            a <= inv_mix_cols_out0;
                            b <= inv_mix_cols_out1;
                            c <= inv_mix_cols_out2;
                            d <= inv_mix_cols_out3;
                            inv_mix_cols_state <= ASSIGN_ROWS;
                        when ASSIGN_ROWS=>
                            state_row0 <= a(31 downto 24) & 
                                          b(31 downto 24) & 
                                          c(31 downto 24) & 
                                          d(31 downto 24);
                                          
                            state_row1 <= a(23 downto 16) & 
                                          b(23 downto 16) & 
                                          c(23 downto 16) & 
                                          d(23 downto 16);
                                          
                            state_row2 <= a(15 downto 8) & 
                                          b(15 downto 8) & 
                                          c(15 downto 8) & 
                                          d(15 downto 8);
                                          
                            state_row3 <= a(7 downto 0) & 
                                          b(7 downto 0) & 
                                          c(7 downto 0) & 
                                          d(7 downto 0);
                                          
                            operation_done <= '1';
                            inv_mix_cols_state <= LOAD_COLS;  -- Reset for next operation
                        when others =>
                            inv_mix_cols_state <= LOAD_COLS;
                    end case;
                            
        
                
                when CHECK_ROUND =>
                    if round_count /= 0 then
                        round_count <= round_count - 1;
                    end if;
                    operation_done <= '1';
                
                when FINAL =>
                    if wait_count = 0 then
                        state_row0 <= add_round_out0;
                        state_row1 <= add_round_out1;
                        state_row2 <= add_round_out2;
                        state_row3 <= add_round_out3;
                        operation_done <= '1';
                        wait_count <= 1;
                    else
                        wait_count <= wait_count - 1;
                    end if;
                
                when others =>
                    null;
            end case;
        end if;
    end process;

    process(current_state, start, round_count, operation_done)
    begin
        -- Default assignments
        next_state <= current_state;
        done <= '0';
        
        case current_state is
            when IDLE =>
                if start = '1' then
                    
                    next_state <= FIRST_ROUND;
                end if;
                
            when FIRST_ROUND =>
                if operation_done = '1' then
                    next_state <= INV_SHIFT_ROWS;
                end if;
                
            when INV_SHIFT_ROWS =>
                if operation_done = '1' then
                    next_state <= INV_SUB_BYTES;
                end if;
                
            when INV_SUB_BYTES =>
                if operation_done = '1' then
                    next_state <= ADD_ROUND_KEY;
                end if;
            when ADD_ROUND_KEY =>
                if operation_done = '1' then
                    if round_count = 0 then
                        next_state <= FINAL;
                    else
                        next_state <= INV_MIX_COLUMNS;
                    end if;
                end if;
                
            when INV_MIX_COLUMNS =>
                if operation_done = '1' then
                    next_state <= INV_SHIFT_ROWS;
                end if;
                
            when FINAL =>
                if operation_done = '1' then
                    done <= '1';
                    next_state <= IDLE;
                end if;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;
    
    -- Output assignment
    plaintext <= state_row0 & state_row1 & state_row2 & state_row3;
    
end Behavioral;

