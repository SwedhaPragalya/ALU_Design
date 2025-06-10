`define WIDTH 'd8
`define RES_WIDTH 'd16
`define CMD_WIDTH  'd4
`define SHIFT 'd2
`define DEFAULT 1'b0

// MODE 1 COMMANDS
`define CMD_ADD 'd0
`define CMD_SUB 'd1
`define CMD_ADD_CIN 'd2
`define CMD_SUB_CIN 'd3
`define CMD_INC_A 'd4
`define CMD_DEC_A 'd5
`define CMD_INC_B 'd6
`define CMD_DEC_B 'd7
`define CMD_CMP 'd8
`define CMD_INC_MULT 'd9
`define CMD_SFT_MULT 'd10 //for shifting a and multiply
`define CMD_SIGN_ADD 'd11
`define CMD_SIGN_SUB 'd12

// MODE 0 COMMANDS
`define CMD_AND 'd0
`define CMD_NAND 'd1
`define CMD_OR 'd2
`define CMD_NOR 'd3
`define CMD_XOR 'd4
`define CMD_XNOR 'd5
`define CMD_NOT_A 'd6
`define CMD_NOT_B 'd7
`define CMD_SHR1_A 'd8
`define CMD_SHL1_A 'd9
`define CMD_SHR1_B 'd10 //for shifting a and multiply
`define CMD_SHL1_B 'd11
`define CMD_ROL_B 'd12
`define CMD_ROR_B 'd13

//for reference model
`define FORMAT_STR "%08b_%01b_%08b_%08b_%04b_%02b_%01b_%01b_%01b_%016b_%01b_%03b_%01b_%01b"

//for tb
`define PASS 1'b1
`define FAIL 1'b0
`define OPWIDTH 14 // WIDTH+6
`define FEATURE_ID_START 55
`define FEATURE_ID_END 48
`define RST_INDEX 47
`define OPA_START 46
`define OPA_END 39
`define OPB_START 38
`define OPB_END 31
`define CMD_START 30
`define CMD_END 27
`define INP_VALID_START 26
`define INP_VALID_END 25
`define CIN_INDEX 24
`define CE_INDEX 23
`define MODE_INDEX 22
`define EXP_RES_START 21
`define EXP_RES_END 6
`define COUT_INDEX 5
`define GEL_START 4
`define GEL_END 2
`define OV_INDEX 1
`define ERR_INDEX 0
`define CURR_TC_BITS 69
`define RES_PAC_BITS 91
`define no_of_testcase 132


