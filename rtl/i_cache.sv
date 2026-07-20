// Instruction cache - read only
`define I_TAG         31:13 // 19 bits
`define I_INDEX       12:2  // 11 bits
`define I_BYTE_OFFSET 1:0   // 2 bits (word aligned)

module i_cache #(
    parameter SIZE = 16*1024*8,
    parameter NWAYS = 2,
    parameter NSETS = 2048,
    parameter BLOCK_SIZE = 32,
    parameter WIDTH = 32,  // cpu data width
    parameter MWIDTH = 32, //same as block size
    parameter INDEX_WIDTH = 11,
    parameter TAG_WIDTH = 19,
    parameter OFFSET_WIDTH = 2
)(
    input logic clk, reset,
    input logic [WIDTH-1: 0] address,    // address from cpu
    input logic rden,                    // read enable, high when fetching instructions
    output logic hit_miss,               // 1 it hit, 0 while handling miss
    output logic [WIDTH-1: 0] dout,      // 32 bit instr returned to cpu
    output logic [WIDTH-1:0] mrdaddress, // address sent to memory to fetch missing block
    output logic mrden,                  // memory read enable
    input logic [MWIDTH-1: 0] mdin       // 32 bit instruction block from memory
);

    // way 0
    logic valid0 [0:NSETS-1];
    logic lru0   [0:NSETS-1];
    logic [TAG_WIDTH-1:0] tag0 [0:NSETS-1];
    logic [MWIDTH-1:0]    mem0 [0:NSETS-1];

    // way 1
    logic valid1 [0:NSETS-1];
    logic lru1   [0:NSETS-1];
    logic [TAG_WIDTH-1:0] tag1 [0:NSETS-1];
    logic [MWIDTH-1:0]    mem1 [0:NSETS-1];

    parameter idle = 0;
    parameter miss = 1;

    logic state;

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= idle;
            hit_miss <= 0;
            dout <= 0;
            for (int i=0; i < NSETS; i++) begin
                valid0[i] <= 0; lru0[i] <= 0;
                valid1[i] <= 0; lru1[i] <= 0;
            end
        end
        else begin
            case(state) 
                idle: begin
                    // idle state logic

                    // check hit or miss status
                    hit_miss <=   (valid0[address[`I_INDEX]] && (tag0[address[`I_INDEX]] == address[`I_TAG]))
                                ||(valid1[address[`I_INDEX]] && (tag1[address[`I_INDEX]] == address[`I_TAG]));

                    // null request - do nothing
                    if(~rden) state <= idle;

                    // check way0
                    else if(valid0[address[`I_INDEX]] && (tag0[address[`I_INDEX]] == address[`I_TAG])) begin
                        // read hit
                        if (rden) dout <= mem0[address[`I_INDEX]];

                        // update lru
                        lru0[address[`I_INDEX]] <= 0;
                        lru1[address[`I_INDEX]] <= 1;
                    end

                    // check way1
                    else if(valid1[address[`I_INDEX]] && (tag1[address[`I_INDEX]] == address[`I_TAG])) begin
                        // read hit
                        if (rden) dout <= mem1[address[`I_INDEX]];

                        // update lru
                        lru1[address[`I_INDEX]] <= 0;
                        lru0[address[`I_INDEX]] <= 1;
                    end

                    // miss
                    else state <= miss;
                end
                miss: begin
                    // miss state logic

                    // if one of the ways is invalid, then no need to evict
                    // way0 is invalid
                    if(~valid0[address[`I_INDEX]]) begin
                        mem0[address[`I_INDEX]] <= mdin;
                        tag0[address[`I_INDEX]] <= address[`I_TAG];
                        valid0[address[`I_INDEX]] <= 1;
                        lru0[address[`I_INDEX]]  <= 0;
                        lru1[address[`I_INDEX]]  <= 1;
                    end

                    // way1 is invalid
                    else if(~valid1[address[`I_INDEX]]) begin
                        mem1[address[`I_INDEX]] <= mdin;
                        tag1[address[`I_INDEX]] <= address[`I_TAG];
                        valid1[address[`I_INDEX]] <= 1;
                        lru1[address[`I_INDEX]]  <= 0;
                        lru0[address[`I_INDEX]]  <= 1;
                    end

                    // when all the ways are valid, then check which way is lru and then evict that way to accomodate new block
                    // way0 is lru
                    else if(lru0[address[`I_INDEX]] == 1) begin
                        // no need to manage dirt block since there are no writes to imem
                        mem0[address[`I_INDEX]] <= mdin;
                        tag0[address[`I_INDEX]] <= address[`I_TAG];
                        valid0[address[`I_INDEX]] <= 1;
                        lru0[address[`I_INDEX]]  <= 0;
                        lru1[address[`I_INDEX]]  <= 1;
                    end

                    // way1 is lru
                    else if(lru1[address[`I_INDEX]] == 1) begin
                        mem1[address[`I_INDEX]] <= mdin;
                        tag1[address[`I_INDEX]] <= address[`I_TAG];
                        valid1[address[`I_INDEX]] <= 1;
                        lru1[address[`I_INDEX]]  <= 0;
                        lru0[address[`I_INDEX]]  <= 1;
                    end

                    // finish miss state work and go back to idle state
                    state <= idle;
                end
            endcase
        end
    end

    // hit_miss, dout driven from the alway_ff block

    assign mrdaddress = {address[`I_TAG], address[`I_INDEX], 2'b00};

    // high if !(hit in way0 || hit in way1)
    assign mrden =  (rden | wren) &
                   ~((valid0[address[`I_INDEX]] && (tag0[address[`I_INDEX]] == address[`I_TAG]))
                   ||(valid1[address[`I_INDEX]] && (tag1[address[`I_INDEX]] == address[`I_TAG])));

endmodule