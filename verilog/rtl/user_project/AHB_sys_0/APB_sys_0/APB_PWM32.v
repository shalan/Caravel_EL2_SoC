/*
        APB Wrapper for PWM32 macro 
        Automatically generated from a JSON description by Mohamed Shalan
        Generated at 2020-11-26 12:31:7 
*/

`timescale 1ns/1ns
   
module APB_PWM32 (
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
	// PRE register/fields
	output [31:0] PRE,


	// TMRCMP1 register/fields
	output [31:0] TMRCMP1,


	// TMRCMP2 register/fields
	output [31:0] TMRCMP2,


	// TMREN register/fields
	output [0:0] TMREN

);

	parameter [2:0] TMRCMP1_ADDR = 3'h1;
	parameter [2:0] TMRCMP2_ADDR = 3'h2;
	parameter [2:0] TMREN_ADDR   = 3'h3;
	parameter [2:0] PRE_ADDR     = 3'h4;

	wire rd_enable;
	wire wr_enable;
	assign  rd_enable = PSEL & (~PWRITE); 
	assign  wr_enable = PSEL & PWRITE & (PENABLE); 
	assign  PREADY = 1'b1;
    

    reg [31:0] PRE;

    reg [31:0] TMRCMP1;

    reg [31:0] TMRCMP2;

    reg [0:0] TMREN;


	// Register: PRE
	wire PRE_select = wr_enable & (PADDR[5:3] == PRE_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            PRE <= 32'h0;
        else if (PRE_select)
            PRE <= PWDATA;
    end
    
	// Register: TMRCMP1
	wire TMRCMP1_select = wr_enable & (PADDR[5:3] == TMRCMP1_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            TMRCMP1 <= 32'h0;
        else if (TMRCMP1_select)
            TMRCMP1 <= PWDATA;
    end
    
	// Register: TMRCMP2
	wire TMRCMP2_select = wr_enable & (PADDR[5:3] == TMRCMP2_ADDR);

    always @(posedge PCLK or negedge PRESETn)
    begin
        if (~PRESETn)
            TMRCMP2 <= 32'h0;
        else if (TMRCMP2_select)
            TMRCMP2 <= PWDATA;
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
    
	assign PRDATA = 
		(PADDR[5:3] == TMRCMP1_ADDR) ? TMRCMP1 : 
		(PADDR[5:3] == TMRCMP2_ADDR) ? TMRCMP2 : 
		(PADDR[5:3] == TMREN_ADDR) ? {31'd0,TMREN} : 
		(PADDR[5:3] == PRE_ADDR) ? PRE : 
		32'hDEADBEEF;

endmodule