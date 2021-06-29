/*
    Reg. No :E/16/394
    CO224
    changed pc jump adder name to program_counter_adder
    change decode unit
    add memread ,memwrite ,memtoreg
*/

`timescale 1ns/100ps
//cpu module
module cpu(PC ,INSTRUCTION ,CLK ,RESET ,BUSYWAIT ,READDATA ,ALURESULTTOMEM ,WRITEDATA ,MEMREAD ,MEMWRITE);
    //define input 
    //clock signal and reset signal
    input CLK ,RESET ,BUSYWAIT;
    //instruction
    input [31:0] INSTRUCTION;
    // Readdata input from data memory
    input [7:0] READDATA ;
    //next address
    output [31:0] PC ;
    //memread , memwrite
    output MEMREAD ,MEMWRITE ;
    output [7:0] ALURESULTTOMEM , WRITEDATA ;

    integer k;
    //readregister 1 and readregister 2 address 
    wire [2:0] w_READREG1 ,w_READREG2 ;
    //write register address and ALU operation
    wire [2:0] w_WRITEREG ,w_ALUOP;
    //writeenable ,alu source , sign extend ,memtoreg 
    wire  w_ALUSRC ,w_SIGNEXT , w_MEMTOREG  ;
    //8 bits immediate value write to reg
    wire [7:0] w_IMMEDIATE ,w_writetoreg;
    //next instrunction addresss ,next pc address to adder 
    wire [31:0] w_nextPC ,w_nextPC2Adder ,w_nextPC4Adder ;
    //alu result output ,readreg 1 out ,read reg 2 out
    wire [7:0] w_ALURESULT ,w_OUT1 ,w_OUT2 ;
    //2s complement out
    wire [7:0] w_2sOUT;
    //mux_2s out
    wire [7:0] w_mux_2s;
    //mux immediate out
    wire [7:0] w_mux_immediate;
    //get alu zero output , get decode unit branch output
    wire w_ZERO ,w_BRANCH ,w_WRITEENABLE ,w_MEMREAD ,w_MEMWRITE;

    //instantiate program counter register
    reg [31:0] PC ;
    // store busy wait signal , memwread ,memwrite in reset 
    reg r_busywait ,MEMREAD ,MEMWRITE ;
    //test purpose reg memory
    wire [7:0] reg0_memory ,reg1_memory ,reg2_memory ,reg3_memory ,reg4_memory ,reg5_memory ,reg6_memory ,reg7_memory ;
    
    //instantiate pc normal adder use default value 
    programe_counter_unit my_pc_unit(PC ,8'd1 ,w_nextPC2Adder);
    //instantiate second pc adder where sign extend happen inside and directly connect to instruction dest 
    programe_counter_adder my_pc2_unit(w_nextPC2Adder ,INSTRUCTION[23:16],w_nextPC4Adder) ;
    //instantiate decode unit
    decode_unit my_decode_unit(w_MEMREAD ,w_MEMWRITE ,w_MEMTOREG ,w_WRITEENABLE ,w_ALUOP ,w_ALUSRC ,w_SIGNEXT ,w_BRANCH ,INSTRUCTION );
    //instantiate alu unit
    alu my_alu_unit(w_OUT1 ,w_mux_immediate ,w_ALURESULT ,w_ALUOP ,w_ZERO);
    //instantiate reg file
    // Stall writeenable signal with busywait signal
    reg_file my_reg_file_unit(w_writetoreg ,w_OUT1 ,w_OUT2 ,w_WRITEREG ,w_READREG1 ,w_READREG2 ,w_WRITEENABLE,CLK ,RESET);
    //instantiate 2scomplement
    twos_complement my_2s_complement_unit(w_OUT2 ,w_2sOUT);
    //instantiate mux for 2s complement
    mux8 mux_2s(w_OUT2 ,w_2sOUT ,w_mux_2s ,w_SIGNEXT);
    //instantiate mux for immediate
    mux8 mux_immediate(w_mux_2s ,w_IMMEDIATE ,w_mux_immediate ,w_ALUSRC);
    //instantiate mux for choosing normal pc value or extended value
    //use 2s complement select bit to separate beq from jump command (branch&~signEXT) | (zero & barnch)
    mux32 mux_pc(w_nextPC2Adder ,w_nextPC4Adder ,w_nextPC, (w_BRANCH & ~w_SIGNEXT) | (w_ZERO & w_BRANCH));
    //intantiate mux for choose between aluresult and readdata
    mux8 mux_writetoreg(w_ALURESULT ,READDATA ,w_writetoreg ,w_MEMTOREG);


    
//update pc every clock edge
//if RESET == 1 do nothing until next clock cycle
// Handle busywait signal 
    always @(posedge CLK , posedge RESET )
    begin
        /*
        if (r_busywait == 1'b0)
        begin
            
            PC <=#1 RESET == 1'b0 ? w_nextPC : -4 ;
            
        end
        */
       // Change due to busywait not caught
        #1
        if (r_busywait== 'b0)
            PC = RESET == 1'b0 ? w_nextPC : -4 ;
           
    end

    //Asynchronusly rest pc for -4
    always @ (RESET)
    begin
        if (RESET == 1'b1)
        begin
        PC = -4 ;
        r_busywait = 0;

        end
    end
    // Asynchronusly save busywait signal
    always @ (BUSYWAIT)
    begin
        // set busy wait register to 1
        if (BUSYWAIT == 1'b1)
        begin
            r_busywait = 1'b1 ;
        end
        else if (BUSYWAIT == 1'b0)
        begin
            r_busywait = 1'b0 ;
        end
        
    end
    // Handle unwantedd busy wait signal occur after reset
    always @ (w_MEMREAD ,w_MEMWRITE)
    begin
        MEMREAD = PC == -4 ? 1'b0 : w_MEMREAD ;
        MEMWRITE = PC == -4 ? 1'b0 : w_MEMWRITE ;
    end



    

    //directly connect READREG1 ,READREG2 ,WRITEREG and IMMEDIATE with INSTRUCTION
    assign w_READREG1 = INSTRUCTION[15:8];
    assign w_READREG2 = INSTRUCTION[7:0];
    assign w_IMMEDIATE = INSTRUCTION[7:0];
    assign w_WRITEREG = INSTRUCTION[23:16];

    // Wires Connected to Data memory
    assign ALURESULTTOMEM  = w_ALURESULT ;
    assign WRITEDATA = w_OUT1;

    

    
   
    //check register write inside reg_file for test purpose
    assign reg0_memory = my_reg_file_unit.r_Block[0];
    assign reg1_memory = my_reg_file_unit.r_Block[1];
    assign reg2_memory = my_reg_file_unit.r_Block[2];
    assign reg3_memory = my_reg_file_unit.r_Block[3];
    assign reg4_memory = my_reg_file_unit.r_Block[4];
    assign reg5_memory = my_reg_file_unit.r_Block[5];
    assign reg6_memory = my_reg_file_unit.r_Block[6];
    assign reg7_memory = my_reg_file_unit.r_Block[7];
    
endmodule