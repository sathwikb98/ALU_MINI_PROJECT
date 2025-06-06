# ALU_MINI_PROJECT
About ALU project carried out @mirafra-technologies [Manipal] during internship......

# Introduction : 
This project is a custom Arithmetic Logic Unit (ALU) developed as part of an internship program at Mirafra Technologies. The ALU is designed in Verilog and supports both arithmetic and logical operations. The module takes configurable parameters, handles pipelining and status flag generation, and supports verification through structured stimulus input.

The ALU operates on two operands (OPA, OPB) of configurable bit width (WIDTH_OP), and supports both combinational and pipelined behaviors based on control signals. It also includes status flags such as ERR, OFLOW, COUT, G, L, and E to provide diagnostic and comparison outputs.

#Objective :
- To design and implement a parameterizable ALU in Verilog.

- To support a wide range of operations (arithmetic, logical, shift, and rotation).

- To ensure valid input handling and flag generation (OFLOW, ERR, etc.).

- To verify the ALU using a self-checking testbench based on structured stimuli.

- To enable mode-based operation:

  - Arithmetic Mode (MODE = 1)

  - Logical Mode (MODE = 0)

# ALU operation command list :
The ALU uses a "4-bit CMD" input to select from various operations. Below is the list grouped by category:

1. Arithmetic Operations (MODE = 1)

| CMD | Operation    | Description                                |
| --- | ------------ | ------------------------------------------ |
| 0   | `ADD`        | Addition: `OPA + OPB`                      |
| 1   | `SUB`        | Subtraction: `OPA - OPB`                   |
| 2   | `ADD_CIN`    | Addition with carry: `OPA + OPB + CIN`     |
| 3   | `SUB_CIN`    | Subtraction with borrow: `OPA - OPB - CIN` |
| 4   | `INC_A`      | Increment A                                |
| 5   | `DEC_A`      | Decrement A                                |
| 6   | `INC_B`      | Increment B                                |
| 7   | `DEC_B`      | Decrement B                                |
| 8   | `CMP`        | Compare A and B → Sets G, L, E flags       |
| 9   | `INCR_MULT`  | `(OPA+1)*(OPB+1)`                          |
| 10  | `SHIFT_MULT` | `(OPA << 1) * OPB`                         |
| 11  | `SIGN_ADD`   | Signed Addition                            |
| 12  | `SIGN_SUB`   | Signed Subtraction                         |

2. Logical Operations (MODE = 0)

| CMD | Operation | Description                   |
| --- | --------- | ----------------------------- |
| 0   | `AND`     | Bitwise AND                   |
| 1   | `NAND`    | Bitwise NAND                  |
| 2   | `OR`      | Bitwise OR                    |
| 3   | `NOR`     | Bitwise NOR                   |
| 4   | `XOR`     | Bitwise XOR                   |
| 5   | `XNOR`    | Bitwise XNOR                  |
| 6   | `NOT_A`   | Bitwise NOT on A              |
| 7   | `NOT_B`   | Bitwise NOT on B              |
| 8   | `SHR1_A`  | Shift right A by 1            |
| 9   | `SHL1_A`  | Shift left A by 1             |
| 10  | `SHR1_B`  | Shift right B by 1            |
| 11  | `SHL1_B`  | Shift left B by 1             |
| 12  | `ROL_A_B` | Rotate left A by amount in B  |
| 13  | `ROR_A_B` | Rotate right A by amount in B |  

# Output Flags :
- ERR – Error if invalid inputs are detected

- OFLOW – Overflow flag for arithmetic operations

- COUT – Carry out flag

- G – Greater-than flag from CMP

- L – Less-than flag from CMP

- E – Equal flag from CMP

# File in the project :

| File Name        | Description                                                          |
| ---------------  | ---------------------------------------------------------------------|
| `ALU_DESIGN.v`   | Main ALU design file                                                 |
| `CMD.vh`         | Macro definitions for command codes                                  |
| `ALU_SELF_TB.v`  | Self-checking testbench with packets as 'stimulus'                   |
| `stimulus.txt`   | Input vectors                                                        |
| `result.txt`     | Generated result file by the testbench                               |
| `README.md`      | This file                                                            |
| `Block diagrams` | This contains design & testbench architecture and Flow chart         |  


