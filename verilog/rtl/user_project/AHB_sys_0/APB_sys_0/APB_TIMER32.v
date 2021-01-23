/*
        APB Wrapper for TIMER32 macro 
        Automatically generated from a JSON description by Mohamed Shalan
        Generated at 2020-11-26 12:31:7 
*/

`timescale 1ns/1ns
   
module APB_TIMER32 (
	// APB Interface
	// clock and reset 
	input  wire        PCLK,    
	//input  wire        PCLKG,   // Gated clock
	input  wire        PRESETn, // Reset

	// input ports
	input  wire        PSEL,    // Select
	input  wire [5:3] PADDR,   // Address
	input  wire        PENABLE, // Transfer control
	input  wire        PWRITE,  // Write control
	input  wire [31:0] PWDATA,  // Write data

	// output ports
	output wire [31:0] PRDATA,  // Read data
	output wire        PREADY,
	// Device ready

	// IP Interface
	output		IRQ,

	// TMR register/fields
	input [31:0] TMR,


	// PRE register/fields
	output [31:0] PRE,


	// TMRCMP register/fields
	output [31:0] TMRCMP,


	// TMROV register/fields
	input [0:0] TMROV,


	// TMROVCLR register/fields
	output [0:0] TMROVCLR,


	// TMREN register/fields
	output [0:0] TMREN

);

	parameter [2:0] TMR_ADDR      = 3'h0;
	parameter [2:0] PRE_ADDR      = 3'h1;
	parameter [2:0] TMRCMP_ADDR   = 3'h2;
	parameter [2:0] TMROV_ADDR    = 3'h3;
	parameter [2:0] TMROVCLR_ADDR = 3'h4;
	parameter [2:0] TMREN_ADDR    = 3'h5;
	parameter [2:0] IRQEN_ADDR    = 3'h6;

	wire rd_enable;
	wire wr_enable;
	assign  rd_enable = PSEL & (~PWRITE); 
	assign  wr_enable = PSEL & PWRITE & (PENABLE); 
	assign  PREADY = 1'b1;
    

    reg [31:0] PRE;

    reg [31:0] TMRCMP;

    reg [0:0] TMROVCLR;

    reg [0:0] TMREN;

    wire[31:0] TMR;
    wire[0:0] TMROV;

	// Register: PRE
	wire PRE_select = wr_enable & (PADDR[5:3] == PRE_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            PRE <= 32'h0;
        else if (PRE_select)
            PRE <= PWDATA;
    end
    
	// Register: TMRCMP
	wire TMRCMP_select = wr_enable & (PADDR[5:3] == TMRCMP_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            TMRCMP <= 32'h0;
        else if (TMRCMP_select)
            TMRCMP <= PWDATA;
    end
    
	// Register: TMROVCLR
	wire TMROVCLR_select = wr_enable & (PADDR[5:3] == TMROVCLR_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            TMROVCLR <= 1'h0;
        else if (TMROVCLR_select)
            TMROVCLR <= PWDATA;
    end
    
	// Register: TMREN
	wire TMREN_select = wr_enable & (PADDR[5:3] == TMREN_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            TMREN <= 1'h0;
        else if (TMREN_select)
            TMREN <= PWDATA;
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
    
	assign IRQ = ( TMROV & IRQEN[0] ) ;

	assign PRDATA = 
		(PADDR[5:3] == TMR_ADDR) ? TMR : 
		(PADDR[5:3] == PRE_ADDR) ? PRE : 
		(PADDR[5:3] == TMRCMP_ADDR) ? TMRCMP : 
		(PADDR[5:3] == TMROV_ADDR) ? {31'd0,TMROV} : 
		(PADDR[5:3] == TMROVCLR_ADDR) ? {31'd0,TMROVCLR} : 
		(PADDR[5:3] == TMREN_ADDR) ? {31'd0,TMREN} : 
		(PADDR[5:3] == IRQEN_ADDR) ? {31'd0,IRQEN} : 
		32'hDEADBEEF;

endmodule