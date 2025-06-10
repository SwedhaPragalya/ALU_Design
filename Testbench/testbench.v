`include "define.v"
`include "alu_design.v"

module alu_tb();
    reg [`CURR_TC_BITS-1:0] curr_test_case = {`CURR_TC_BITS{1'b0}};
    reg [`CURR_TC_BITS-1:0] stimulus_mem [0:`no_of_testcase-1];
    reg [`RES_PAC_BITS-1:0] response_packet;

    //Declaration for the Stimulus
    integer i, j;
    reg CLK, RST, CE;
    event fetch_stimulus;
    reg [`WIDTH-1:0] OPA, OPB;
    reg [`CMD_WIDTH-1:0] CMD;
    reg [1:0] INP_VALID;
    reg MODE, CIN;
    reg [7:0] Feature_ID;
    reg [2:0] Comparison_GEL;
    reg [15:0] Expected_RES;
    reg err, cout, ov;
    reg rst;

    //Declaration for dut
    wire [`RES_WIDTH-1:0] RES;
    wire ERR, OFLOW, COUT;
    wire [2:0] GEL;
    wire [21:0] expected_data;
    reg [21:0] exact_data;

    //READ DATA FROM THE TEXT VECTOR FILE	
    task read_stimulus();
        begin
            #10 $readmemb("stimulus.txt", stimulus_mem);
        end
    endtask

    //design instantiation
    alu dut(OPA, OPB, CIN,INP_VALID, CLK, RST, CMD, CE, MODE, COUT, OFLOW, RES, G, E, L, ERR);

    //FETCHING STIMULUS 
    integer stim_mem_ptr = 0, stim_stimulus_mem_ptr = 0, fid = 0, pointer = 0;
    always @(fetch_stimulus) begin
        curr_test_case = stimulus_mem[stim_mem_ptr];
        $display("stimulus_mem data = %69b \n", stimulus_mem[stim_mem_ptr]);
        $display("packet data = %69b \n", curr_test_case);
        stim_mem_ptr = stim_mem_ptr + 1;
    end

    //INITIALIZING CLOCK
    initial begin
        CLK = 0;
        forever #60 CLK = ~CLK;
    end

    //DRIVER MODULE
    task driver();
        begin
            ->fetch_stimulus;
            @(posedge CLK);
            Feature_ID     = curr_test_case[`FEATURE_ID_START:`FEATURE_ID_END];
            $display("Feature id - %b",Feature_ID);
            RST            = curr_test_case[`RST_INDEX];
            OPA            = curr_test_case[`OPA_START:`OPA_END];
            OPB            = curr_test_case[`OPB_START:`OPB_END];
            CMD            = curr_test_case[`CMD_START:`CMD_END];
            INP_VALID      = curr_test_case[`INP_VALID_START:`INP_VALID_END];
            CIN            = curr_test_case[`CIN_INDEX];
            CE             = curr_test_case[`CE_INDEX];
            MODE           = curr_test_case[`MODE_INDEX];
            Expected_RES   = curr_test_case[`EXP_RES_START:`EXP_RES_END];
            cout           = curr_test_case[`COUT_INDEX];
            Comparison_GEL = curr_test_case[`GEL_START:`GEL_END];
            ov             = curr_test_case[`OV_INDEX];
            err            = curr_test_case[`ERR_INDEX];
            $display("At time (%0t), Feature_ID = %8b, Reset = %1b, OPA = %8b, OPB = %8b, CMD = %4b, INP_VALID= %2b, CIN = %1b, CE = %1b, MODE = %1b, expected_result = %16b, cout = %1b, Comparison_GEL = %3b, ov = %1b, err = %1b",
         $time, Feature_ID, RST, OPA, OPB, CMD, INP_VALID, CIN, CE, MODE, Expected_RES, cout, Comparison_GEL, ov, err);
        end
    endtask

    //GLOBAL DUT RESET
    task dut_reset();
        begin
            CE = 1;
            #10 RST = 1;
            #20 RST = 0;
        end
    endtask

    //GLOBAL INITIALIZATION
    task global_init();
        begin
            curr_test_case = {`CURR_TC_BITS{1'b0}};
            response_packet = {`RES_PAC_BITS{1'b0}};
            stim_mem_ptr = 0;
        end
    endtask

//MONITOR PROGRAM
task monitor();
        begin
            repeat(3) @(posedge CLK);
            #5 response_packet[`FEATURE_ID_START:0] = curr_test_case;
            response_packet[`FEATURE_ID_START+1]     = ERR;
            response_packet[`FEATURE_ID_START+2]     = OFLOW;
            response_packet[`FEATURE_ID_START+5:`FEATURE_ID_START+3]  = {G,E,L};
            response_packet[`FEATURE_ID_START+6]     = COUT;
            response_packet[`FEATURE_ID_START+22:`FEATURE_ID_START+7]  = RES;
            //response_packet[`FEATURE_ID_START+8]/     = 0;
            $display("Monitor: At time (%0t), RES = %16b, COUT = %1b, GEL= %3b, OFLOW = %1b, ERR = %1b", $time, RES, COUT, {G,E,L}, OFLOW, ERR);
            exact_data = {RES, COUT, {G,E,L}, OFLOW, ERR};
        end
    endtask

    assign expected_data = {Expected_RES, cout, Comparison_GEL, ov, err};

    reg [54:0] scb_stimulus_mem [0:`no_of_testcase-1];

    //SCORE BOARD PROGRAM TO CHECK THE DUT OUTPUT WITH EXPECTD OUTPUT
    task score_board();
        reg [21:0] expected_res;
        reg [7:0] feature_id;
        reg [21:0] response_data;
        begin
            #5;
            feature_id    = curr_test_case[`FEATURE_ID_START:`FEATURE_ID_END];
            expected_res   = {curr_test_case[`EXP_RES_START:`EXP_RES_END],curr_test_case[`COUT_INDEX],curr_test_case[`GEL_START:`GEL_END],curr_test_case[`OV_INDEX],curr_test_case[`ERR_INDEX]};
            response_data = response_packet[`FEATURE_ID_START+22:`FEATURE_ID_START+1];
            $display("expected result = %22b ,response data = %22b", expected_data, exact_data);
            if (expected_data === exact_data)
                scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0, feature_id, expected_res, response_data, 1'b0, `PASS};
            else
                scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0, feature_id, expected_res, response_data, 1'b0, `FAIL};
            stim_stimulus_mem_ptr = stim_stimulus_mem_ptr + 1;
        end
    endtask

    //Generating the report `no_of_testcase-1
    task gen_report;
        integer file_id, pointer;
        reg [54:0] status;
        begin
            file_id = $fopen("results.txt", "w");
            for (pointer = 0; pointer <= `no_of_testcase - 1; pointer = pointer + 1) begin
                status = scb_stimulus_mem[pointer];
                if (status[0])
                    $fdisplay(file_id, "Feature ID %8b : PASS", status[53:46]);
                else
                    $fdisplay(file_id, "Feature ID %8b : FAIL", status[53:46]);
            end
        end
    endtask

    initial begin
        #10;
        global_init();
        dut_reset();
        read_stimulus();
        for (j = 0; j <= `no_of_testcase - 1; j = j + 1) begin
            fork
                driver();
                monitor();
            join

            score_board();
        end
        gen_report();
        $fclose(fid);
        #300 $finish();
    end
endmodule

