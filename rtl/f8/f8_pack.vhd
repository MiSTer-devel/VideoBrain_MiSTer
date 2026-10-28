--------------------------------------------------------------------------------
-- Fairchild F8 CPU
--------------------------------------------------------------------------------
-- DO 8/2020
--------------------------------------------------------------------------------
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- With help from MAME F8 model

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.base_pack.ALL;

PACKAGE f8_pack IS

  TYPE type_rom IS ARRAY(0 TO 1023) OF uv8;

  FUNCTION test_bf(op    : uv4;
                   iozcs : uv5) RETURN boolean;
  FUNCTION test_bt(op    : uv3;
                   iozcs : uv5) RETURN boolean;

  TYPE enum_len IS (S,L);
  TYPE enum_int IS (I0,IX,IY);
  TYPE enum_op IS (
    OP_NOP,OP_MOV,OP_MOI,
    OP_ADD,OP_ADDD,OP_AND,OP_OR ,OP_XOR,OP_CMP,
    OP_SR1,OP_SL1,OP_SR4, OP_SL4,
    OP_COM,OP_LNK,OP_EDI,
    OP_INC,OP_DEC,OP_LIS,OP_TST8,OP_TST9);

  PROCEDURE aluop(op : IN enum_op;
                  code : IN uv8;
                  src1 : IN uv8;
                  src2 : IN uv8;
                  iozcs_i : IN uv5;
                  dst  : OUT uv8;
                  dstm : OUT std_logic; -- modified result reg
                  iozcs_o : OUT uv5;
                  test : OUT std_logic);
  
  CONSTANT R0     : uint5 := 0;
  CONSTANT R1     : uint5 := 1;
  CONSTANT R2     : uint5 := 2;
  CONSTANT R3     : uint5 := 3;
  CONSTANT R4     : uint5 := 4;
  CONSTANT R5     : uint5 := 5;
  CONSTANT R6     : uint5 := 6;
  CONSTANT R7     : uint5 := 7;
  CONSTANT R8     : uint5 := 8;
  CONSTANT R9     : uint5 := 9;
  CONSTANT R10    : uint5 := 10;
  CONSTANT R11    : uint5 := 11;
  CONSTANT R12    : uint5 := 12;
  CONSTANT R13    : uint5 := 13;
  CONSTANT R14    : uint5 := 14;
  CONSTANT R15    : uint5 := 15;

  CONSTANT RACC   : uint5 := 16;

  CONSTANT WREG   : uint5 := 17;
  CONSTANT ISARU  : uint5 := 18;
  CONSTANT ISARL  : uint5 := 19;
  CONSTANT ISAR   : uint5 := 20;

  CONSTANT RISAR  : uint5 := 21;
  CONSTANT RISARP : uint5 := 22;
  CONSTANT RISARM : uint5 := 23;

  CONSTANT PORT0  : uint5 := 24;
  CONSTANT PORT1  : uint5 := 25;

  CONSTANT DATA   : uint5 := 31;

  TYPE type_microcode IS RECORD
    romc : uv5;
    len  : enum_len;
    last : uint1;
    int  : enum_int;
    op   : enum_op;
    rd   : uint5;
    rs   : uint5;
  END RECORD;
  TYPE arr_microcode IS ARRAY(natural RANGE <>) OF type_microcode;

  CONSTANT OP_RESET     : uv8 := x"2F";
  CONSTANT OP_INTERRUPT : uv8 := x"2E";

  CONSTANT ROMC_00 : uv5 :="00000";
  CONSTANT ROMC_01 : uv5 :="00001";
  CONSTANT ROMC_02 : uv5 :="00010";
  CONSTANT ROMC_03 : uv5 :="00011"; -- or 01 for cond. branches
  CONSTANT ROMC_04 : uv5 :="00100";
  CONSTANT ROMC_05 : uv5 :="00101";
  CONSTANT ROMC_06 : uv5 :="00110";
  CONSTANT ROMC_07 : uv5 :="00111";
  CONSTANT ROMC_08 : uv5 :="01000";
  CONSTANT ROMC_09 : uv5 :="01001";
  CONSTANT ROMC_0A : uv5 :="01010";
  CONSTANT ROMC_0B : uv5 :="01011";
  CONSTANT ROMC_0C : uv5 :="01100";
  CONSTANT ROMC_0D : uv5 :="01101";
  CONSTANT ROMC_0E : uv5 :="01110";
  CONSTANT ROMC_0F : uv5 :="01111";
  CONSTANT ROMC_10 : uv5 :="10000";
  CONSTANT ROMC_11 : uv5 :="10001";
  CONSTANT ROMC_12 : uv5 :="10010";
  CONSTANT ROMC_13 : uv5 :="10011";
  CONSTANT ROMC_14 : uv5 :="10100";
  CONSTANT ROMC_15 : uv5 :="10101";
  CONSTANT ROMC_16 : uv5 :="10110";
  CONSTANT ROMC_17 : uv5 :="10111";
  CONSTANT ROMC_18 : uv5 :="11000";
  CONSTANT ROMC_19 : uv5 :="11001";
  CONSTANT ROMC_1A : uv5 :="11010";
  CONSTANT ROMC_1B : uv5 :="11011";
  CONSTANT ROMC_1C : uv5 :="11100";
  CONSTANT ROMC_1D : uv5 :="11101";
  CONSTANT ROMC_1E : uv5 :="11110";
  CONSTANT ROMC_1F : uv5 :="11111";

  CONSTANT ZZ : type_microcode := (ROMC_00,S,1,I0,OP_NOP,RACC,RACC);

  -- romc / cycles / op / rdest / rsrc
  CONSTANT MICROCODE : arr_microcode(0 TO 256*8-1) := (
    -- romc cyc last int aluop rdest rsrc
    -- 6    2   1    2   4     5     5
    (ROMC_00,S,1,I0,OP_MOV,RACC,R12),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 00: lr a,ku
    (ROMC_00,S,1,I0,OP_MOV,RACC,R13),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 01: lr a,kl
    (ROMC_00,S,1,I0,OP_MOV,RACC,R14),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 02: lr a,qu
    (ROMC_00,S,1,I0,OP_MOV,RACC,R15),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 03: lr a,ql
    (ROMC_00,S,1,I0,OP_MOV,R12,RACC),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 04: lr ku,a
    (ROMC_00,S,1,I0,OP_MOV,R13,RACC),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 05: lr kl,a
    (ROMC_00,S,1,I0,OP_MOV,R14,RACC),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 06: lr qu,a
    (ROMC_00,S,1,I0,OP_MOV,R15,RACC),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 07: lr ql,a
    (ROMC_07,L,0,I0,OP_MOV,R12,DATA),                               -- 08: lr k,p
    (ROMC_0B,L,0,I0,OP_MOV,R13,DATA),                               -- r13 <= data <= pc1l
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_15,L,0,I0,OP_MOV,DATA,R12),                               -- 09: lr p,k
    (ROMC_18,L,0,I0,OP_MOV,DATA,R13),                               -- pc1l <= data <= r13
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_00,S,1,I0,OP_MOV,RACC,ISAR), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 0a: lr a,is
    (ROMC_00,S,1,I0,OP_MOV,ISAR,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 0b: lr is,a
    (ROMC_12,L,0,I0,OP_MOV,DATA,R13),                               -- 0c: pk
    (ROMC_14,L,0,I0,OP_MOV,DATA,R12),                               -- pc0u <= data <= r12
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_17,L,0,I0,OP_MOV,DATA,R15),                               -- 0d: lr
    (ROMC_14,L,0,I0,OP_MOV,DATA,R14),                               -- pc0u <= data <= r14
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_06,L,0,I0,OP_MOV,R14,DATA),                               -- 0e: lr q,dc
    (ROMC_09,L,0,I0,OP_MOV,R15,DATA),                               -- r15 <= data <= dc0l
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_16,L,0,I0,OP_MOV,DATA,R14),                               -- 0f: lr dc,q
    (ROMC_19,L,0,I0,OP_MOV,DATA,R15),                               -- dc0l <= data <= r15
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_16,L,0,I0,OP_MOV,DATA,R10),                               -- 10: lr dc,h
    (ROMC_19,L,0,I0,OP_MOV,DATA,R11),                               -- dc0l <= data <= r11
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_06,L,0,I0,OP_MOV,R10,DATA),                               -- 11: lr h,dc
    (ROMC_09,L,0,I0,OP_MOV,R11,DATA),                               -- r11 <= data <= dc0l
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_00,S,1,I0,OP_SR1,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 12: sr   1
    (ROMC_00,S,1,I0,OP_SL1,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 13: sl   1
    (ROMC_00,S,1,I0,OP_SR4,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 14: sr   4
    (ROMC_00,S,1,I0,OP_SL4,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 15: sl   4
    (ROMC_02,L,0,I0,OP_MOV,RACC,DATA),                              -- 16: lm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_05,L,0,I0,OP_MOV,DATA,RACC),                              -- 17: st
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_00,S,1,I0,OP_COM,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 18: com
    (ROMC_00,S,1,I0,OP_LNK,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 19: lnk
    (ROMC_1C,S,0,IY,OP_EDI,RACC,RACC),                              -- 1a: di
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_EDI,RACC,RACC),                              -- 1b: ei
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_04,S,0,I0,OP_NOP,RACC,RACC),                              -- 1c: pop
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_MOV,WREG,R9),                                -- 1d: lr w,j
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_00,S,1,I0,OP_MOV,R9,WREG),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 1e: lr j,w
    (ROMC_00,S,1,I0,OP_INC,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 1f: inc
    (ROMC_03,L,0,I0,OP_MOV,RACC,DATA),                              -- 20 ii : acc <= imm         : li ii   : load immediate acc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_AND,RACC,DATA),                              -- 21 ii : acc <= acc & imm   : ni   ii : and immediate acc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_OR ,RACC,DATA),                              -- 22 ii : acc <= acc | imm   : oi   ii : or  immediate acc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_XOR,RACC,DATA),                              -- 23 ii : acc <= acc ^ imm   : xi   ii : xor immediate acc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_ADD,RACC,DATA),                              -- 24 ii : acc <= acc + imm   : ai   ii : add immediate acc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_CMP,RACC,DATA),                              -- 25 ii : cmp (acc,imm)      : ci   ii : cmp immediate acc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_NOP,RACC,RACC),                              -- 26 ii : (fetch operand)    : in   aa : input port aa
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- acc <= ioport[db]
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_NOP,RACC,RACC),                              -- 27 ii : (fetch operand)    : out  aa : output port aa
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),                              -- ioport[db] <= acc
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_MOV,RACC,DATA),                              -- 28 aaaa : acc <= data (immediate)  : pi  aaaa : call subroutine
    (ROMC_0D,S,0,I0,OP_NOP,RACC,RACC),                              -- pc1 <= pc0 + 1
    (ROMC_0C,L,0,I0,OP_MOV,DATA,DATA),                              -- pc0l <= data (immediate)
    (ROMC_14,L,0,I0,OP_MOV,DATA,RACC),                              -- pc0u <= data <= acc
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,
    (ROMC_03,L,0,I0,OP_MOV,RACC,DATA),                              -- 29 aaaa : acc <= data (immediate)  : jmp aaaa : jump
    (ROMC_0C,L,0,I0,OP_MOV,DATA,DATA),                              -- pc0l <= data (immediate)
    (ROMC_14,L,0,I0,OP_MOV,DATA,RACC),                              -- pc0u <= data <= acc
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,
    (ROMC_11,L,0,I0,OP_MOV,DATA,DATA),                              -- 2a aaaa : dc0u <= data (immediate)  : dci aaaa : load dc imm
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- pc0 ++
    (ROMC_0E,L,0,I0,OP_MOV,DATA,DATA),                              -- dc0l <= data (immediate)
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- pc0 ++
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,

    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 2b: nop

    (ROMC_1D,S,1,I0,OP_NOP,RACC,RACC),                              -- 2c: xdc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 2d: nop

    -- interrupt (undef opcode) ---------------------------
    (ROMC_1C,L,0,I0,OP_NOP,RACC,RACC),                              -- 2e      :                           
    (ROMC_0F,L,0,I0,OP_NOP,RACC,RACC),                              -- pc0l <= int vect low, pc1 <= pc0
    (ROMC_13,L,0,IY,OP_NOP,RACC,RACC),                              -- pc0u <= int vect high
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,

    -- reset (undef opcode) -------------------------------
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- 2f      
    (ROMC_08,L,0,IY,OP_NOP,RACC,RACC),                              -- pc0 <= 0 pc1 <= pc0
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_00,L,1,I0,OP_DEC,R0 ,R0 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 30: ds   r0
    (ROMC_00,L,1,I0,OP_DEC,R1 ,R1 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 31: ds   r1
    (ROMC_00,L,1,I0,OP_DEC,R2 ,R2 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 32: ds   r2
    (ROMC_00,L,1,I0,OP_DEC,R3 ,R3 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 33: ds   r3
    (ROMC_00,L,1,I0,OP_DEC,R4 ,R4 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 34: ds   r4
    (ROMC_00,L,1,I0,OP_DEC,R5 ,R5 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 35: ds   r5
    (ROMC_00,L,1,I0,OP_DEC,R6 ,R6 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 36: ds   r6
    (ROMC_00,L,1,I0,OP_DEC,R7 ,R7 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 37: ds   r7
    (ROMC_00,L,1,I0,OP_DEC,R8 ,R8 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 38: ds   r8
    (ROMC_00,L,1,I0,OP_DEC,R9 ,R9 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 39: ds   r9
    (ROMC_00,L,1,I0,OP_DEC,R10,R10),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 3a: ds   r10
    (ROMC_00,L,1,I0,OP_DEC,R11,R11),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 3b: ds   r11
    (ROMC_00,L,1,I0,OP_DEC,RISAR,RISAR),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 3c: ds (isar)
    (ROMC_00,L,1,I0,OP_DEC,RISARP,RISARP), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 3d: ds (isar+)
    (ROMC_00,L,1,I0,OP_DEC,RISARM,RISARM), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 3e: ds (isar-)
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC),     ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,    -- 3f: invalid (invalid)

    (ROMC_00,S,1,I0,OP_MOV,RACC,R0 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 40: lr a,r0
    (ROMC_00,S,1,I0,OP_MOV,RACC,R1 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 41: lr a,r1
    (ROMC_00,S,1,I0,OP_MOV,RACC,R2 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 42: lr a,r2
    (ROMC_00,S,1,I0,OP_MOV,RACC,R3 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 43: lr a,r3
    (ROMC_00,S,1,I0,OP_MOV,RACC,R4 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 44: lr a,r4
    (ROMC_00,S,1,I0,OP_MOV,RACC,R5 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 45: lr a,r5
    (ROMC_00,S,1,I0,OP_MOV,RACC,R6 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 46: lr a,r6
    (ROMC_00,S,1,I0,OP_MOV,RACC,R7 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 47: lr a,r7
    (ROMC_00,S,1,I0,OP_MOV,RACC,R8 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 48: lr a,r8
    (ROMC_00,S,1,I0,OP_MOV,RACC,R9 ),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 49: lr a,r9
    (ROMC_00,S,1,I0,OP_MOV,RACC,R10),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 4a: lr a,r10
    (ROMC_00,S,1,I0,OP_MOV,RACC,R11),       ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 4b: lr a,r11
    (ROMC_00,S,1,I0,OP_MOV,RACC,RISAR),     ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 4c: lr a,(isar)
    (ROMC_00,S,1,I0,OP_MOV,RACC,RISARP),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 4d: lr a,(isar+)
    (ROMC_00,S,1,I0,OP_MOV,RACC,RISARM),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 4e: lr a,(isar-)
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC),      ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,   -- 4f: invalid (invalid)

    (ROMC_00,S,1,I0,OP_MOV,R0 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 50: lr r0 ,a
    (ROMC_00,S,1,I0,OP_MOV,R1 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 51: lr r1 ,a
    (ROMC_00,S,1,I0,OP_MOV,R2 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 52: lr r2 ,a
    (ROMC_00,S,1,I0,OP_MOV,R3 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 53: lr r3 ,a
    (ROMC_00,S,1,I0,OP_MOV,R4 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 54: lr r4 ,a
    (ROMC_00,S,1,I0,OP_MOV,R5 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 55: lr r5 ,a
    (ROMC_00,S,1,I0,OP_MOV,R6 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 56: lr r6 ,a
    (ROMC_00,S,1,I0,OP_MOV,R7 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 57: lr r7 ,a
    (ROMC_00,S,1,I0,OP_MOV,R8 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 58: lr r8 ,a
    (ROMC_00,S,1,I0,OP_MOV,R9 ,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 59: lr r9 ,a
    (ROMC_00,S,1,I0,OP_MOV,R10,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 5a: lr r10,a
    (ROMC_00,S,1,I0,OP_MOV,R11,RACC),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 5b: lr r11,a
    (ROMC_00,S,1,I0,OP_MOV,RISAR,RACC),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 5c: lr (isar),a
    (ROMC_00,S,1,I0,OP_MOV,RISARP,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 5d: lr (isar+),a
    (ROMC_00,S,1,I0,OP_MOV,RISARM,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 5e: lr (isar-),a
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- 5f: invalid (invalid)

    (ROMC_00,S,1,I0,OP_LIS,ISARU,R0), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 60: lisu 0
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R1), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 61: lisu 1
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R2), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 62: lisu 2
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R3), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 63: lisu 3
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R4), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 64: lisu 4
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R5), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 65: lisu 5
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R6), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 66: lisu 6
    (ROMC_00,S,1,I0,OP_LIS,ISARU,R7), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 67: lisu 7

    (ROMC_00,S,1,I0,OP_LIS,ISARL,R0), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 68: lisl 0
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R1), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 69: lisl 1
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R2), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 6a: lisl 2
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R3), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 6b: lisl 3
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R4), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 6c: lisl 4
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R5), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 6d: lisl 5
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R6), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 6e: lisl 6
    (ROMC_00,S,1,I0,OP_LIS,ISARL,R7), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- 6f: lisl 7

    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 70: lis 0
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 71: lis 1
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 72: lis 2
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 73: lis 3
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 74: lis 4
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 75: lis 5
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 76: lis 6
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 77: lis 7
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 78: lis 8
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 79: lis 9
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 7a: lis 10
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 7b: lis 11
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 7c: lis 12
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 7d: lis 13
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 7e: lis 14
    (ROMC_00,S,1,I0,OP_LIS,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,        -- 7f: lis 15

    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 80: bcc  0
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 81: bcc  1
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 82: bcc  2
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 83: bcc  3
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 84: bcc  4
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 85: bcc  5
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 86: bcc  6
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST8,RACC,RACC),                             -- 87: bcc  7
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_02,L,0,I0,OP_ADD,RACC,DATA),                              -- 88: am
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_02,L,0,I0,OP_ADDD,RACC,DATA),                             -- 89: amd
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_02,L,0,I0,OP_AND,RACC,DATA),                              -- 8a: nm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_02,L,0,I0,OP_OR ,RACC,DATA),                              -- 8b: om
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_02,L,0,I0,OP_XOR,RACC,DATA),                              -- 8c: xm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_02,L,0,I0,OP_CMP,RACC,DATA),                              -- 8d: cm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_0A,L,0,I0,OP_MOV,DATA,RACC),                              -- 8e: adc
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- 8f aa : test  isarl, pc +2 or +imm  : br7 aa  : branch if isarlo/=7
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 90 aa :                             :  bf 0   : branch
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 91 aa :                             :  bf 1   : branch if negative
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 92 aa :                             :  bf 2   : branch if no carry
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 93 aa :                             :  bf 3   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 94 aa :                             :  bf 4   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 95 aa :                             :  bf 5   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 96 aa :                             :  bf 6   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 97 aa :                             :  bf 7   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 98 aa :                             :  bf 8   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 99 aa :                             :  bf 9   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 9a aa :                             :  bf a   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 9b aa :                             :  bf b   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 9c aa :                             :  bf c   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 9d aa :                             :  bf d   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 9e aa :                             :  bf e   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_TST9,RACC,RACC),                             -- 9f aa :                             :  bf f   : branch if
    (ROMC_03,S,0,I0,OP_NOP,RACC,RACC),                              -- test, change pc0 + 2 or +imm
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_1C,S,0,I0,OP_MOI,RACC,PORT0),                             -- a0: ins  0
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_MOI,RACC,PORT1),                             -- a1: ins  1
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_1C,L,0,I0,OP_LIS,DATA,R2),                                -- a2: ins  2
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R3),                                -- a3: ins  3
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R4),                                -- a4: ins  4
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R5),                                -- a5: ins  5
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R6),                                -- a6: ins  6
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R7),                                -- a7: ins  7
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R8),                                -- a8: ins  8
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R9),                                -- a9: ins  9
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R10),                               -- aa: ins  10
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R11),                               -- ab: ins  11
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R12),                               -- ac: ins  12
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R13),                               -- ad: ins  13
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R14),                               -- ae: ins  14
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R15),                               -- af: ins  15
    (ROMC_1B,L,0,I0,OP_MOI,RACC,DATA),                              -- db <= data ioport
    (ROMC_00,S,1,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_1C,S,0,I0,OP_MOV,PORT0,RACC),                             -- b0: outs 0
    (ROMC_00,S,0,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_MOV,PORT1,RACC),                             -- b1: outs 1
    (ROMC_00,S,0,I0,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R2),                                -- b2: outs 2
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R3),                                -- b3: outs 3
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R4),                                -- b4: outs 4
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R5),                                -- b5: outs 5
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R6),                                -- b6: outs 6
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R7),                                -- b7: outs 7
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R8),                                -- b8: outs 8
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R9),                                -- b9: outs 9
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R10),                               -- ba: outs 10
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R11),                               -- bb: outs 11
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R12),                               -- bc: outs 12
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R13),                               -- bd: outs 13
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R14),                               -- be: outs 14
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,L,0,I0,OP_LIS,DATA,R15),                               -- bf: outs 15
    (ROMC_1A,L,0,I0,OP_MOV,DATA,RACC),
    (ROMC_00,S,1,IX,OP_NOP,RACC,RACC), ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_00,S,1,I0,OP_ADD,RACC,R0 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c0: as r0
    (ROMC_00,S,1,I0,OP_ADD,RACC,R1 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c1: as r1
    (ROMC_00,S,1,I0,OP_ADD,RACC,R2 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c2: as r2
    (ROMC_00,S,1,I0,OP_ADD,RACC,R3 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c3: as r3
    (ROMC_00,S,1,I0,OP_ADD,RACC,R4 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c4: as r4
    (ROMC_00,S,1,I0,OP_ADD,RACC,R5 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c5: as r5
    (ROMC_00,S,1,I0,OP_ADD,RACC,R6 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c6: as r6
    (ROMC_00,S,1,I0,OP_ADD,RACC,R7 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c7: as r7
    (ROMC_00,S,1,I0,OP_ADD,RACC,R8 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c8: as r8
    (ROMC_00,S,1,I0,OP_ADD,RACC,R9 ),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- c9: as r9
    (ROMC_00,S,1,I0,OP_ADD,RACC,R10),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- ca: as r10
    (ROMC_00,S,1,I0,OP_ADD,RACC,R11),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- cb: as r11
    (ROMC_00,S,1,I0,OP_ADD,RACC,RISAR),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- cc: as r12
    (ROMC_00,S,1,I0,OP_ADD,RACC,RISARP), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- cd: as r13
    (ROMC_00,S,1,I0,OP_ADD,RACC,RISARM), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- ce: as r14
    (ROMC_00,S,1,I0,OP_ADD,RACC,R15),    ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- cf: as r15 (invalid)

    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d0: asd r0
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R0 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d1: asd r1
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R1 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d2: asd r2
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R2 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d3: asd r3
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R3 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d4: asd r4
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R4 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d5: asd r5
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R5 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d6: asd r6
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R6 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d7: asd r7
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R7 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d8: asd r8
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R8 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- d9: asd r9
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R9 ),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- da: asd r10
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R10),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- db: asd r11
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R11),   ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- dc: asd r12
    (ROMC_00,S,1,I0,OP_ADDD,RACC,RISAR), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- dd: asd r13
    (ROMC_00,S,1,I0,OP_ADDD,RACC,RISARP), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- de: asd r14
    (ROMC_00,S,1,I0,OP_ADDD,RACC,RISARM),  ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,
    (ROMC_1C,S,0,I0,OP_NOP,RACC,RACC),                              -- df: asd r15 (invalid)
    (ROMC_00,S,1,I0,OP_ADDD,RACC,R15),     ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,

    (ROMC_00,S,1,I0,OP_XOR,RACC,R0 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e0: xs r0
    (ROMC_00,S,1,I0,OP_XOR,RACC,R1 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e1: xs r1
    (ROMC_00,S,1,I0,OP_XOR,RACC,R2 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e2: xs r2
    (ROMC_00,S,1,I0,OP_XOR,RACC,R3 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e3: xs r3
    (ROMC_00,S,1,I0,OP_XOR,RACC,R4 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e4: xs r4
    (ROMC_00,S,1,I0,OP_XOR,RACC,R5 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e5: xs r5
    (ROMC_00,S,1,I0,OP_XOR,RACC,R6 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e6: xs r6
    (ROMC_00,S,1,I0,OP_XOR,RACC,R7 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e7: xs r7
    (ROMC_00,S,1,I0,OP_XOR,RACC,R8 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e8: xs r8
    (ROMC_00,S,1,I0,OP_XOR,RACC,R9 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- e9: xs r9
    (ROMC_00,S,1,I0,OP_XOR,RACC,R10), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- ea: xs r10
    (ROMC_00,S,1,I0,OP_XOR,RACC,R11), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- eb: xs r11
    (ROMC_00,S,1,I0,OP_XOR,RACC,RISAR), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,       -- ec: xs r12
    (ROMC_00,S,1,I0,OP_XOR,RACC,RISARP), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- ed: xs r13
    (ROMC_00,S,1,I0,OP_XOR,RACC,RISARM), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- ee: xs r14
    (ROMC_00,S,1,I0,OP_XOR,RACC,R15), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- ef: xs r15 (invalid)

    (ROMC_00,S,1,I0,OP_AND,RACC,R0 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f0: ns r0
    (ROMC_00,S,1,I0,OP_AND,RACC,R1 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f1: ns r1
    (ROMC_00,S,1,I0,OP_AND,RACC,R2 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f2: ns r2
    (ROMC_00,S,1,I0,OP_AND,RACC,R3 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f3: ns r3
    (ROMC_00,S,1,I0,OP_AND,RACC,R4 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f4: ns r4
    (ROMC_00,S,1,I0,OP_AND,RACC,R5 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f5: ns r5
    (ROMC_00,S,1,I0,OP_AND,RACC,R6 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f6: ns r6
    (ROMC_00,S,1,I0,OP_AND,RACC,R7 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f7: ns r7
    (ROMC_00,S,1,I0,OP_AND,RACC,R8 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f8: ns r8
    (ROMC_00,S,1,I0,OP_AND,RACC,R9 ), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- f9: ns r9
    (ROMC_00,S,1,I0,OP_AND,RACC,R10), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- fa: ns r10
    (ROMC_00,S,1,I0,OP_AND,RACC,R11), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,         -- fb: ns r11
    (ROMC_00,S,1,I0,OP_AND,RACC,RISAR), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,       -- fc: ns r12
    (ROMC_00,S,1,I0,OP_AND,RACC,RISARP), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- fd: ns r13
    (ROMC_00,S,1,I0,OP_AND,RACC,RISARM), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,      -- fe: ns r14
    (ROMC_00,S,1,I0,OP_AND,RACC,R15), ZZ,ZZ,ZZ,ZZ,ZZ,ZZ,ZZ          -- ff: ns r15 (invalid)
    );

  TYPE arr_string12 IS ARRAY(natural RANGE <>) OF string(1 TO 12);
  CONSTANT OPTXT : arr_string12(0 TO 255) :=(
    "LR A,KU     ", "LR A,KL     ", "LR A,QU     ", "LR A,QL     ", -- 00
    "LR KU,A     ", "LR KL,A     ", "LR QU,A     ", "LR QL,A     ",
    "LR K,P      ", "LR P,K      ", "LR A,IS     ", "LR IS,A     ",
    "PK          ", "LR          ", "LR Q,DC     ", "LR DC,Q     ",
    "LR DC,H     ", "LR H,DC     ", "SR   1      ", "SL   1      ", -- 10
    "SR   4      ", "SL   4      ", "LM          ", "ST          ",
    "COM         ", "LNK         ", "DI          ", "EI          ",
    "POP         ", "LR W,J      ", "LR J,W      ", "INC         ",
    "LI   ii     ", "NI   ii     ", "OI   ii     ", "XI   ii     ", -- 20
    "AI   ii     ", "CI   ii     ", "IN   aa     ", "OUT  aa     ",
    "PI  aaaa    ", "JMP aaaa    ", "DCI aaaa    ", "NOP         ",
    "XDC         ", "NOP         ", "<INTERRUPT> ", "<RESET>     ",
    "DEC  R0     ", "DEC  R1     ", "DEC  R2     ", "DEC  R3     ", -- 30
    "DEC  R4     ", "DEC  R5     ", "DEC  R6     ", "DEC  R7     ",
    "DEC  R8     ", "DEC  R9     ", "DEC  R10    ", "DEC  R11    ",
    "DEC (ISAR)  ", "DEC  (ISAR+)", "DEC  (ISAR-)", "Invalid     ",
    "LR A,R0     ", "LR A,R1     ", "LR A,R2     ", "LR A,R3     ", -- 40
    "LR A,R4     ", "LR A,R5     ", "LR A,R6     ", "LR A,R7     ",
    "LR A,R8     ", "LR A,R9     ", "LR A,R10    ", "LR A,R11    ",
    "LR A,(ISAR) ", "LR A,(ISAR+)", "LR A,(ISAR-)", "Invalid     ",
    "LR R0 ,A    ", "LR R1 ,A    ", "LR R2 ,A    ", "LR R3 ,A    ", -- 50
    "LR R4 ,A    ", "LR R5 ,A    ", "LR R6 ,A    ", "LR R7 ,A    ",
    "LR R8 ,A    ", "LR R9 ,A    ", "LR R10,A    ", "LR R11,A    ",
    "LR (ISAR),A ", "LR (ISAR+),A", "LR (ISAR-),A", "Invalid     ",
    "LISU 0      ", "LISU 1      ", "LISU 2      ", "LISU 3      ", -- 60
    "LISU 4      ", "LISU 5      ", "LISU 6      ", "LISU 7      ",
    "LISL 0      ", "LISL 1      ", "LISL 2      ", "LISL 3      ",
    "LISL 4      ", "LISL 5      ", "LISL 6      ", "LISL 7      ",
    "LIS 0       ", "LIS 1       ", "LIS 2       ", "LIS 3       ", -- 70
    "LIS 4       ", "LIS 5       ", "LIS 6       ", "LIS 7       ",
    "LIS 8       ", "LIS 9       ", "LIS 10      ", "LIS 11      ",
    "LIS 12      ", "LIS 13      ", "LIS 14      ", "LIS 15      ",
    "BT   0 aa   ", "BT   1 aa   ", "BT   2 aa   ", "BT   3 aa   ", -- 80
    "BT   4 aa   ", "BT   5 aa   ", "BT   6 aa   ", "BT   7 aa   ",
    "AM          ", "AMD         ", "NM          ", "OM          ",
    "XM          ", "CM          ", "ADC         ", "BR7 aa      ",
    "BF 0   aa   ", "BF 1   aa   ", "BF 2   aa   ", "BF 3   aa   ", -- 90
    "BF 4   aa   ", "BF 5   aa   ", "BF 6   aa   ", "BF 7   aa   ",
    "BF 8   aa   ", "BF 9   aa   ", "BF A   aa   ", "BF B   aa   ",
    "BF C   aa   ", "BF D   aa   ", "BF E   aa   ", "BF F   aa   ",
    "INS  0      ", "INS  1      ", "INS  2      ", "INS  3      ", -- a0
    "INS  4      ", "INS  5      ", "INS  6      ", "INS  7      ",
    "INS  8      ", "INS  9      ", "INS  10     ", "INS  11     ",
    "INS  12     ", "INS  13     ", "INS  14     ", "INS  15     ",
    "OUTS 0      ", "OUTS 1      ", "OUTS 2      ", "OUTS 3      ", -- b0
    "OUTS 4      ", "OUTS 5      ", "OUTS 6      ", "OUTS 7      ",
    "OUTS 8      ", "OUTS 9      ", "OUTS 10     ", "OUTS 11     ",
    "OUTS 12     ", "OUTS 13     ", "OUTS 14     ", "OUTS 15     ",
    "AS R0       ", "AS R1       ", "AS R2       ", "AS R3       ", -- c0
    "AS R4       ", "AS R5       ", "AS R6       ", "AS R7       ",
    "AS R8       ", "AS R9       ", "AS R10      ", "AS R11      ",
    "AS  (ISAR)  ", "AS  (ISAR+) ", "AS  (ISAR-) ", "Invalid     ",
    "ASD R0      ", "ASD R1      ", "ASD R2      ", "ASD R3      ", -- d0
    "ASD R4      ", "ASD R5      ", "ASD R6      ", "ASD R7      ",
    "ASD R8      ", "ASD R9      ", "ASD R10     ", "ASD R11     ",
    "ASD (ISAR)  ", "ASD (ISAR+) ", "ASD (ISAR-) ", "Invalid     ",
    "XOR R0      ", "XOR R1      ", "XOR R2      ", "XOR R3      ", -- e0
    "XOR R4      ", "XOR R5      ", "XOR R6      ", "XOR R7      ",
    "XOR R8      ", "XOR R9      ", "XOR R10     ", "XOR R11     ",
    "XOR (ISAR)  ", "XOR (ISAR+) ", "XOR (ISAR-) ", "Invalid     ",
    "AND R0      ", "AND R1      ", "AND R2      ", "AND R3      ", -- f0
    "AND R4      ", "AND R5      ", "AND R6      ", "AND R7      ",
    "AND R8      ", "AND R9      ", "AND R10     ", "AND R11     ",
    "AND (ISAR)  ", "AND (ISAR+) ", "AND (ISAR-) ", "Invalid     ");
  
  TYPE arr_ilen IS ARRAY(natural RANGE <>) OF uint3;
  CONSTANT ILEN : arr_ilen(0 TO 255) :=(
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,1,  -- 00
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,1,  -- 10
    2,2,2,2,    2,2,2,2,    3,3,3,1,    1,1,0,0,  -- 20
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0,  -- 30
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0,  -- 40
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0,  -- 50
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,1,  -- 60
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,1,  -- 70
    2,2,2,2,    2,2,2,2,    1,1,1,1,    1,1,1,2,  -- 80
    2,2,2,2,    2,2,2,2,    2,2,2,2,    2,2,2,2,  -- 90
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,1,  -- a0
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,1,  -- b0
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0,  -- c0
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0,  -- d0
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0,  -- e0
    1,1,1,1,    1,1,1,1,    1,1,1,1,    1,1,1,0); -- f0
  
END PACKAGE;

PACKAGE BODY f8_pack IS
  FUNCTION test_bf(op    : uv4;
                   iozcs : uv5) RETURN boolean IS
  BEGIN
    -- all selected flags must be clear, icb excluded
    -- lr w,j can load z=1,s=0
    RETURN (iozcs(3 DOWNTO 0) AND op) = 0;
  END FUNCTION;

  FUNCTION test_bt(op    : uv3;
                   iozcs : uv5) RETURN boolean IS
  BEGIN
    -- branch if any selected flag is set
    RETURN (iozcs(2 DOWNTO 0) AND op) /= 0;
  END FUNCTION;


  PROCEDURE aluop(op : IN enum_op;
                  code : IN uv8;
                  src1 : IN uv8;   -- source and destination register
                  src2 : IN uv8;
                  iozcs_i : IN uv5;
                  dst  : OUT uv8;
                  dstm : OUT std_logic; -- modified result reg
                  iozcs_o : OUT uv5;
                  test : OUT std_logic) IS
    VARIABLE dst_v : uv8;
    VARIABLE dst9_v : uv9;
    VARIABLE tc_v,tic_v : boolean;
  BEGIN

    iozcs_o:=iozcs_i;
    dstm:='0';
    test:='0';

    CASE op IS
      WHEN OP_ADD =>
        dst9_v:=('0' & src1) + ('0' & src2);
        iozcs_o(0):=NOT dst9_v(7);
        iozcs_o(1):=dst9_v(8);
        iozcs_o(2):=to_std_logic(dst9_v(7 DOWNTO 0)=x"00");
        iozcs_o(3):=(src1(7) XNOR src2(7)) AND (src1(7) XOR dst9_v(7));
        dstm:='1';
        dst_v:=dst9_v(7 DOWNTO 0);

      WHEN OP_ADDD =>
        dst9_v:=('0' & src1) + ('0' & src2);
        iozcs_o(0):=NOT dst9_v(7);
        iozcs_o(1):=dst9_v(8);
        iozcs_o(2):=to_std_logic(dst9_v(7 DOWNTO 0)=x"00");
        iozcs_o(3):=(src1(7) XNOR src2(7)) AND (src1(7) XOR dst9_v(7));

        tc_v :=(((('0' & src1) + ('0' & src2)) AND "111110000") > "011110000");
        tic_v:=(('0' & src1(3 DOWNTO 0)) + ('0' & src2(3 DOWNTO 0))> "01111");

        dst_v:=src1 + src2;
        IF NOT tc_v AND NOT tic_v THEN
          dst_v:=((dst_v + x"A0") AND x"F0") + ((dst_v + x"0A") AND x"0F");
        ELSIF NOT tc_v AND tic_v THEN
          dst_v:=((dst_v + x"A0") AND x"F0") + (dst_v AND x"0F");
        ELSIF tc_v AND NOT tic_v THEN
          dst_v:=(dst_v AND x"F0") + ((dst_v + x"0A") AND x"0F");
        END IF;
        dstm:='1';

      WHEN OP_CMP =>
        dst9_v:=(('0' & NOT src1) + ('0' & src2)) + 1;
        iozcs_o(0):=NOT dst9_v(7);
        iozcs_o(1):=dst9_v(8);
        iozcs_o(2):=to_std_logic(dst9_v(7 DOWNTO 0)=x"00");
        iozcs_o(3):=(NOT src1(7) XNOR src2(7)) AND (NOT src1(7) XOR dst9_v(7));
        dstm:='0';

      WHEN OP_AND =>
        dst_v:=src1 AND src2;
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_OR =>
        dst_v:=src1 OR src2;
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_XOR =>
        dst_v:=src1 XOR src2;
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_DEC =>
        dst9_v:=('0' & src1) + ('0' & x"FF");
        iozcs_o(0):=NOT dst9_v(7);
        iozcs_o(1):=dst9_v(8);
        iozcs_o(2):=to_std_logic(dst9_v(7 DOWNTO 0)=x"00");
        iozcs_o(3):=(src1(7) XOR dst9_v(7)) AND (NOT dst9_v(7));
        dstm:='1';
        dst_v:=dst9_v(7 DOWNTO 0);
        
      WHEN OP_SL1 =>
        dst_v:=src1(6 DOWNTO 0) & '0';
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_SL4 =>
        dst_v:=src1(3 DOWNTO 0) & x"0";
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_SR1 =>
        dst_v:='0' & src1(7 DOWNTO 1);
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_SR4 =>
        dst_v:=x"0" & src1(7 DOWNTO 4);
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_COM =>
        dst_v:=NOT src1;
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_LNK =>
        dst9_v:=('0' & src1) + ('0' & iozcs_i(1));
        iozcs_o(0):=NOT dst9_v(7);
        iozcs_o(1):=dst9_v(8);
        iozcs_o(2):=to_std_logic(dst9_v(7 DOWNTO 0)=x"00");
        iozcs_o(3):=(src1(7) XNOR '0') AND (src1(7) XOR dst9_v(7));
        dstm:='1';
        dst_v:=dst9_v(7 DOWNTO 0);

      WHEN OP_INC =>
        dst9_v:=('0' & src1) + 1;
        iozcs_o(0):=NOT dst9_v(7);
        iozcs_o(1):=dst9_v(8);
        iozcs_o(2):=to_std_logic(dst9_v(7 DOWNTO 0)=x"00");
        iozcs_o(3):=(src1(7) XNOR '0') AND (src1(7) XOR dst9_v(7));
        dstm:='1';
        dst_v:=dst9_v(7 DOWNTO 0);

      WHEN OP_EDI =>
        iozcs_o(4):=code(0);

      WHEN OP_LIS =>
        dst_v:=x"0" & code(3 DOWNTO 0);
        dstm:='1';

      WHEN OP_TST8 =>
        test:=to_std_logic(test_bt(code(2 DOWNTO 0),iozcs_i));

      WHEN OP_TST9 =>
        test:=to_std_logic(test_bf(code(3 DOWNTO 0),iozcs_i));
        dstm:='0';

      WHEN OP_NOP =>
        dstm:='0';

      WHEN OP_MOI => 
        dst_v:=src2;
        iozcs_o(0):=NOT dst_v(7);
        iozcs_o(1):='0';
        iozcs_o(2):=to_std_logic(dst_v=x"00");
        iozcs_o(3):='0';
        dstm:='1';

      WHEN OP_MOV => 
        dst_v:=src2;
        dstm:='1';

    END CASE;

    dst:=dst_v;
  END PROCEDURE;


END PACKAGE BODY;
