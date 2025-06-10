# ALU_Design
# Parameterized ALU Design in Verilog

This repository contains the design, reference model, and verification environment for a parameterized Arithmetic Logic Unit (ALU). The ALU supports both arithmetic and logical operations based on a 4-bit command input and operates on parameterized input widths (default 8-bit) and generates a wider result (16-bit).

---

# Features

- **Parameterized Input/Output Widths**
- **Supports Arithmetic and Logical Modes**
-  27 operations including:
   - Addition, Subtraction (signed/unsigned), Compare, Overflow Detection
   - AND, OR, XOR, NOT, NOR, NAND, XNOR
   - Shift/Rotate Left & Right
- Flag outputs:
   - Carry-out (COUT)
   - Overflow (OFLOW)
   - Comparison flags (G, E, L)
   - Error flag (ERR)
