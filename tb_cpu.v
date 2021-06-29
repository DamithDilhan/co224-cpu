/*
    Reg. No :E/16/394
    CO224
    modified
*/
`timescale 1ns/100ps
module testbench();
    reg clk ,reset;
    reg iread;
    reg [31:0] instructMem [1023:0];
    wire [31:0] instruction;
    wire [31:0] pc;
    wire [7:0] aluresult ,writedata ,readdata ;
    wire read , write , busywait ,dbusywait , ibusywait;
    wire memread ,memwrite ,membusywait ,imemread ,imembusywait ;
    wire[5:0] memaddress ,imemaddress;
    wire[31:0] memwritedata ,memreaddata ;
    wire[127:0] imemreaddata ;
     
    assign busywait = dbusywait || ibusywait ;
    // Instantiate cpu module
    cpu my_cpu(pc ,instruction ,clk ,reset ,busywait ,readdata ,aluresult ,writedata ,read ,write);
    // Instantiate cache module
    cache my_cache(clk ,reset ,read ,write ,aluresult ,writedata ,readdata ,dbusywait ,memread ,memwrite ,membusywait ,memwritedata ,memreaddata ,memaddress);
    // Instantiate data memory module
    data_memory my_datamemory(clk ,reset ,memread ,memwrite ,memaddress ,memwritedata ,memreaddata ,membusywait) ;
    // Instantiate instruction cache memory
    icache my_icache(clk ,reset ,pc[9:0] ,iread ,imembusywait ,imemreaddata ,instruction ,ibusywait ,imemread ,imemaddress);
    // Instantiate instruction memory
    instruction_memory my_instruction_memory(clk ,imemread ,imemaddress ,imemreaddata ,imembusywait);

    /*
    // read from test_programe_1.s.machine file 
    // append instructions to instruction memory
    integer file_input; 
    integer scan_input;
    reg [7:0] capture_input;
    reg file_reading;
    integer i;
    
    
    initial
    begin
        i =0;
        
        //open file
        file_input= $fopen("test_program_1.s.machine","r");
        if (file_input == 0)
        begin
            $finish;
        end
    while (!$feof(file_input))
        begin
            scan_input = $fscanf(file_input ,"%8b\n",capture_input);
            $display("%8b" ,capture_input);
            instructMem[i] <= capture_input ;
            i = i+4 ;
           
        end
    $fclose(file_input);
    //$finish;
    end
    
    */

    initial
    begin
        clk <= 0;
        reset <= 1;
        
        #4
        reset <= 0;
        
    end
    always
    begin
        #4  //cpu clock cycle was changed to 8
        clk = ~clk ;
    end
    initial
    begin
        // wave file generate
        $dumpfile("wavedata.vcd");
		$dumpvars(0,testbench);
        $monitor($time ," %b %b %d %b",clk ,reset ,pc ,membusywait);
        //finish
        #2200 $finish;
    end
    /*
    always @ (posedge clk)
    begin
        #1//update
        //instruction read if pc = -4 give 0 as instruction
        #2 instruction = pc!=-4 ? instructMem[pc] :0;
    end
    */
    always @(pc)
    begin
        iread = 1;
        //$display("iread on");
    end
    always @(ibusywait)
    begin
        if (ibusywait == 0)
            iread = 0;

    end        

endmodule
