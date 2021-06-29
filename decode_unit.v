/*
    Reg. No :E/16/394
    CO224
    add new instructions
    change branch instruction 

*/

`timescale 1ns/100ps
/*
module testbench();

    wire [2:0] aluop ;
    wire signext ,writeenable ,alusrc ,branch ,memread ,memwrite ,memtoreg;
    reg [31:0] instruction ; 
    decode_unit my_cu(memread ,memwrite ,memtoreg ,writeenable ,aluop ,alusrc ,signext ,branch ,instruction );


    initial
    begin
    #5
    //add 5 2 1                |
    instruction <= {8'b11100001,8'b00000101,8'b00000010,8'b00000001};
    #5
    //sub 6 2 5
    instruction <= {8'b11110001,8'b00000110,8'b00000010,8'b00000101};
    #5
    //loadi 1 0xf7
    instruction <= {8'b01101000,8'b00000110,8'b00000010,8'b00000101};
    #5
    //j 0x05
    instruction <= {8'b01001000,8'b00000110,8'b00000010,8'b00000101};
    #5
    //beq 0x6 1 2
    instruction <= {8'b11010001,8'b00000110,8'b00000001,8'b00000010};
    #5
    //lwi 4 0x1F
    instruction <= {8'b00101000,8'b00000100,8'b00000001,8'b00010000};
    #5
    // lwd 4 2
    instruction <= {8'b00100000,8'b00000100,8'b00000001,8'b00000010};
    #5
    // swi 2 0x1F
    instruction <= {8'b10001000,8'b00000100,8'b00000010,8'b00010000};
    #5
    // swd 2 3
    instruction <= {8'b10000000,8'b00000100,8'b00000010,8'b00000011};
    #80 $finish;
    end

    initial
    begin
        $display("\t\twriteen aluop alusrc signext branch memread memwrite memtoreg");
        $monitor($time ,"\t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%b",writeenable ,aluop ,alusrc ,signext ,branch ,memread ,memwrite ,memtoreg  );
        
    end
endmodule
*/
//separate decode unit for cpu
module decode_unit(MEMREAD ,MEMWRITE ,MEMTOREG ,WRITEENABLE ,ALUOP ,ALUSRC ,SIGNEXT ,BRANCH ,INSTRUCTION );

    /*
        1110 0001 add
        1111 0001 sub
        1110 0010 and
        1110 0011 or

        1110 1100 ror right rotate
        1110 1101 sll logical left shift
        1110 1110 srl logicla right shift
        1110 1111 sra arithematic right shift

        0110 1000 loadi
        0110 0000 mov

        1101 0001 beq
        0100 1000 j

        0010 1000 lwi
        0010 0000 lwd

        1000 1000 swi
        1000 0000 swd

        use first 3 lsb as ALU operation
        use 3rd bit to determine whether to use immediate
        use 4th bit to determine whether to use 2s complement
        use 5th bit to determine whether writeenable
        use 5th and 6th bits to detemine branch
        use 5th and 6th bits to determine memtoreg
        use 6,5,4 th bits to determine memwrite
    */

    //define inputs
    //32 bits instruction 
    input [31:0] INSTRUCTION ;
    //define outputs
    //ALU operation
    output [2:0] ALUOP;
    //writeenable ,alu source , sign extend <= 2s complement
    output WRITEENABLE ,ALUSRC ,SIGNEXT ,BRANCH ,MEMREAD ,MEMWRITE ,MEMTOREG;
    

    reg [7:0] opcode ;
    
    
    //seperate opcode and decode it
    always @ (INSTRUCTION)
    begin
        #1 {opcode } = INSTRUCTION[31:24] ;
    end
    
    
    //write enable 
    assign WRITEENABLE = opcode[5];
    //branch enable
    assign BRANCH = (~opcode[5] && opcode[6] );
    //sign extend
    assign SIGNEXT = opcode[4] ;
    //alusrc use immediate or readreg 1 in alu
    assign ALUSRC = opcode[3] ;
    //alu function as lsb 3
    assign ALUOP = opcode[2:0] ;
    // memtoreg write to reg from data memory
    assign MEMTOREG = (opcode[5] && (~opcode[6] ));
    // read from data memory
    assign MEMREAD = (opcode[5] && (~opcode[6] )) ;
    // write to data memory
    assign MEMWRITE = ~(opcode[6] || opcode[5] || opcode[4]) ;


endmodule

