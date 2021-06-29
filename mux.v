/*
    Reg. No :E/16/394
    CO224
    Update add support to don't care  in mux32
*/

`timescale 1ns/100ps
/*
module testbench();

    reg [7:0] in1 ,in2 ;
    wire [7:0] out;
    reg select;

    mux8 my_mux(in1 ,in2 ,out ,select);

    initial
    begin
        in1 <= 1;
        in2 <= 2;
        select <=0;

        #5
        in1 <=3 ;
        #5
        select <=1;
        #5 $finish ;
    end
    
    initial 
    begin
        $monitor($time ," in1 : %d in2 : %d select : %b out : %d",in1 ,in2 ,select ,out );
    end
endmodule
*/
// 2 to 1 mux
module mux8(IN1 ,IN2 ,OUT ,SELECT);
    //define input
    //8 bits inputs
    input [7:0] IN1 ,IN2 ;
    // 1bit control
    input SELECT ;
    //define output
    //8 bits output
    output [7:0] OUT ;
    //output in register
    reg [7:0] OUT;

    ///execute whenever IN1 , IN2 , IN3 value changes
    always @ (IN1 ,IN2 ,SELECT)
    begin
        case (SELECT)
        1'b0 : OUT <= IN1 ;
        1'b1 : OUT <= IN2 ;
        endcase
    end
endmodule
// 4 to 1 mux
module mux4x1(IN1 ,IN2 ,IN3 ,IN4 ,OUT ,SELECT);
    //define input
    //8 bits inputs
    input [7:0] IN1 ,IN2 ,IN3 ,IN4;
    // 2bit control
    input[1:0] SELECT ;
    //define output
    //8 bits output
    output [7:0] OUT ;
    //output in register
    reg [7:0] OUT;

    ///execute whenever IN1 , IN2 , IN3 value changes
    always @ (IN1 ,IN2 ,SELECT)
    begin
        case (SELECT)
        2'b00 : OUT <= IN1 ;
        2'b01 : OUT <= IN2 ;
        2'b10 : OUT <= IN3 ;
        2'b11 : OUT <= IN4 ;
        endcase
    end
endmodule

module mux32(IN1 ,IN2 ,OUT ,SELECT);
    //define input
    //8 bits inputs
    input [31:0] IN1 ,IN2 ;
    // 1bit control
    input SELECT ;
    //define output
    //8 bits output
    output [31:0] OUT ;
    //output in register
    reg [31:0] OUT;

    ///execute whenever IN1 , IN2 , IN3 value changes
    always @ (IN1 ,IN2 ,SELECT)
    begin
        case (SELECT)
        1'b0 : OUT <= IN1 ;
        1'b1 : OUT <= IN2 ;
        1'bx: OUT <=IN1 ;
        endcase
    end
endmodule