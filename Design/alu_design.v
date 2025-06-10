`include "define.v"

module alu(OPA, OPB, CIN,INP_VALID, CLK, RST, CMD, CE, MODE, COUT, OFLOW, RES, G, E, L, ERR);

    input [`WIDTH-1:0] OPA, OPB;
    input CLK, RST, CE, MODE, CIN;
    input [1:0] INP_VALID;
    input [`CMD_WIDTH-1:0] CMD;

    output reg [`RES_WIDTH-1:0] RES = {`RES_WIDTH{`DEFAULT}};
    output reg COUT = `DEFAULT;
    output reg OFLOW = `DEFAULT;
    output reg G = `DEFAULT;
    output reg E = `DEFAULT;
    output reg L = `DEFAULT;
    output reg ERR = `DEFAULT;

    reg [`RES_WIDTH-1:0] RES_next;
    reg COUT_next, OFLOW_next, G_next, E_next, L_next, ERR_next;

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            RES <= {`RES_WIDTH{`DEFAULT}};
            COUT <= `DEFAULT;
            OFLOW <= `DEFAULT;
            G <= `DEFAULT;
            E <= `DEFAULT;
            L <= `DEFAULT;
            ERR <= `DEFAULT;
        end
        else begin
                RES <= RES_next;
                COUT <= COUT_next;
                OFLOW <= OFLOW_next;
                G <= G_next;
                E <= E_next;
                L <= L_next;
                ERR <= ERR_next;
        end
    end

    always @(posedge CLK) begin
        RES_next = {`RES_WIDTH{`DEFAULT}};
        COUT_next = `DEFAULT;
        OFLOW_next = `DEFAULT;
        G_next = `DEFAULT;
        E_next = `DEFAULT;
        L_next = `DEFAULT;
        ERR_next = `DEFAULT;

        if (CE) begin
            if (MODE) begin
                case (CMD)
                   `CMD_ADD: begin
                        if (INP_VALID == 'b11) begin
                            RES_next = OPA+ OPB;
                            COUT_next = RES_next[8];// ? 1 : 0;
                        end
                        //else ;
                   end
                   `CMD_SUB: begin
                        if (INP_VALID == 'b11) begin
                            OFLOW_next = (OPA < OPB);
                            RES_next = OPA - OPB;
                        end
                        //else ;
                   end
                   `CMD_ADD_CIN: begin
                        if (INP_VALID == 'b11) begin
                            RES_next = OPA + OPB + CIN;
                            COUT_next = RES_next[8];
                        end
                        //else ;
                   end
                   `CMD_SUB_CIN: begin
                        if (INP_VALID == 'b11) begin
                            OFLOW_next = (OPA < (OPB + CIN));
                            RES_next = OPA - OPB - CIN;
                        end
                        //else ;
                   end
                   `CMD_INC_A:  begin
                        if (INP_VALID[0] == 'b1) begin
                            RES_next = OPA + 1;
                        end
                        //else ;
                   end
                   `CMD_DEC_A: begin
                        if (INP_VALID[0] == 'b1) begin
                            RES_next = OPA - 1;
                            if (OPA == {`WIDTH{1'b0}}) OFLOW_next = 1;
                        end
                        //else ;
                   end
                   `CMD_INC_B: begin
                        if (INP_VALID[1] == 'b1) begin
                            RES_next = OPB + 1;
                        end
                        //else ;
                   end
                   `CMD_DEC_B: begin
                        if (INP_VALID[1] == 'b1) begin
                            RES_next = OPB - 1;
                            if (OPB == {`WIDTH{1'b0}}) OFLOW_next = 1;
                        end
                        //else ;
                   end
                   `CMD_CMP: begin
                        if (INP_VALID == 'b11) begin
                            if (OPA == OPB) begin
                                E_next = 1'b1;
                                G_next = `DEFAULT;
                                L_next = `DEFAULT;
                            end
                            else if (OPA > OPB) begin
                                E_next = `DEFAULT;
                                G_next = 1'b1;
                                L_next = `DEFAULT;
                            end
                            else begin
                                E_next = `DEFAULT;
                                G_next = `DEFAULT;
                                L_next = 1'b1;
                            end
                        end
                        //else ;
                   end
                   `CMD_INC_MULT: begin
                        if (INP_VALID == 'b11) begin
                            RES_next = (OPA + 1) * (OPB + 1);
                        end
                        //else ;
                   end
                   `CMD_SFT_MULT: begin
                        if (INP_VALID == 'b11) begin
                            RES_next = (OPA << 1) * (OPB);
                        end
                        //else ;
                   end
                   `CMD_SIGN_ADD: begin
                        if (INP_VALID == 'b11) begin
                            RES_next = $signed(OPA) + $signed(OPB);
                            OFLOW_next =((OPA[7] == OPB[7]) && (RES_next[7] != OPA[7]));
                            COUT_next = RES_next[8];
                            if ($signed(RES_next) < 0) L_next = 1'b1;
                            else if ($signed(RES_next) > 0) G_next = 1'b1;
                            else E_next = 1'b1;
                        end
                        //else ;
                   end
                   `CMD_SIGN_SUB: begin
                        if (INP_VALID == 'b11) begin
                            RES_next = $signed(OPA) - $signed(OPB);
                            OFLOW_next = ((OPA[7] != OPB[7]) && (RES_next[7] != OPA[7]));
                            COUT_next = RES_next[8];
                            if ($signed(RES_next) < 0) L_next = 1'b1;
                            else if ($signed(RES_next) > 0) G_next = 1'b1;
                            else E_next = 1'b1;
                        end
                        //else ;
                   end
                   default:;
               endcase
            end
            else begin
                case (CMD)
                    `CMD_AND:begin
                        if (INP_VALID == 'b11) RES_next = {1'b0, OPA & OPB};
                        //else ;
                    end
                    `CMD_NAND:begin
                        if (INP_VALID == 'b11) RES_next = {1'b0, ~(OPA & OPB)};
                        //else ;
                    end
                    `CMD_OR:begin
                        if (INP_VALID == 'b11)RES_next = {1'b0, OPA | OPB};
                        //else ;
                    end
                    `CMD_NOR:begin
                        if (INP_VALID == 'b11)RES_next = {1'b0, ~(OPA | OPB)};
                        //else ;
                    end
                    `CMD_XOR:begin
                        if (INP_VALID == 'b11) RES_next = {1'b0, OPA ^ OPB};
                        //else ;
                    end
                    `CMD_XNOR:begin
                        if (INP_VALID == 'b11) RES_next = {1'b0, ~(OPA ^ OPB)};
                        //else ;
                    end
                    `CMD_NOT_A:begin
                        if (INP_VALID[0] == 'b1)
                            RES_next = ~OPA &{`WIDTH {1'b1}};
                        //else ;
                    end
                    `CMD_NOT_B:begin
                        if (INP_VALID[1] == 'b1)
                            RES_next =  ~OPB&{`WIDTH{1'b1}};
                        //else ;
                    end
                    `CMD_SHR1_A:begin
                        if (INP_VALID[0] == 'b1)
                            RES_next = (OPA >> 1) &{`WIDTH{1'b1}} ;
                        //else ;
                    end
                    `CMD_SHL1_A:begin
                        if (INP_VALID[0] == 'b1)
                            RES_next = (OPA << 1)&{`WIDTH{1'b1}};
                        //else ;
                    end
                    `CMD_SHR1_B:begin
                        if (INP_VALID[1] == 'b1)
                            RES_next = (OPB >> 1)&{`WIDTH{1'b1}};
                        //else ;
                    end
                    `CMD_SHL1_B:begin
                        if (INP_VALID[1] == 'b1)
                            RES_next = (OPB << 1)&{`WIDTH{1'b1}};
                        //else ;
                    end
                    `CMD_ROL_B:begin
                        if (INP_VALID == 'b11) begin
                            if (!(|OPB[`WIDTH-1:`SHIFT+1])) begin
                                RES_next = ((OPA <<  OPB[`SHIFT:0]) | (OPA >> (`WIDTH -  OPB[`SHIFT:0])))&{`WIDTH{1'b1}};
                            end
                            else ERR_next = 1'b1;
                        end
                        //else ;
                    end
                    `CMD_ROR_B:begin
                        if (INP_VALID == 'b11) begin
                            if (!(|OPB[`WIDTH-1:`SHIFT+1])) begin
                                RES_next = ((OPA >> OPB[`SHIFT:0]) | (OPA << (`WIDTH - OPB[`SHIFT:0]))) &{`WIDTH{1'b1}};
                            end
                            else ERR_next = 1'b1;
                        end
                        //else ;
                    end
                    default: ;
                endcase
            end
            if(!(MODE == 1 && (CMD == `CMD_SFT_MULT || CMD == `CMD_INC_MULT || CMD == `CMD_SIGN_SUB || CMD == `CMD_SIGN_ADD)))
                RES_next = RES_next & {`WIDTH{1'b1}};
        end
    end
endmodule
