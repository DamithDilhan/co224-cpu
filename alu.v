/*
    Reg. No :E/16/394
    CO224
*/
`timescale 1ns/100ps
module alu( DATA1, DATA2 ,RESULT ,SELECT ,ZERO);
    //ALU module for cpu
    //define 8 bits inputs data1 and data2
    input [7:0] DATA1 ,DATA2 ;
    //define 3 bits input select
    input [2:0] SELECT;
    //define 8 bits output result
    output [7:0] RESULT;
    //define 1 bit ouput check whether result == 0
    output ZERO;
    //create 7 bits register to hold result
    reg [7:0] RESULT;
    //define wires
    //wire for shift module outputs
    wire [7:0] w_left_out ,w_right_out ,w_arithematic_out ,w_rotate_out ;
    
    //instantiate barral shift left
    barral_shift_left alu_left_shift(DATA1 ,DATA2[2:0] ,w_left_out) ;
    //instantiate barral shift right
    barral_shift_right alu_right_shift(DATA1 ,DATA2[2:0] ,1'b0 ,w_right_out) ;
    //instantiate arithematic shift right
    barral_shift_right alu_arithematic_shift(DATA1 ,DATA2[2:0] ,DATA1[7] ,w_arithematic_out) ;
    //instantiate right rotate 
    right_rotate_shifter alu_right_rotate(DATA1 ,DATA2[2:0] ,w_rotate_out) ;

    //execute whenever data1 , data2 , select value changes

    always @( DATA1 , DATA2 , SELECT)
    begin
        //do operation according to value in select
        case(SELECT)
            //if select = 000 forward function ,data2-> result #1 delay
            3'b000 : #1  RESULT =  DATA2 ;
            //if select = 001 add function ,data1 + data2 -> result #2 delay
            3'b001 : #2 RESULT = DATA1 + DATA2 ;
            //if select = 010 and function , data1 & data2 -> result #1 delay
            3'b010 : #1 RESULT =  DATA1 & DATA2 ;
            //if select = 011 or function , data1 | data2 -> result #1 delay
            3'b011 : #1 RESULT =  DATA1 | DATA2;
            
            //if select = 100 rotate right #2 delays
            3'b100 : #2 RESULT = w_rotate_out;
            //if select = 101 logical left shift data1 << data2 -> result #1 delay
            3'b101 : #1 RESULT = w_left_out;
            //if select = 110 logical right shift data1 >> data2 -> result #1 delay
            3'b110 : #1 RESULT = w_right_out ;
            //if select = 111 Arithmetic right shift data1 >>> data2 -> result #1 delay
            //make DATA1 32bit number
            3'b111 : #1 RESULT = w_arithematic_out;
        endcase


    end
    //if result == 0 set 1 else 0 xnor gate used not working 
    //assign ZERO = RESULT == 0 ? 1 : 0;
   assign ZERO = ~(|(RESULT)) ;

endmodule