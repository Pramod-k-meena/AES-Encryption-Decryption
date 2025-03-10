# AES Decryption Implementation with FSM Control

This project implements an AES decryption algorithm on the Basys 3 FPGA board using VHDL. The design is modular, with dedicated components for each decryption operation, and is controlled by a Finite State Machine (FSM) that manages data transfers between memories and compute units. The final plaintext is displayed on a 7-segment display.

## Authors

- **Pramod Kumar Meena (2023CS51175)**
- **Manvendra Rajpurohit (2023CS10936)**

## Project Overview

The objective of this project is to decrypt AES-encrypted ciphertext using a hardware-based approach. The AES decryption process reverses the encryption steps by applying:
- **InvSubBytes**: Uses an inverse S-box lookup.
- **InvShiftRows**: Performs right cyclic shifts on the state matrix rows.
- **InvMixColumns**: Applies matrix multiplication in GF(2^8) to reverse column mixing.
- **AddRoundKey**: Executes a bitwise XOR between the state and the round key.

The decryption process consists of an initial round, 8 main rounds, and a final round, with each round controlled by an FSM that synchronizes read/write operations and decryption steps.

## Design Details

### AES Decryption Process

1. **Input Data**
   - **Ciphertext and Key Storage**: Both are provided via COE files and stored in Block RAM. The ciphertext is an 8-bit binary stream stored in row-major order starting from address 0.

2. **Decryption Rounds**
   - **Initial Round**: XOR of ciphertext with the round key.
   - **Main Rounds** (8 rounds):
     - **InvShiftRows**: Each row of the 4×4 byte state matrix is shifted to the right (Row 0: no shift, Row 1: shift by 1, etc.).
     - **InvSubBytes**: Each byte is substituted using an inverse S-box lookup stored in memory.
     - **InvMixColumns**: The state matrix undergoes a transformation using multiplication in GF(2^8) to reverse column mixing.
     - **AddRoundKey**: A bitwise XOR is performed between the state and the round key.
   - **Final Round**: InvShiftRows, InvSubBytes, and AddRoundKey (without InvMixColumns).

### Finite State Machine (FSM)

The FSM controls the overall decryption flow, managing the sequence of operations and memory access. It handles:
- **Read/Write Operations**: Synchronizing data transfers between ROM/RAM and the compute units.
- **Round Control**: Iterating through the decryption rounds and triggering module operations.

Below is an example VHDL code snippet for the FSM:

```vhdl
entity FSM is
    Port ( 
        M             : in STD_LOGIC;
        Done          : in STD_LOGIC;
        clk           : in STD_LOGIC;
        reset         : in STD_LOGIC;
        cntrl_add_sub : out STD_LOGIC
    );
end FSM;

architecture machine of FSM is
    type state_type is (ADD, SUB);
    signal cur_state  : state_type := ADD;
    signal next_state : state_type := ADD;
begin
    -- Sequential block
    process (clk, reset)
    begin
        if (reset = '1') then
            cur_state <= ADD;
        elsif rising_edge(clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    -- Combinational block
    process (cur_state, M, Done)
    begin
        next_state <= cur_state;
        case cur_state is
            when ADD =>
                if (Done = '1' and M = '1') then
                    next_state <= SUB;
                    cntrl_add_sub <= '1';
                elsif (Done = '0') then
                    next_state <= ADD;
                    cntrl_add_sub <= '0';
                end if;
            when SUB =>
                if (Done = '1' and M = '0') then
                    next_state <= ADD;
                    cntrl_add_sub <= '0';
                elsif (Done = '0') then
                    next_state <= SUB;
                    cntrl_add_sub <= '1';
                end if;
        end case;
    end process;
end machine;
