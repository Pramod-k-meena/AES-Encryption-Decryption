 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.NUMERIC_STD.ALL;

 entity read_write_fsm is
     Port (
         clk, rst, start : in STD_LOGIC;
         round_number : in STD_LOGIC_VECTOR(3 downto 0);
         done : out STD_LOGIC;
         cipher_row1, cipher_row2, cipher_row3, cipher_row4 : out STD_LOGIC_VECTOR(31 downto 0);
         round_row1, round_row2, round_row3, round_row4 : out STD_LOGIC_VECTOR(31 downto 0)
     );
 end read_write_fsm;

 architecture Behavioral of read_write_fsm is
     type state_type is (IDLE, READ_CIPHER, READ_ROUND, DONE_STATE);
     signal current_state, next_state : state_type;
    
     signal byte_counter : unsigned(2 downto 0);
     signal word_counter : unsigned(1 downto 0);
     signal data_valid : std_logic;
     signal wait_counter : unsigned(1 downto 0);
    
     signal cipher_addr : std_logic_vector(3 downto 0);
     signal round_addr : std_logic_vector(7 downto 0);
     signal cipher_en, round_en : std_logic;
     signal cipher_data, round_data : std_logic_vector(7 downto 0);
    
     type reg_array is array(0 to 3) of std_logic_vector(31 downto 0);
     signal cipher_regs, round_regs : reg_array;
     signal temp_word : std_logic_vector(31 downto 0);
    
     constant WAIT_CYCLES : unsigned(1 downto 0) := "10";
    component blk_mem_gen_2
        port (
            clka : in std_logic;
            ena : in std_logic;
            addra : in std_logic_vector(3 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component blk_mem_gen_3
        port (
            clka : in std_logic;
            ena : in std_logic;
            addra : in std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;
 begin
     -- Memory components instantiation
     cipher_mem : blk_mem_gen_2
     port map (
         clka => clk, ena => cipher_en,
         addra => cipher_addr, douta => cipher_data
     );
    
     round_mem : blk_mem_gen_3
     port map (
         clka => clk, ena => round_en,
         addra => round_addr, douta => round_data
     );

     -- Main sequential process
     process(clk, rst)
     begin
         if rst = '1' then
             current_state <= IDLE;
             byte_counter <= (others => '0');
             word_counter <= (others => '0');
             wait_counter <= (others => '0');
             cipher_regs <= (others => (others => '0'));
             round_regs <= (others => (others => '0'));
         elsif rising_edge(clk) then
             current_state <= next_state;
            
             case current_state is
                 when READ_CIPHER | READ_ROUND =>
                     if wait_counter = WAIT_CYCLES then
                         wait_counter <= (others => '0');
                        
                         -- Store data in appropriate register
                         if current_state = READ_CIPHER then
                             cipher_regs(to_integer(word_counter))(31-to_integer(byte_counter)*8 downto 24-to_integer(byte_counter)*8) 
                                 <= cipher_data;
                         else
                             round_regs(to_integer(word_counter))(31-to_integer(byte_counter)*8 downto 24-to_integer(byte_counter)*8) 
                                <= round_data;
                         end if;
                        
                         -- Update counters
                         if byte_counter = 3 then
                             byte_counter <= (others => '0');
                             if word_counter = 3 then
                                 word_counter <= (others => '0');
                             else
                                 word_counter <= word_counter + 1;
                             end if;
                         else
                             byte_counter <= byte_counter + 1;
                         end if;
                     else
                         wait_counter <= wait_counter + 1;
                     end if;
                
                 when others =>
                     wait_counter <= (others => '0');
                     byte_counter <= (others => '0');
                     word_counter <= (others => '0');
             end case;
         end if;
     end process;

     -- Next state logic
     process(current_state, start, byte_counter, word_counter, wait_counter)
     begin
         next_state <= current_state;
         cipher_en <= '0';
         round_en <= '0';
         done <= '0';
        
         case current_state is
             when IDLE =>
                 if start = '1' then
                     next_state <= READ_CIPHER;
                 end if;
                
             when READ_CIPHER =>
                 cipher_en <= '1';
                 cipher_addr <= std_logic_vector(word_counter & byte_counter(1 downto 0));
                 if byte_counter = 3 and word_counter = 3 and wait_counter = WAIT_CYCLES then
                     next_state <= READ_ROUND;
                 end if;
                
             when READ_ROUND =>
                round_en <= '1';
                round_addr <= round_number & std_logic_vector(word_counter) & std_logic_vector(byte_counter(1 downto 0));
                if byte_counter = 3 and word_counter = 3 and wait_counter = WAIT_CYCLES then
                    next_state <= DONE_STATE;
                end if;
--                      round_addr <= round_number & std_logic_vector(word_counter) & std_logic_vector(byte_counter(1 downto 0));
--                 if byte_counter = 3 and word_counter = 3 and wait_counter = WAIT_CYCLES then
--                     next_state <= DONE_STATE;
--                 end if;
                
             when DONE_STATE =>
                 done <= '1';
                 if start = '0' then
                     next_state <= IDLE;
                 end if;
         end case;
     end process;

     -- Output assignments
     cipher_row1 <= cipher_regs(0);
     cipher_row2 <= cipher_regs(1);
     cipher_row3 <= cipher_regs(2);
     cipher_row4 <= cipher_regs(3);
     round_row1 <= round_regs(0);
     round_row2 <= round_regs(1);
     round_row3 <= round_regs(2);
     round_row4 <= round_regs(3);
    
 end Behavioral;
