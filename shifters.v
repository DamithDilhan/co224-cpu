/*
    Reg. No :E/16/394
    CO224
    Shifter modules for ALU unit.
*/

`timescale 1ns/100ps
/*
module testbench();

    reg [7:0] in ;
    reg [2:0] shift ;
    wire [7:0] out_left ,out_right ,out_ra ,out_rotate ;

    //instantiate barrel shift right
    barral_shift_right right_shift(in ,shift ,1'b1 ,out_ra);
    barral_shift_right ar_right_shift(in ,shift ,1'b0 ,out_right);
    //instantiate barrel shift left
    barral_shift_left left_shift(in ,shift ,out_left);
    //instantiate right rotate shifter
    right_rotate_shifter rotate_shifter(in ,shift ,out_rotate) ;

    initial
    begin
        in <=8'b10010001;
        shift <=3'd1;

        #2
        shift <=3'd2;

        #2
        shift <=3'd3;

        #2
        shift <=3'd4;

        #2
        shift <=3'd5;

        #2
        shift <=3'd6;

        #2
        shift <=3'd7;

        #2
        shift <=3'd0;


    end 

    initial
    begin
        $monitor($time ," %b %b %b %b %b %d",in ,out_left ,out_right ,out_ra ,out_rotate ,shift);
    end
endmodule
*/
//barrel shift left
module barral_shift_left(IN , SHIFT , OUT);

    //define input
    // 8 bit number
    input [7:0] IN;
    //3 bit number of shifting bits
    input [2:0] SHIFT ;
    //define output
    //8 bit output
    output [7:0] OUT ;

    

    //define wires
    wire [7:0] w_level1_out ,w_level2_out ;
    //instantiate 8 bit mux
    //level 1
    mux8 level1_mux8({IN[6:0],1'b0} ,IN ,w_level1_out,~SHIFT[0]);
    //level 2
    mux8 level2_mux8({w_level1_out[5:0] ,2'b00} ,w_level1_out ,w_level2_out ,~SHIFT[1]);
    //level 3
    mux8 level3_mux8({w_level2_out[3:0] ,4'b0000} ,w_level2_out ,OUT ,~SHIFT[2]);


endmodule

//barral shift right
module barral_shift_right(IN , SHIFT ,BIT , OUT);

    //define input
    // 8 bit number
    input [7:0] IN;
    //input bit 
    input BIT ;
    //3 bit number of shifting bits
    input [2:0] SHIFT ;
    //define output
    //8 bit output
    output [7:0] OUT ;

    

    //define wires
    wire [7:0] w_level1_out ,w_level2_out ;
    //instantiate 8 bit mux
    //level 1
    mux8 level1_mux8({BIT ,IN[7:1] } ,IN ,w_level1_out,~SHIFT[0]);
    //level 2
    mux8 level2_mux8({{2{BIT}} ,w_level1_out[7:2] } ,w_level1_out ,w_level2_out ,~SHIFT[1]);
    //level 3
    mux8 level3_mux8({{4{BIT}} ,w_level2_out[7:4] } ,w_level2_out ,OUT ,~SHIFT[2]);


endmodule

//right rotate shifter
module right_rotate_shifter(IN , SHIFT , OUT);
    //define input
    // 8 bit number
    input [7:0] IN;
    //3 bit number of shifting bits
    input [2:0] SHIFT ;
    //define output
    //8 bit output
    output [7:0] OUT ;

    //define wires
    wire [7:0] w_left_shift_out ,w_right_shift_out ;

    //instantiate barral shifter right
    barral_shift_right right_shifter(IN ,SHIFT ,1'b0 ,w_right_shift_out);
    //instantiate barral shifter left
    //use shift as  2s complement of SHIFT
    barral_shift_left left_shifter(IN ,(~(SHIFT) +1'b1 ),w_left_shift_out);
    //do or operation to both left shift out and right shift out 
    assign OUT = (w_left_shift_out | w_right_shift_out) ;
endmodule