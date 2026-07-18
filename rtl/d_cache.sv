`define TAG          31:13  // 19 bits
`define INDEX        12:3   // 10 bits
`define BLOCK_OFFSET 2      // 1 bit (which word in the block)
`define BYTE_OFFSET  1:0    // 2 bits (word aligned)

module d_cache #(
    parameter SIZE = 32*1024*8,
    parameter NWAYS = 4,
    parameter NSETS = 1024,
    parameter BLOCK_SIZE = 64,
    parameter WIDTH = 32, // CPU data width
    parameter MWIDTH = 64, // Memory data width, (same as block size)
    parameter INDEX_WIDTH = 10,
    parameter TAG_WIDTH = 19,
    parameter OFFSET_WIDTH = 3
)(
    input logic clk, reset,
    input logic [WIDTH-1: 0] address, //address from cpu
    input logic [WIDTH-1: 0] din,     // data from cpu if store instr
    input logic rden,                 // read enable, 1 for load instr
    input logic wren,                 // write enable, 1 for store instr
    output logic hit_miss,            // 1 if cache_hit, 0 if miss
    output logic [WIDTH-1: 0] dout,      // data cache sends back to cpu
    output logic [WIDTH-1: 0] mrdaddress, // (memory read), address cache sends to memory when it needs to fetch a missing block
    output logic mrden,                   // memory read enable
    output logic [WIDTH-1: 0] mwraddress, // (memory write), address cache sends to to memory when evicting a dirty block
    output logic mwren,                   // memory write enable
    output logic [MWIDTH-1: 0] mdout,     // memory data out, the dirty block which cache sends to memory while evicting
    input logic [MWIDTH-1: 0] mdin        // memory data in, the data coming from memory to cache
);

    // way 0 
    logic valid0 [0: NSETS-1];
    logic dirty0 [0: NSETS-1];
    logic [1:0] lru0 [0: NSETS-1];
    logic [TAG_WIDTH-1: 0] tag0 [0: NSETS-1];
    logic [MWIDTH-1: 0] mem0 [0: NSETS-1];

    // way 1
    logic valid1 [0: NSETS-1];
    logic dirty1 [0: NSETS-1];
    logic [1:0] lru1 [0: NSETS-1];
    logic [TAG_WIDTH-1: 0] tag1 [0: NSETS-1];
    logic [MWIDTH-1: 0] mem1 [0: NSETS-1];

    // way 2
    logic valid2 [0: NSETS-1];
    logic dirty2 [0: NSETS-1];
    logic [1:0] lru2 [0: NSETS-1];
    logic [TAG_WIDTH-1: 0] tag2 [0: NSETS-1];
    logic [MWIDTH-1: 0] mem2 [0: NSETS-1];

    // way 3
    logic valid3 [0: NSETS-1];
    logic dirty3 [0: NSETS-1];
    logic [1:0] lru3 [0: NSETS-1];
    logic [TAG_WIDTH-1: 0] tag3 [0: NSETS-1];
    logic [MWIDTH-1: 0] mem3 [0: NSETS-1];

    parameter idle = 0;  // receive requests from cpu
    parameter miss = 1;  // write back dirty block and put in new data

    logic state;
    



    always_ff @(posedge clk) begin
        if(reset) begin
            state <= idle;
            hit_miss <= 0;
            dout <= 0;
            mwren <= 0;
            mwraddress <= 0;
            mdout <= 0;
            for(int i=0; i < NSETS; i++) begin
                valid0[i] <= 0; dirty0[i] <= 0; lru0[i] <= 0;
                valid1[i] <= 0; dirty1[i] <= 0; lru1[i] <= 0;
                valid2[i] <= 0; dirty2[i] <= 0; lru2[i] <= 0;
                valid3[i] <= 0; dirty3[i] <= 0; lru3[i] <= 0;
            end
        end
        else begin
            case(state)
                idle: begin
                   // idle state logic 

                   // reset mwren if it was high
                   mwren <= 0;

                   // check hit or miss status
                   hit_miss <= (valid0[address[`INDEX]] && (tag0[address[`INDEX]] == address[`TAG]))
                             ||(valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG])) 
                             ||(valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG])) 
                             ||(valid3[address[`INDEX]] && (tag3[address[`INDEX]] == address[`TAG]));

                    // null request - do nothing
                    if (~rden && ~wren) state <= idle;

                    // check way0
                    else if(valid0[address[`INDEX]] && (tag0[address[`INDEX]] == address[`TAG])) begin
                        // read hit
                        if (rden) dout <= address[`BLOCK_OFFSET] ? mem0[address[`INDEX]][63:32] : mem0[address[`INDEX]][31:0];
                        
                        // write hit
                        else if(wren) begin
                            if(address[`BLOCK_OFFSET]) mem0[address[`INDEX]][63:32] <= din;
                            else                       mem0[address[`INDEX]][31:0] <= din;
                            dirty0[address[`INDEX]] <= 1;
                            dout <= 0;
                        end

                        // update lru data
                        if (lru1[address[`INDEX]] <= lru0[address[`INDEX]]) lru1[address[`INDEX]] <= lru1[address[`INDEX]] + 1;
                        if (lru2[address[`INDEX]] <= lru0[address[`INDEX]]) lru2[address[`INDEX]] <= lru2[address[`INDEX]] + 1;
                        if (lru3[address[`INDEX]] <= lru0[address[`INDEX]]) lru3[address[`INDEX]] <= lru3[address[`INDEX]] + 1;
                        lru0[address[`INDEX]] <= 0;
                    end

                    // check way1
                    else if(valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG])) begin
                        // read hit
                        if (rden) dout <= address[`BLOCK_OFFSET] ? mem1[address[`INDEX]][63:32] : mem1[address[`INDEX]][31:0];
                        
                        // write hit
                        else if(wren) begin
                            if(address[`BLOCK_OFFSET]) mem1[address[`INDEX]][63:32] <= din;
                            else                       mem1[address[`INDEX]][31:0] <= din;
                            dirty1[address[`INDEX]] <= 1;
                            dout <= 0;
                        end

                        // update lru data     
                        if (lru0[address[`INDEX]] <= lru1[address[`INDEX]]) lru0[address[`INDEX]] <= lru0[address[`INDEX]] + 1;
                        if (lru2[address[`INDEX]] <= lru1[address[`INDEX]]) lru2[address[`INDEX]] <= lru2[address[`INDEX]] + 1;
                        if (lru3[address[`INDEX]] <= lru1[address[`INDEX]]) lru3[address[`INDEX]] <= lru3[address[`INDEX]] + 1;
                        lru1[address[`INDEX]] <= 0;                  
                    end

                    // check way2
                    else if(valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG])) begin
                        // read hit
                        if (rden) dout <= address[`BLOCK_OFFSET] ? mem2[address[`INDEX]][63:32] : mem2[address[`INDEX]][31:0];
                        
                        // write hit
                        else if(wren) begin
                            if(address[`BLOCK_OFFSET]) mem2[address[`INDEX]][63:32] <= din;
                            else                       mem2[address[`INDEX]][31:0] <= din;
                            dirty2[address[`INDEX]] <= 1;
                            dout <= 0;
                        end

                        // update lru data    
                        if (lru1[address[`INDEX]] <= lru2[address[`INDEX]]) lru1[address[`INDEX]] <= lru1[address[`INDEX]] + 1;
                        if (lru0[address[`INDEX]] <= lru2[address[`INDEX]]) lru0[address[`INDEX]] <= lru0[address[`INDEX]] + 1;
                        if (lru3[address[`INDEX]] <= lru2[address[`INDEX]]) lru3[address[`INDEX]] <= lru3[address[`INDEX]] + 1;
                        lru2[address[`INDEX]] <= 0;                    
                    end

                    // check way3
                    else if(valid3[address[`INDEX]] && (tag3[address[`INDEX]] == address[`TAG])) begin
                        // read hit
                        if (rden) dout <= address[`BLOCK_OFFSET] ? mem3[address[`INDEX]][63:32] : mem3[address[`INDEX]][31:0];
                        
                        // write hit
                        else if(wren) begin
                            if(address[`BLOCK_OFFSET]) mem3[address[`INDEX]][63:32] <= din;
                            else                       mem3[address[`INDEX]][31:0] <= din;
                            dirty3[address[`INDEX]] <= 1;
                            dout <= 0;
                        end

                        // update lru data  
                        if (lru1[address[`INDEX]] <= lru3[address[`INDEX]]) lru1[address[`INDEX]] <= lru1[address[`INDEX]] + 1;
                        if (lru2[address[`INDEX]] <= lru3[address[`INDEX]]) lru2[address[`INDEX]] <= lru2[address[`INDEX]] + 1;
                        if (lru0[address[`INDEX]] <= lru3[address[`INDEX]]) lru0[address[`INDEX]] <= lru0[address[`INDEX]] + 1;
                        lru3[address[`INDEX]] <= 0;                      
                    end

                    // miss
                    else state <= miss;
                end
                miss: begin
                    // miss state logic

                    // one of the ways is invalid, then no need to evict
                    // way 0 is invalid
                    if(~valid0[address[`INDEX]]) begin
                        mem0[address[`INDEX]] <= mdin;
                        tag0[address[`INDEX]] <= address[`TAG];
                        dirty0[address[`INDEX]] <= 0;
                        valid0[address[`INDEX]] <= 1;
                    end

                    // way1 is invalid
                    else if(~valid1[address[`INDEX]]) begin
                        mem1[address[`INDEX]] <= mdin;
                        tag1[address[`INDEX]] <= address[`TAG];
                        dirty1[address[`INDEX]] <= 0;
                        valid1[address[`INDEX]] <= 1;
                    end

                    // way2 is invalid
                    else if(~valid2[address[`INDEX]]) begin
                        mem2[address[`INDEX]] <= mdin;
                        tag2[address[`INDEX]] <= address[`TAG];
                        dirty2[address[`INDEX]] <= 0;
                        valid2[address[`INDEX]] <= 1;
                    end

                    // way3 is invalid
                    else if(~valid3[address[`INDEX]]) begin
                        mem3[address[`INDEX]] <= mdin;
                        tag3[address[`INDEX]] <= address[`TAG];
                        dirty3[address[`INDEX]] <= 0;
                        valid3[address[`INDEX]] <= 1;
                    end

                    // when all the ways are valid, then check which way is lru and then evict that way to accomodate new block
                    // way0 is lru
                    else if(lru0[address[`INDEX]] == 3) begin
                        // dirty block writeback
                        if (dirty0[address[`INDEX]] == 1) begin
                            mwraddress <= {tag0[address[`INDEX]], address[`INDEX], 3'b000};
                            mwren <= 1;
                            mdout <= mem0[address[`INDEX]];
                        end
                        mem0[address[`INDEX]] <= mdin;
                        tag0[address[`INDEX]] <= address[`TAG];
                        valid0[address[`INDEX]] <= 1;
                        dirty0[address[`INDEX]] <= 0;
                    end

                    // way1 is lru
                    else if(lru1[address[`INDEX]] == 3) begin
                        // dirty block writeback
                        if (dirty1[address[`INDEX]] == 1) begin
                            mwraddress <= {tag1[address[`INDEX]], address[`INDEX], 3'b000};
                            mwren <= 1;
                            mdout <= mem1[address[`INDEX]];
                        end
                        mem1[address[`INDEX]] <= mdin;
                        tag1[address[`INDEX]] <= address[`TAG];
                        valid1[address[`INDEX]] <= 1;
                        dirty1[address[`INDEX]] <= 0;
                    end

                    // way2 is lru
                    else if(lru2[address[`INDEX]] == 3) begin
                        // dirty block writeback
                        if (dirty2[address[`INDEX]] == 1) begin
                            mwraddress <= {tag2[address[`INDEX]], address[`INDEX], 3'b000};
                            mwren <= 1;
                            mdout <= mem2[address[`INDEX]];
                        end
                        mem2[address[`INDEX]] <= mdin;
                        tag2[address[`INDEX]] <= address[`TAG];
                        valid2[address[`INDEX]] <= 1;
                        dirty2[address[`INDEX]] <= 0;
                    end

                    // way3 is lru
                    else if(lru3[address[`INDEX]] == 3) begin
                        // dirty block writeback
                        if (dirty3[address[`INDEX]] == 1) begin
                            mwraddress <= {tag3[address[`INDEX]], address[`INDEX], 3'b000};
                            mwren <= 1;
                            mdout <= mem3[address[`INDEX]];
                        end
                        mem3[address[`INDEX]] <= mdin;
                        tag3[address[`INDEX]] <= address[`TAG];
                        valid3[address[`INDEX]] <= 1;
                        dirty3[address[`INDEX]] <= 0;
                    end

                    // finish miss state work and go back to idle state
                    state <= idle;
                end
            endcase
        end
    end

    // hit_miss, dout, mwren, mdout, mwraddress is driven from the always_ff block

    assign mrdaddress = {address[`TAG], address[`INDEX], 3'b000};

    // mrden (combinational) - goes high when none of the 4 ways match the incoming address,
    // which starts memory fetch in the same cycle the miss is detected.
    // mrden = !(hit in way0 || hit in way1 || hit in way2 || hit in way3)
    assign mrden =    ~((valid0[address[`INDEX]] && (tag0[address[`INDEX]] == address[`TAG]))
                      ||(valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG])) 
                      ||(valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG])) 
                      ||(valid3[address[`INDEX]] && (tag3[address[`INDEX]] == address[`TAG])));

endmodule