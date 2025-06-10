`include "define.v"
module alu_ref_model(
    input [`WIDTH-1:0] OPA,
    input [`WIDTH-1:0] OPB,
    input CIN,
    input CLK,
    input RST,
    input [1:0] INP_VALID,
    input [`CMD_WIDTH-1:0] CMD,
    input CE,
    input MODE,
    output reg [`RES_WIDTH-1:0] RES_expected,
    output reg COUT_expected,
    output reg OFLOW_expected,
    output reg G_expected,
    output reg E_expected,
    output reg L_expected,
    output reg ERR_expected
);

    // Task to compute expected outputs
    task compute_expected_outputs;
        input [`WIDTH-1:0] OPA;
        input [`WIDTH-1:0] OPB;
        input cin_in;
        input [1:0] INP_VALID;
        input rst_in;
        input [`CMD_WIDTH-1:0] cmd_in;
        input ce_in;
        input mode_in;
        output reg cout_out;
        output reg oflow_out;
        output reg [`RES_WIDTH-1:0] res_out;
        output reg g_out;
        output reg e_out;
        output reg l_out;
        output reg err_out;
        integer rotate;
        begin
            // Initialize outputs to 0
            if (rst_in) begin
                    // Reset condition - all outputs 0
                    res_out = {`RES_WIDTH{`DEFAULT}};
                    cout_out = `DEFAULT;
                    oflow_out = `DEFAULT;
                    g_out = `DEFAULT;
                    e_out = `DEFAULT;
                    l_out = `DEFAULT;
                    err_out = `DEFAULT;
             end

             else begin
                res_out = {`RES_WIDTH{`DEFAULT}};
                cout_out = `DEFAULT;
                oflow_out = `DEFAULT;
                g_out = `DEFAULT;
                e_out = `DEFAULT;
                l_out = `DEFAULT;
                err_out = `DEFAULT;
                if (ce_in) begin
                    if(mode_in) begin
                    // Arithmetic operations (MODE = 1)
                    case (cmd_in)
                        `CMD_ADD: begin // ADD
                             if (INP_VALID == 'b11) begin
                                res_out = OPA+ OPB;
                                cout_out = res_out[8] ? 1 : 0;
                            end
                            else ;
                        end

                        `CMD_SUB: begin // SUB
                            if (INP_VALID == 'b11) begin
                                oflow_out = (OPA < OPB) ? 1 : 0;
                                res_out = OPA - OPB;
                            end
                            else ;
                            end

                        `CMD_ADD_CIN: begin
                            if (INP_VALID == 'b11) begin
                                res_out = OPA + OPB + cin_in;
                                cout_out = res_out[`WIDTH] ? 1 : 0;
                            end
                            else ;
                            end

                        `CMD_SUB_CIN: begin // SUB_CIN
                            if (INP_VALID == 'b11) begin
                                oflow_out = (OPA < (OPB + cin_in)) ? 1 : 0;
                                res_out = OPA - OPB - cin_in;
                            end
                            else ;
                        end

                        `CMD_INC_A: // INC_A
                        begin
                            if (INP_VALID[0] == 'b1) begin
                                res_out = OPA + 1;
                            end
                            else ;
                        end

                        `CMD_DEC_A:  // DEC_A
                                    begin
                            if (INP_VALID[0] == 'b1) begin
                                res_out = OPA - 1;
                                if (OPA == {`WIDTH{1'b0}}) oflow_out = 1;
                            end
                            else ;
                            end

                        `CMD_INC_B:  // INC_B
                                    begin
                            if (INP_VALID[1] == 'b1) begin
                                res_out = OPB + 1;
                            end
                            else ;
                        end

                        `CMD_DEC_B:  // DEC_B
                        begin
                            if (INP_VALID[1] == 'b1) begin
                                res_out = OPB - 1;
                                if (OPB == {`WIDTH{1'b0}}) oflow_out = 1;
                            end
                            else ;
                        end

                        `CMD_CMP:  // CMP
                        begin
                            if (INP_VALID == 'b11) begin
                                if (OPA == OPB) begin
                                    e_out = 1'b1;
                                    g_out = `DEFAULT;
                                    l_out = `DEFAULT;
                                end
                                else if (OPA > OPB) begin
                                    e_out = `DEFAULT;
                                    g_out = 1'b1;
                                    l_out = `DEFAULT;
                                end
                                else begin
                                    e_out = `DEFAULT;
                                    g_out = `DEFAULT;
                                    l_out = 1'b1;
                                end
                            end
                            else ;
                            end

                       `CMD_INC_MULT: begin
                            if (INP_VALID == 'b11) begin
                                res_out = (OPA + 1) * (OPB +1);
                            end
                            else ;
                       end

                       `CMD_SFT_MULT: begin
                            if (INP_VALID == 'b11) begin
                                res_out = (OPA << 1) * (OPB);
                            end
                            else ;
                       end

                       `CMD_SIGN_ADD: begin
                            if (INP_VALID == 'b11) begin
                                res_out = $signed(OPA) + $signed(OPB);
                                oflow_out =((OPA[7] == OPB[7]) && (res_out[7] != OPA[7]))? 1'b1:1'b0;
                                cout_out = res_out[8] ? 1 : 0;
                                if ($signed(res_out) < 0) l_out = 1'b1;
                                else if ($signed(res_out) > 0) g_out = 1'b1;
                                else e_out = 1'b1;
                            end
                            else ;
                       end

                       `CMD_SIGN_SUB: begin
                            if (INP_VALID == 'b11) begin
                                res_out = $signed(OPA) - $signed(OPB);
                                oflow_out = ((OPA[7] != OPB[7]) && (res_out[7] != OPA[7])) ? 1 : 0;
                                cout_out = res_out[8] ? 1 : 0;
                                if ($signed(res_out) < 0) l_out = 1'b1;
                                else if ($signed(res_out) > 0) g_out = 1'b1;
                                else e_out = 1'b1;
                            end
                            else ;
                       end

                       default:;
                    endcase
                end
                else begin
                    // Logical operations (MODE = 0)
                    case (cmd_in)
                        `CMD_AND: begin
                            if (INP_VALID == 'b11) res_out = {1'b0, OPA & OPB};
                            else ;
                        end
                        `CMD_NAND: begin
                            if (INP_VALID == 'b11) res_out = {1'b0, ~(OPA & OPB)};
                            else ;
                        end
                        `CMD_OR: begin
                            if (INP_VALID == 'b11) res_out = {1'b0, OPA | OPB};
                            else ;
                        end
                        `CMD_NOR: begin
                            if (INP_VALID == 'b11) res_out = {1'b0, ~(OPA | OPB)};
                            else ;
                        end
                        `CMD_XOR:begin
                            if (INP_VALID == 'b11) res_out = {1'b0, OPA ^ OPB};
                            else ;
                        end
                        `CMD_XNOR: begin
                            if (INP_VALID == 'b11) res_out = {1'b0, ~(OPA ^ OPB)};
                            else ;
                        end
                        `CMD_NOT_A:begin
                            if (INP_VALID[0] == 'b1)
                                res_out = ~OPA &{`WIDTH {1'b1}};
                            else ;
                        end
                        `CMD_NOT_B:begin
                            if (INP_VALID[1] == 'b1)
                                res_out =  ~OPB&{`WIDTH{1'b1}};
                            else ;
                        end
                        `CMD_SHR1_A:begin
                            if (INP_VALID[0] == 'b1)
                                res_out = (OPA >> 1) &{`WIDTH{1'b1}} ;
                            else ;
                        end
                        `CMD_SHL1_A:begin
                            if (INP_VALID[0] == 'b1)
                                res_out = (OPA << 1)&{`WIDTH{1'b1}};
                            else ;
                        end
                        `CMD_SHR1_B:begin
                            if (INP_VALID[1] == 'b1)
                                res_out = (OPB >> 1)&{`WIDTH{1'b1}};
                            else ;
                        end
                        `CMD_SHL1_B:begin
                            if (INP_VALID[1] == 'b1)
                                res_out = (OPB << 1)&{`WIDTH{1'b1}};
                            else ;
                        end
                        `CMD_ROL_B:begin
                            if (INP_VALID == 'b11) begin
                                if (!(|OPB[`WIDTH-1:`SHIFT+1])) begin
                                    rotate = OPB[`SHIFT:0];
                                    res_out = ((OPA << rotate) | (OPA >> (`WIDTH - rotate)))&{`WIDTH{1'b1}};//res_out = {OPA[`WIDTH-rotate:0], OPA[`WIDTH:`WIDTH-rotate-1]};
                                end
                                else err_out = 1'b1;
                            end
                            else ;
                        end
                        `CMD_ROR_B:begin
                            if (INP_VALID == 'b11) begin
                                if (!(|OPB[`WIDTH-1:`SHIFT+1])) begin
                                    rotate = OPB[`SHIFT:0];
                                    res_out = ((OPA >> rotate) | (OPA << (`WIDTH - rotate))) &{`WIDTH{1'b1}};//res_out = {OPA[rotate-1:0], OPA[`WIDTH:rotate]};
                                end
                                else err_out = 1'b1;
                            end
                            else ;
                        end
                        default: ;
                    endcase
                end
                 if(!(mode_in == 1 && (cmd_in == 'b1001 || cmd_in == 'b1010))) res_out= res_out & {{`WIDTH{1'b0}},{`WIDTH{1'b1}}};
       end
        else begin
                res_out = {`RES_WIDTH{`DEFAULT}};
                cout_out = `DEFAULT;
                oflow_out = `DEFAULT;
                g_out = `DEFAULT;
                e_out = `DEFAULT;
                l_out = `DEFAULT;
                err_out = `DEFAULT;
        end
        end
        end
    endtask

    // Continuous assignment to compute expected outputs
    always @(*) begin
        compute_expected_outputs(
            OPA, OPB, CIN,INP_VALID ,RST,CMD, MODE,  CE,
            RES_expected, COUT_expected, OFLOW_expected,
            G_expected, E_expected, L_expected, ERR_expected
        );
    end

    reg [`CMD_WIDTH-1:0] cmd;
    reg [`WIDTH-1:0] opa_in, opb_in,opa_ini,opb_ini;
    reg cin;
    reg rst;
    reg [1:0] inp_valid;
    reg mode;
    reg ce;
    integer file;
    reg [7:0] fid;
    integer i;

    initial begin
      file = $fopen("stimulus.txt", "w");
      if (file == 0) begin
          $display("ERROR: Could not open stimulus.txt");
          $finish;
      end
  
      // Reset test case
      fid  = 8'h00;
      rst  = 1'b1;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
      rst = 1'b0;
  
      // Fixed inputs opa =255;opb =255
      opa_in    = 8'b11111111;
      opb_in    = 8'b11111111;
      cin       = 1'b0;
      inp_valid = 2'b11;
      ce        = 1'b1;
      mode      = 1'b1;
      // mode = 1
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      //mode = 0
      mode = 1'b0;
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      //mode = 1, cin = 1, cmd 2–3
      mode = 1'b1;
      cin  = 1'b1;
      for (cmd = 4'b0010; cmd < 4'b0011; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
  
     //opa and opb = 000
      opa_in    = 0;
      opb_in    = 0;
      cin       = 1'b0;
      inp_valid = 2'b11;
      ce        = 1'b1;
      mode      = 1'b1;
      // mode = 1
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      //mode = 0
      mode = 1'b0;
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      mode = 1'b1;
      cin  = 1'b1;
      for (cmd = 4'b0010; cmd < 4'b0011; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
  
      // random inputs,opb > opa 
      // mode = 1
      mode = 1'b1;
      while (opa_in <= opb_in)begin
          opa_in = $random & 8'hFF;
          opb_in = $random & 8'hFF;
      end
      cin = 1'b0;
      inp_valid = 2'b11;
      ce = 1'b1;
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      // mode = 0
      mode = 1'b0;
      for (cmd = 0; cmd < 4'b1111 && fid < 63; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      //mode = 1, cin = 1, cmd 2–3 
      mode = 1'b1;
      cin  = 1'b1;
      for (cmd = 4'b0010; cmd < 4'b0011; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
   
      //random testcase: opb < opa
      //mode = 1
      mode = 1'b1;
      while (opa_in >= opb_in)begin
          opa_in = $random & 8'hFF;
          opb_in = $random & 8'hFF;
      end
      cin = 1'b0;
      inp_valid = 2'b11;
      ce = 1'b1;
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      // mode = 0
      mode = 1'b0;
      for (cmd = 0; cmd < 4'b1111 && fid < 63; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      // mode = 1, cin = 1, cmd 2–3 
      mode = 1'b1;
      cin  = 1'b1;
      for (cmd = 4'b0010; cmd < 4'b0011; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
  
      //inp_valid = 00
      //mode = 1
      inp_valid = 2'b00;
      ce = 1'b1;
      mode = 1'b1;
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
      // mode = 0
      mode = 1'b0;
      for (cmd = 0; cmd < 4'b1111; cmd = cmd + 1) begin
          compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                                   COUT_expected, OFLOW_expected, RES_expected,
                                   G_expected, E_expected, L_expected, ERR_expected);
          $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                    ce, mode, RES_expected, COUT_expected,
                    {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
          fid = fid + 1;
      end
  
      // Extra fixed test cases
      opa_in    = 8'd127;
      opb_in    = 8'd1;
      cmd       = 4'b1011;
      mode      = 1;
      cin       = 0;
      inp_valid = 2'b11;
      ce        = 1;
      rst       = 0;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
  
      opa_in  = 8'd129 ;
      opb_in = 1;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
  
      opa_in    = 8'd127;
      opb_in    = 8'd1;
      cmd = 4'b1100;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
  
      opb_in  = 8'd128 ;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
  
      opa_in  = 8'd129 ;
      opb_in = 1;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
  
      cmd =12;mode =0;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
      fid = fid + 1;
  
      ce = 0;
      compute_expected_outputs(opa_in, opb_in, cin, inp_valid, rst, cmd, mode, ce,
                               COUT_expected, OFLOW_expected, RES_expected,
                               G_expected, E_expected, L_expected, ERR_expected);
      $fdisplay(file, `FORMAT_STR, fid, rst, opa_in, opb_in, cmd, inp_valid, cin,
                ce, mode, RES_expected, COUT_expected,
                {G_expected, E_expected, L_expected}, OFLOW_expected, ERR_expected);
  
      fid = fid + 1;
      $fclose(file);
      $display("Simulation completed.");
      $finish;
    end

endmodule
