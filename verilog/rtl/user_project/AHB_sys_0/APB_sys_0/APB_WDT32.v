/*
        APB Wrapper for WDT32 macro 
        Automatically generated from a JSON description by Mohamed Shalan
        Generated at 2020-11-26 12:31:7 
*/

`timescale 1ns/1ns
   
module APB_WDT32 (
	// APB Interface
	// clock and reset 
	input  wire        PCLK,    
	//input  wire        PCLKG,   // Gated clock
	input  wire        PRESETn, // Reset

	// input ports
	input  wire        PSEL,    // Select
	input  wire [5:3]  PADDR,   // Address
	input  wire        PENABLE, // Transfer control
	input  wire        PWRITE,  // Write control
	input  wire [31:0] PWDATA,  // Write data

	// output ports
	output wire [31:0] PRDATA,  // Read data
	output wire        PREADY,
	// Device ready

	// IP Interface
	output		IRQ,

	// WDTMR register/fields
	input [31:0] WDTMR,


	// WDLOAD register/fields
	output [31:0] WDLOAD,


	// WDOV register/fields
	input [0:0] WDOV,


	// WDOVCLR register/fields
	output [0:0] WDOVCLR,


	// WDEN register/fields
	output [0:0] WDEN

);

	parameter [2:0] WDTMR_ADDR   = 3'h0;
	parameter [2:0] WDLOAD_ADDR  = 3'h1;
	parameter [2:0] WDOV_ADDR    = 3'h2;
	parameter [2:0] WDOVCLR_ADDR = 3'h3;
	parameter [2:0] WDEN_ADDR    = 3'h4;
	parameter [2:0] IRQEN_ADDR   = 3'h5;

	wire rd_enable;
	wire wr_enable;
	assign  rd_enable = PSEL & (~PWRITE); 
	assign  wr_enable = PSEL & PWRITE & (PENABLE); 
	assign  PREADY = 1'b1;
    

    reg [31:0] WDLOAD;

    reg [0:0] WDOVCLR;

    reg [0:0] WDEN;

    wire[31:0] WDTMR;
    wire[0:0] WDOV;

	// Register: WDLOAD
	wire WDLOAD_select = wr_enable & (PADDR[5:3] == WDLOAD_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            WDLOAD <= 32'h0;
        else if (WDLOAD_select)
            WDLOAD <= PWDATA;
    end
    
	// Register: WDOVCLR
	wire WDOVCLR_select = wr_enable & (PADDR[5:3] == WDOVCLR_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            WDOVCLR <= 1'h0;
        else if (WDOVCLR_select)
            WDOVCLR <= PWDATA;
    end
    
	// Register: WDEN
	wire WDEN_select = wr_enable & (PADDR[5:3] == WDEN_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            WDEN <= 1'h0;
        else if (WDEN_select)
            WDEN <= PWDATA;
    end
    

	// IRQ Enable Register @ offset 0x100
	reg[0:0] IRQEN;
	wire IRQEN_select = wr_enable & (PADDR[5:3] == IRQEN_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            IRQEN <= 1'h0;
        else if (IRQEN_select)
            IRQEN <= PWDATA;
    end
    
	assign IRQ = ( WDOV & IRQEN[0] ) ;

	assign PRDATA = 
		(PADDR[5:3] == WDTMR_ADDR) ? WDTMR : 
		(PADDR[5:3] == WDLOAD_ADDR) ? WDLOAD : 
		(PADDR[5:3] == WDOV_ADDR) ? {31'd0,WDOV} : 
		(PADDR[5:3] == WDOVCLR_ADDR) ? {31'd0,WDOVCLR} : 
		(PADDR[5:3] == WDEN_ADDR)  ? {31'd0,WDEN} : 
		(PADDR[5:3] == IRQEN_ADDR) ? {31'd0,IRQEN} : 
		32'hDEADBEEF;

endmodule