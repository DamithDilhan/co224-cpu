/*
    Reg. No :E/16/394
    CO224
    create new adder for handle jump/Branch
    set pc+4 delay to #1
*/

`timescale 1ns/100ps
/*
module testbench();
reg [31:0] pc;
wire [31:0] w_pc;
reg clk;

programe_counter_unit my_programe_counter_unit(pc ,(8'd1) ,w_pc );

initial
begin
    clk <= 0;
    pc <= 0;
    $monitor($time ," %b %d %32d",clk , pc ,w_pc);
end

always
begin
    #5
    clk =~clk ;

    if ($time == 50) $finish;


end
always @ (posedge clk)
begin
    pc <= #1 w_pc ;
    
end
endmodule
*/

//adder for pc
module programe_counter_unit(CURRENTADDRESS ,VALUE ,NEXTADDRESS);

    //define inputs
    //current address 
    input [31:0] CURRENTADDRESS ;
    //adding value default 4
    input [7:0] VALUE;
    //define output
    //next instruction address
    output [31:0] NEXTADDRESS ;
    wire [31:0] w_sign_extende_value;

    //extend msb to 24 bits make 32 bit number
    assign w_sign_extende_value = {{24{VALUE[7]}},VALUE} ;
    //add 4 bytes to pass a word
    assign #1 NEXTADDRESS = CURRENTADDRESS + (w_sign_extende_value << 2);   //change delay to 1
    
    

endmodule
// need secondry pc adder
//adder for pc with jump?branch has #2 delay
module programe_counter_adder(CURRENTADDRESS ,VALUE ,NEXTADDRESS);

    //define inputs
    //current address 
    input [31:0] CURRENTADDRESS ;
    //adding value default 4
    input [7:0] VALUE;
    //define output
    //next instruction address
    output [31:0] NEXTADDRESS ;
    wire [31:0] w_sign_extende_value;

    //extend msb to 24 bits make 32 bit number
    assign w_sign_extende_value = {{24{VALUE[7]}},VALUE} ;
    //add 4 bytes to pass a word
    assign #2 NEXTADDRESS = CURRENTADDRESS + (w_sign_extende_value << 2);
    
    

endmodule

