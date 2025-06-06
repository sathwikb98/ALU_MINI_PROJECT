# ALU_MINI_PROJECT
About ALU project carried out @mirafra-technologies [Manipal] during internship......

# Introduction 
This project is a custom Arithmetic Logic Unit (ALU) developed as part of an internship program at Mirafra Technologies. The ALU is designed in SystemVerilog and supports both arithmetic and logical operations. The module takes configurable parameters, handles pipelining and status flag generation, and supports verification through structured stimulus input.

The ALU operates on two operands (OPA, OPB) of configurable bit width (WIDTH_OP), and supports both combinational and pipelined behaviors based on control signals. It also includes status flags such as ERR, OFLOW, COUT, G, L, and E to provide diagnostic and comparison outputs.

#Objective
To design and implement a parameterizable ALU in SystemVerilog.

To support a wide range of operations (arithmetic, logical, shift, and rotation).

To ensure valid input handling and flag generation (OFLOW, ERR, etc.).

To verify the ALU using a self-checking testbench based on structured stimuli.

To enable mode-based operation:

- Arithmetic Mode (MODE = 1)

- Logical Mode (MODE = 0)
