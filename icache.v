/*
Program	: 128x8-bit cache memory (16-Byte blocks)
Reg No	: E/16/394
Date	: 14/06/2020

Description	:

This program presents a primitive instruction  cache memory module for CO224 Lab 6 - Part 3
This cache allow cpu to read 4 Byte instruction and read instruction from instruction memory
*/

module icache(
    input               clock,
    input               reset,
    input[9:0]          pc,
    input               read,
    input               mem_busywait,
    input[127:0]        mem_readdata,
    output[31:0]        instruction,
    output reg          busywait,
    output reg          mem_read,
    output reg [5:0]    mem_address
);


reg [2:0] r_tag;
reg [2:0] r_index;
reg [3:0] r_offset;
wire[2:0] tag;
wire[2:0] index;
wire[3:0] offset;
reg valid;
reg hit;

/*
    Declare cache array (1 + 3 + 16*8 ) x 8
    valid bit | tag bit(3) | 4 instructions
*/
reg[131:0] cache_table [7:0] ;

assign offset = pc[3:0] ;
assign index  = pc[6:4] ;
assign tag    = pc[9:7] ;
//  Detect change in pc 
always @ (pc)
begin
    if (pc != -4 && read)
    begin
    busywait = 1;
    //   Latency for extraction stored value added here
    #1 {valid ,r_tag ,r_offset} = cache_table[index] ;
    //  Tag comparison
    #1 hit = ( tag == r_tag ) && (cache_table[index][131] == 1) ;
    end
end
//  Asynchronus read with 1 latency of selecting word
assign #1 instruction = (offset == 4'd0) ? cache_table[index][31:0] : (offset == 4'd4) ? cache_table[index][63:32] : (offset == 4'd8) ? cache_table[index][95:64] : cache_table[index][127:96];

//  Cache update
always @(negedge mem_busywait)
begin
    //  Write at next clock edge
    if (hit == 0)
    begin
        mem_read = 0;
        #1 cache_table[index][127:0] = mem_readdata;
        //  Update valid and tag bits
        cache_table[index][130:128] = tag;
        cache_table[index][131] = 1;
        //  Check hit status again
        #1 hit = ( tag == cache_table[index][130:128] ) && (cache_table[index][131] == 1);
    end
end

always @(posedge clock)
begin
    //  Deassert busywait signal
    if (hit == 1)
    begin
        hit =0;
        busywait = 0;
    end
end

//<--------------------------------------------------------------------------------------------->
integer i;
// Reset memory
always @(posedge reset)
begin
    if (reset)
    begin
        for (i=0;i<8; i=i+1)
            cache_table[i] = 132'd0;
        
        busywait = 0;
		
    end
end


// <-----------------cache controller FSM for instruction cache memory -------------------------------------->
parameter IDLE = 2'b00 , MEM_READ = 2'b01 ,UPDATE = 2'b10 ;
reg[1:0] state , next_state ;

//  Combinational next state logic
always @(*)
begin
    case(state)
    IDLE:
        if ( read && !hit )
        begin
            next_state = MEM_READ ;
        end
        else
        begin
            next_state = IDLE ;
        end
    
    MEM_READ:
        if (!mem_busywait)
        begin
            next_state = UPDATE ;
        end
        else
        begin
            next_state = MEM_READ ;
        end
    UPDATE:
        next_state = IDLE ;
    endcase
end
// Combinational output logic

always @(*)
begin
    case (state)
        IDLE:
        begin
            mem_read = 0;
        end
        MEM_READ:
        //  Read instructions from memory
        begin
            mem_read = 1;
            mem_address = {tag ,index} ;
            busywait = 1;
        end
        UPDATE :
        // Write instruction to cache
        begin
            mem_read = 0;
            //busywait = 0;
        end
    endcase
end

// Sequential logic for state transitioning
always @ (posedge clock , reset)
begin
    if (reset)
        state = IDLE ;
    else 
        state = next_state ;
    
end

//<----------------------For debugging purpose------------------------------------------------------------------>
/*
integer j;
always @(negedge read)
begin
    for (j=0 ;j< 8 ;j++)
        $display("%132b",cache_table[j]);
end
*/
endmodule