module AHBlite_64bit_bridge (
    input HCLK,

    input [1: 0] HTRANS,
    input [63:0] HWDATA_64, 
    input [31:0] HADDR,
    input [31:0] HRDATA_32,

    output [63:0] HRDATA_64,
    output [31:0] HWDATA_32
);

wire [31:0] hrdata_lo;
wire [31:0] hrdata_hi;

reg A_2;

always @(posedge HCLK) begin
    if (HTRANS[1]) begin
        A_2 <= HADDR[2];
    end
end
assign hrdata_lo = A_2 ? 32'h0000  : HRDATA_32;
assign hrdata_hi = A_2 ? HRDATA_32 : 32'h0000 ;

assign HRDATA_64 = {hrdata_hi, hrdata_lo};

assign HWDATA_32 = A_2 ? HWDATA_64[63:32]: HWDATA_64[31:0];

endmodule