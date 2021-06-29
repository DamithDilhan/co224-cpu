/*
    Reg.No :E/16/394
    CO224 Lab 5 Reg_File.v
    write latency change from #2 to #1
*/

`timescale 1ns/100ps
module reg_file(IN ,OUT1 ,OUT2 ,INADDRESS ,OUTADDRESS1 ,OUTADDRESS2 ,WRITE ,CLK ,RESET);
    //register file with 8x8 bits registers
    //define inputs
    //input 8 bits data
    input [7:0] IN;
    // 3 bits input and output register addresses
    input [2:0] INADDRESS ,OUTADDRESS1 ,OUTADDRESS2 ;
    //1 bit inputs
    input WRITE ,CLK ,RESET ;
    //define    8 BITS outputs
    output [7:0] OUT1 ,OUT2 ;

    //8 bits 8 registers 
    reg [7:0] r_Block [0:7];
    //instantiate 8 bit register for out1 and out2
    reg [7:0] OUT1 ,OUT2;
    //define integer for reset all registers using for loop
    integer i ;
    //asynchronusly put registers to out 
    //execute whenever OUTADDRESS1 or register file change 
    always @ (OUTADDRESS1 ,r_Block[0] ,r_Block[1] ,r_Block[2] ,r_Block[3] ,r_Block[4] ,r_Block[5] ,r_Block[6] ,r_Block[7] )
    begin
        
        //choose Out1 according to outaddress1
        //add #2 delay to read 
        case (OUTADDRESS1)
        0 : OUT1 <= #2 r_Block[0] ;
        1 : OUT1 <= #2 r_Block[1] ;
        2 : OUT1 <= #2 r_Block[2] ;
        3 : OUT1 <= #2 r_Block[3] ;
        4 : OUT1 <= #2 r_Block[4] ;
        5 : OUT1 <= #2 r_Block[5] ;
        6 : OUT1 <= #2 r_Block[6] ;
        7 : OUT1 <= #2 r_Block[7] ;
        endcase
    end

    //execute whenever OUTADDRESS1 or register file change 
    always @(OUTADDRESS2 ,r_Block[0] ,r_Block[1] ,r_Block[2] ,r_Block[3] ,r_Block[4] ,r_Block[5] ,r_Block[6] ,r_Block[7] )
    begin
        //choose Out2 according to outaddress2
        //add #2 delay to read 
        case (OUTADDRESS2)
        0 : OUT2 <= #2 r_Block[0] ;
        1 : OUT2 <= #2 r_Block[1] ;
        2 : OUT2 <= #2 r_Block[2] ;
        3 : OUT2 <= #2 r_Block[3] ;
        4 : OUT2 <= #2 r_Block[4] ;
        5 : OUT2 <= #2 r_Block[5] ;
        6 : OUT2 <= #2 r_Block[6] ;
        7 : OUT2 <= #2 r_Block[7] ;
        endcase  
            
    end
    //synchronize with positve edge of clk 
    always @ (posedge CLK)
    begin
        //write data in IN to INADDRESS if write enabled
        if (WRITE == 1)
        begin
            //add #2 delay to write
            // changed writing delay to 1
            case (INADDRESS)
                0 :#1 r_Block[0] =  IN;
                1 :#1 r_Block[1] =  IN;
                2 :#1 r_Block[2] =  IN;
                3 :#1 r_Block[3] =  IN;
                4 :#1 r_Block[4] =  IN;
                5 :#1 r_Block[5] =  IN;
                6 :#1 r_Block[6] =  IN;
                7 :#1 r_Block[7] =  IN;
            endcase
            
        end
    end
    //asynchronizely reset all registers to 0
    always @ (RESET)
    begin
        //check reset == 1 add #2 delay
        if (RESET == 1)
        begin
            #2
            for (i =0 ;i <8 ;i = i+1)
            begin
                r_Block[i] <= 0;
            end
        end
    end
    
endmodule