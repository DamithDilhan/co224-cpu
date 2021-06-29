/*
    Reg. No :E/16/394
    CO224
    add #1 delay 
*/

`timescale 1ns/100ps
/*
module testbench();
    reg [7:0] in;
    wire [7:0] out;
    twos_complement my_twos_complement(in ,out);

    initial
    begin
        in <= 1;
        #5
        in <= 2;
        #5
        in <= 0;

    end
    initial
    begin
        $monitor($time ," in :%b out :%b ",in ,out);
    end
endmodule
*/
//2s complement unit for cpu 
module twos_complement(IN ,OUT);
    //define input
    //8 bit input
    input [7:0] IN;
    //define output
    // 8 bits output 
    output [7:0] OUT;
    //instantiate register for output
    reg [7:0] OUT ;
    //excute when IN chages
    always@ (IN)
    begin
        // negate In and add 1 
        #1 OUT = ~(IN) +1'b1; 
    end
endmodule