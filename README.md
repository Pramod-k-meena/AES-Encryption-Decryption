AES Decryption Hardware Implementation
Overview
This project implements the Advanced Encryption Standard (AES) decryption algorithm in hardware using VHDL. The system takes encrypted ciphertext and a key as inputs, performs the AES decryption process through multiple rounds, and displays the resulting plaintext on a 7-segment display.

Team Members
Pramod Kumar Meena (2023CS51175)

Manvendra Rajpurohit (2023CS10936)

Project Objective
The main goal is to implement a complete AES decryption system with:

A Finite State Machine (FSM) to control data flow between memory and compute units

Hardware modules for all AES decryption operations

Display of decrypted plaintext on a 7-segment display

AES Decryption Process
The AES decryption algorithm reverses the encryption process through these key operations:

Initial Round:

AddRoundKey: XOR with the final round key

Main Rounds (8 rounds):

InvShiftRows: Cyclically shift rows to the right

InvSubBytes: Replace bytes using inverse S-box

AddRoundKey: XOR with the round key

InvMixColumns: Matrix multiplication in Galois Field GF(2^8)

Final Round:

InvShiftRows

InvSubBytes

AddRoundKey with the initial key

System Architecture
Core Components
Memory Units:

Block RAM for cipher text storage

Block RAM for round keys

Registers for temporary storage

Computational Units:

InvSubBytes module

InvShiftRows module

InvMixColumns module

AddRoundKey module

Control Units:

Main FSM for AES decryption

Read/Write FSM for memory operations

Display controller

Module Descriptions
InvSubBytes (inv_sub.vhd)
Performs byte substitution using the inverse S-box lookup table

Implemented with block memory for the S-box

Each byte is replaced with its corresponding value from the inverse S-box

InvShiftRows (inv_shift_rows.vhd)
Performs row-wise right shifts on the state matrix

Row 0: No shift

Row 1: Right shift by 1 byte

Row 2: Right shift by 2 bytes

Row 3: Right shift by 3 bytes

InvMixColumns (inv_mix_columns.vhd)
Performs matrix multiplication in Galois Field GF(2^8)

Uses the inverse mix columns matrix

Implements Galois Field multiplication with shifts and XOR operations

AddRoundKey (add_round.vhd)
Performs bitwise XOR between state and round key

Pure combinational logic module

FSM Structure
Main AES Decryption FSM States:
IDLE: Initializes the state machine and loads ciphertext

FIRST_ROUND: Executes initial AddRoundKey operation

INV_SHIFT_ROWS: Performs inverse shift rows operation

INV_SUB_BYTES: Performs inverse S-box substitution

ADD_ROUND_KEY: Combines state with round key

INV_MIX_COLUMNS: Reverses the MixColumns transformation

CHECK_ROUND: Decrements round count and checks for completion

FINAL: Completes decryption and outputs plaintext

Read/Write FSM:
Controls memory read/write operations

Manages data transfers between memory and computational units

Display System
The plaintext is displayed on the Basys 3 board's 7-segment display with the following features:

Only four characters can be displayed at a time

Text scrolls cyclically across the display

Characters are limited to the range 0-F (hexadecimal)

Out-of-range characters are displayed as "-"

No case sensitivity (e.g., both 'F' and 'f' display as 'F')

Implementation Details
Hardware Resources
The design uses Block RAM for memory components

Utilizes approximately 0.38% of available LUTs

Uses 0.67% of available registers

Requires 2% of available Block RAM tiles

Performance
The system implements the full 10-round AES decryption process

Minimal wait cycles manage latency between operations

Optimized for the Basys 3 FPGA board

Submission Deadline
November 10, 2024

References
Basys 3 Reference Manual

IEEE VHDL Reference Manual

ASCII Table for Plaintext Conversion
