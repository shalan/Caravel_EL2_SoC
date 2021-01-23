/*
    32 lines x 16 bytes Direct Mapped Cache
*/
`ifdef NO_HC_CACHE

module DMC_32x16 (
`ifdef USE_POWER_PINS
    input VPWR,
    input VGND,
`endif
    input wire          clk,
    input wire          rst_n,
    // 
    input wire  [23:0]  A,
    input wire  [23:0]  A_h,
    output wire [63:0]  Do,
    output wire         hit,
    //
    input wire [127:0]  line,
    input wire          wr
);

    //
    reg [127:0] LINES   [31:0];
    reg [14:0]  TAGS    [31:0];
    reg         VALID   [31:0];

    wire [3:0]  offset  = A[3:0];
    wire [4:0]  index   = A[8:4];
    wire [14:0] tag     = A[23:9];

    wire [4:0]  index_h   = A_h[8:4];
    wire [14:0] tag_h     = A_h[23:9];

    
    assign  hit =   VALID[index_h] & (TAGS[index_h] == tag_h);

    
    assign  Do  =   (offset[3] == 1'd0) ?  LINES[index][63:0] : LINES[index][127:64];

    // clear the VALID flags
    integer i;
    always @ (posedge clk or negedge rst_n)
        if(!rst_n) 
            for(i=0; i<32; i=i+1)
                VALID[i] <= 1'b0;
        else  if(wr)  VALID[index]    <= 1'b1;

    always @(posedge clk)
        if(wr) begin
            LINES[index]    <= line;
            TAGS[index]     <= tag;
        end

endmodule
`endif
