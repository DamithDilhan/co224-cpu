/*
    Reg. No :E/16/394
    CO224
    32 bytes cache memory for cpu
    !!!Can not make mem read and write in 41 and 21 cycle 
    !!! change hit 0.9 didnt work
*/
`timescale 1ns/100ps

module cache(clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
	busywait,
    mem_read,
    mem_write,
    mem_busywait,
    mem_writedata,
    mem_readdata,
    mem_address
    );
input               clock;
input               reset;
input               read;
input               write;
input[7:0]          address;
input[7:0]          writedata;
input               mem_busywait;
input[31:0]         mem_readdata;
output wire [7:0]    readdata;
output reg          busywait;
output reg          mem_read;
output reg          mem_write;
output reg [31:0]   mem_writedata;
output reg [5:0]    mem_address;
integer i;

/*
    tag_bits = 3 , index_bits= 3 ,offset_bits = 2
    table size = 3 + 1 + 1+ 4* 8 = 37
    lines = 8
    [{valid[36]}{dirty[35]}{tag[34:32]}{data[31:0]}]
*/

// Declare cache memory table
reg [36:0] cache_table [7:0] ;
// Hold read , write access status
reg readaccess , writeaccess;

// Hold hit status
reg hit =  0;
// Hold dirty status
reg dirty = 0;
reg[2:0] index;
reg[2:0] tag;
reg[1:0] offset;
// Temp busywait hold register
reg tempbusywait =0;

//<----------------------------------------------------------------------------->
/*
// Create initial block for test purpose
initial
begin
    // Do reset
    for (i=0;i<8; i=i+1)
            cache_table[i] = 37'd0;
        
    busywait = 0;
	readaccess = 0;
	writeaccess = 0;
    // Put data to cache
    cache_table[0] = 37'b00000xxxxxxxxxxxxxxxx00010010xxxxxxxx;
end
*/
//<------------------------------------------------------------------------>
// Detect read or write and set busywait
always @(read ,write)
begin
    if (read || write)
    begin
        //$display("readaccess and writeaccess activated");
        busywait = 1;
        tempbusywait = 1;   //<!---temp-->
        // set readaccess and writeaccess
        readaccess = read ;
        writeaccess = write ;
    end
end
/*  Combinational part */
/*  Split address to tag ,index ,offset asynchronously
    Set hit by tag comparison and validity
    Get dirty bit status
*/
always @(address,read ,write)
begin
    
    #1 {tag,index,offset} = address;
    if (read || write)
    begin
    dirty = cache_table[index][35] ;
    #0.9 hit = (cache_table[index][34:32] == tag ) && cache_table[index][36] ;
    end
end
// Read from cache
//assign #0.9 hit = (cache_table[index][34:32] == tag ) && cache_table[index][36] ;
//assign #1 readdata = (offset==2'b00 && hit ==1) ? cache_table[index][7:0] : offset==2'b01 && (hit == 1) ? cache_table[index][15:8] : (offset==2'b10 && hit==1) ? cache_table[index][23:16] : (offset==2'b11 && hit ==1) ? cache_table[index][31:24] : 8'dx ; 
assign #1 readdata = (offset==2'b00) ? cache_table[index][7:0] : (offset==2'b01) ? cache_table[index][15:8] : (offset==2'b10) ? cache_table[index][23:16] : (offset==2'b11) ? cache_table[index][31:24] : 8'dx ;    

// Write to cache
always @ (posedge clock)
begin
    
    if (write && hit == 1 && mem_busywait != 1)
    begin
        tempbusywait = 0 ;
        writeaccess = 0;
        hit =0;
        case (offset)
            2'b00 : #1 cache_table[index][7:0] = writedata ;
            2'b01 : #1 cache_table[index][15:8] = writedata ;
            2'b10 : #1 cache_table[index][23:16]  = writedata ;
            2'b11 : #1 cache_table[index][31:24]   = writedata ;
        endcase
        // Set dirty bit 1
        cache_table[index][35] = 1; 
        //$display("cache write");
          
    end
end


always @(posedge clock)
begin
     
    if (readaccess==1 && hit==1 && !mem_busywait)
    begin
        tempbusywait = 0;   //<--tempbusywait-->
        readaccess = 0;
        hit = 0;
        //$display("deaserted readacces");
    end
    else if (writeaccess==1 && hit==1 && !mem_busywait)
    begin
        tempbusywait = 0;   //<--tempbusywait-->
        writeaccess = 0;
    end
    
end

    

// On mem busywait negative edge
always @(negedge mem_busywait)
begin
    //$display("negative edge");
    // After memory read update cache
    // incase of miss
    if( hit == 0 && mem_read == 1)
    begin
        cache_table[index][31:0] =#1 mem_readdata ;
        cache_table[index][35] = 0;
        cache_table[index][36] = 1;
        cache_table[index][34:32] = tag ;
        #0.9 hit = (cache_table[index][34:32] == tag ) && cache_table[index][36] ;
        dirty = 0 ;
    end
    // incase of dirty
    if(dirty == 1)
    begin
        // Update dirty bit
        cache_table[index][35] = 0;
        dirty = 0;
    end

end
//<--------------------------------------------------------------------------------------------->

// Reset memory
always @(posedge reset)
begin
    if (reset)
    begin
        for (i=0;i<8; i=i+1)
            cache_table[i] = 37'd0;
        
        busywait = 0;
		readaccess = 0;
		writeaccess = 0;
    end
end

//<---------------------------------------------------------------------------------------------------->
/*  Cache Controller FSM Start  */

parameter IDLE =3'b000 , MEM_READ = 3'b001 , MEM_WRITE = 3'b010 ,READ = 3'b011 ,UPDATE = 3'b100 ;
reg [2:0] state ,next_state ;

// Combinational next state logic
always @(*)
begin
    case (state)
        IDLE:
            if ((readaccess || writeaccess) && !dirty && !hit)
            begin
            next_state = MEM_READ ;
            end
            else if ((readaccess || writeaccess) && dirty && !hit)
                next_state = MEM_WRITE ;
            else
                next_state = IDLE;
        MEM_READ:
            if (!mem_busywait)
            begin
                next_state = UPDATE ;
            end
            else if (mem_busywait == 1)
            begin
                next_state = MEM_READ ;
            end
        MEM_WRITE:
            if (!mem_busywait)
            begin
                next_state = MEM_READ ;
            end
            else
                next_state = MEM_WRITE ;
        UPDATE:

            next_state = IDLE ;
        
    endcase
end

// Combinational output logic
always @(*)
begin
    case (state)
        IDLE :
            begin
                //$display("IDLE");
                mem_read = 0;
                mem_write = 0;
                
            end
                 
        MEM_READ:
            begin
                //$display("MEM_READ");
                mem_read = 1;
                mem_write = 0;
                busywait = 1;
                tempbusywait =1 ;
                // Give address of block to read
                mem_address = {tag,index} ;
                

            end
        MEM_WRITE:
            begin
                //$display("MEM_WRITE");
                mem_read = 0;
                mem_write = 1;
                busywait = 1;
                tempbusywait = 1;
                // Write to current {tag index}
                mem_address = {cache_table[index][34:32],index} ;
                mem_writedata = cache_table[index][31:0] ;
                
            end
        UPDATE :
            begin
                //$display(" UPDATE");
                mem_read = 0;
                mem_write = 0;
                busywait = 1;
            end
                
    endcase 
end

// Sequential logic for state transitioning
always @ (posedge clock , reset)
begin
    busywait = tempbusywait || 0;
    if (reset)
        state = IDLE ;
    else 
        state = next_state ;
    
    if (state == IDLE)
        begin
        // Set busy wait zero if read of write is done.
        // Implement inside Idle state giving static hazard
        busywait = tempbusywait || 0;
        
        end
    
end
/*  Cache controller FSM End */
//<------monitor cache ------>
/*
integer j;
always @(*)
begin
    for (j= 0 ; j <8 ; j++)
    begin
    
        $display(" %b %b %3b %d %32b",cache_table[j][36] ,cache_table[j][35] ,cache_table[j][34:32] ,j ,cache_table[j][31:0]);
    end
end
*/

endmodule