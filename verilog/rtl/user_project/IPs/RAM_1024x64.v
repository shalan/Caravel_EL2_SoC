// `define DBG_RAM

module RAM_1024x64 (
`ifdef USE_POWER_PINS
	input VPWR,
	input VGND,
`endif
    input           CLK,
    input   [7:0]   WE,
    input           EN,
    input   [63:0]  Di,
    output  [63:0]  Do,
    input   [9:0]   A
);
   
`ifdef USE_DFFRAM_BEH
	DFFRAM_beh 
`else
	DFFRAM_4K
`endif
    #(.COLS(4)) LBANK (
    `ifdef USE_POWER_PINS
            .VPWR(VPWR),
            .VGND(VGND),
	`endif
            .CLK(CLK),
            .WE(WE[3:0]),
            .EN(EN),
            .Di(Di[31:0]),
            .Do(Do[31:0]),
            .A(A[9:0])
    );

`ifdef USE_DFFRAM_BEH
	DFFRAM_beh 
`else
	DFFRAM_4K
`endif #(.COLS(4)) HBANK (
    `ifdef USE_POWER_PINS
            .VPWR(VPWR),
            .VGND(VGND),
	`endif
            .CLK(CLK),
            .WE(WE[7:4]),
            .EN(EN),
            .Di(Di[63:32]),
            .Do(Do[63:32]),
            .A(A[9:0])
    );

`ifdef DBG_RAM
    always @(EN, WE, Di, Do, A) 
        if(EN) begin
             $display("WE: %h, Di: %h , Do: %h, A: %h, time: %d",WE, Di, Do, A, $time);
        end
`endif

endmodule    