/*
        A Wrapper for EL2 to simplify its bus interfaces.
        Mohamed Shalan

*/

`ifndef AW
`define AW 32
`endif

`ifndef DW
`define DW 64
`endif


module el2_n5_soc_wrapper (
`ifdef USE_POWER_PINS
    input wire VPWR,
    input wire VGND,
`endif
    input  wire         HCLK,				// System clock
    input  wire         HRESETn,			// System Reset, active low

   // AHB-LITE MASTER PORT for Instructions
    output wire [`AW-1:0]  HADDR,			// AHB transaction address
    output wire [ 2:0]   HSIZE,				// AHB size: byte, half-word or word
    output wire [ 1:0]  HTRANS,				// AHB transfer: non-sequential only
    output wire [`DW-1:0]  HWDATA,			// AHB write-data
    output wire         HWRITE,				// AHB write control
    input  wire [`DW-1:0]  HRDATA,			// AHB read-data
    input  wire         HREADY,				// AHB stall signal

    // MISCELLANEOUS 
    input  wire         NMI,				// Non-maskable interrupt input
    input  wire [30:0]  IRQ
);

        wire [31:0] ifu_haddr;
        wire [2:0] ifu_hburst;
        wire [3:0] ifu_hprot;
        wire [2:0] ifu_hsize;
        wire [1:0] ifu_htrans;
        wire [63:0] ifu_hrdata;
        wire [31:0] lsu_haddr;
        wire [2:0] lsu_hburst;
        wire [3:0] lsu_hprot;
        wire [2:0] lsu_hsize;
        wire [1:0] lsu_htrans;
        wire [63:0] lsu_hwdata;
        wire [63:0] lsu_hrdata;

        wire lsu_hwrite;
        wire ifu_hwrite;

        wire ifu_hready;
        wire lsu_hready;

Mux2M1S MUX (
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	
	.HADDR_M1(ifu_haddr),
	.HTRANS_M1(ifu_htrans),
	.HWRITE_M1(ifu_hwrite),
	.HSIZE_M1(ifu_hsize),
	.HWDATA_M1(),
	.HREADY_M1(ifu_hready),
	.HRDATA_M1(ifu_hrdata),
	
	.HADDR_M2(lsu_haddr),
	.HTRANS_M2(lsu_htrans),
	.HWRITE_M2(lsu_hwrite),
	.HSIZE_M2(lsu_hsize),
	.HWDATA_M2(lsu_hwdata),
	.HREADY_M2(lsu_hready),
	.HRDATA_M2(lsu_hrdata),
	
	.HREADY(HREADY),
	.HRDATA(HRDATA),
	.HADDR(HADDR),
	.HTRANS(HTRANS),
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA)
);


el2_swerv_wrapper el2 ( 
`ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND),
`endif
        .clk(HCLK), 
        .rst_l(HRESETn), 
        .dbg_rst_l(HRESETn), 
        
        .rst_vec(31'b0), 
        .nmi_int(NMI), 
        .nmi_vec(31'b0),
        
        // Unused I/Os
        .jtag_id(31'b0),
        .trace_rv_i_insn_ip(),
        .trace_rv_i_address_ip(), 
        .trace_rv_i_valid_ip(),
        .trace_rv_i_exception_ip(),
        .trace_rv_i_ecause_ip(), 
        .trace_rv_i_interrupt_ip(),
        .trace_rv_i_tval_ip(), 
        
        .haddr(ifu_haddr), 
        .hburst(), //
        .hmastlock(), //
        .hprot(), 
        .hsize(ifu_hsize), 
        .htrans(ifu_htrans), 
        .hwrite(ifu_hwrite), 
        .hrdata(ifu_hrdata), 
        .hready(ifu_hready), 
        .hresp(1'b0), 
        
        .lsu_haddr(lsu_haddr), 
        .lsu_hburst(), 
        .lsu_hmastlock(), 
        .lsu_hprot(), 
        .lsu_hsize(lsu_hsize), 
        .lsu_htrans(lsu_htrans), 
        .lsu_hwrite(lsu_hwrite), 
        .lsu_hwdata(lsu_hwdata), 
        .lsu_hrdata(lsu_hrdata), 
        .lsu_hready(lsu_hready), 
        .lsu_hresp(1'b0), 
        
        // Un-used I/Os
        .sb_haddr(), 
        .sb_hburst(),
        .sb_hmastlock(),
        .sb_hprot(),
        .sb_hsize(),
        .sb_htrans(),
        .sb_hwrite(), 
        .sb_hwdata(),
        .sb_hrdata(64'b0),
        .sb_hready(1'b1),
        .sb_hresp(1'b0), 
        
        .dma_hsel(1'b0),
        .dma_haddr(32'b0), 
        .dma_hburst(3'b0),
        .dma_hmastlock(1'b0),
        .dma_hprot(4'b0),
        .dma_hsize(3'b0),
        .dma_htrans(2'b0), 
        .dma_hwrite(1'b0),
        .dma_hwdata(64'b0),
        .dma_hreadyin(1'b1),
        .dma_hrdata(),
        .dma_hreadyout(), 
        .dma_hresp(), 
        
        .dccm_ext_in_pkt(48'b0),
        .iccm_ext_in_pkt(48'b0),
        .ic_data_ext_in_pkt(48'b0), 
        .ic_tag_ext_in_pkt(24'b0),
        
        .dec_tlu_perfcnt0(),
        .dec_tlu_perfcnt1(),
        .dec_tlu_perfcnt2(),
        .dec_tlu_perfcnt3(), 
        
        .jtag_tck(1'b0),
        .jtag_tdi(1'b0),
        .jtag_tdo(),
        
        .mpc_debug_halt_ack(),
        .mpc_debug_run_ack(), 
        
        .debug_brkpt_status(), 
        .o_cpu_halt_ack(),
        .o_cpu_halt_status(),
        .o_debug_mode_status(), 
        .o_cpu_run_ack(),
   
        .core_id(28'h000_0000),

        .ifu_bus_clk_en(1'b1),
        .lsu_bus_clk_en(1'b1),
        .dbg_bus_clk_en(1'b0), 
        .dma_bus_clk_en(1'b0), 
                
        .jtag_trst_n(HRESETn),
        .jtag_tms(1'b0),

        .i_cpu_halt_req(1'b0),
        .i_cpu_run_req(1'b0),

        .scan_mode(1'b0),
        .mbist_mode(1'b0),
        
        .mpc_reset_run_req(1'b1),
        .mpc_debug_run_req(1'b0),
        .mpc_debug_halt_req(1'b0),
        
        .timer_int(1'b0), 
        .soft_int(1'b0), 
        .extintsrc_req(IRQ[30:0])  // IRQ [30:0]
    );



endmodule

/*
        A quick and rough AHB master multiplexor
        Each master is given the bus till it gives it up.
        This is fine for IFU and LSU AHB master ports.
*/
module Mux2M1S #(parameter SZ=64) (
	input HCLK,
	input HRESETn,
	
	input  [31:0] 	HADDR_M1,
	input   [1:0] 	HTRANS_M1,
	input         	HWRITE_M1,
	input   [2:0] 	HSIZE_M1,
	input  [SZ-1:0]	HWDATA_M1,
	output		HREADY_M1,
	output [SZ-1:0] HRDATA_M1,
	
	input  [31:0] 	HADDR_M2,
	input   [1:0] 	HTRANS_M2,
	input         	HWRITE_M2,
	input   [2:0] 	HSIZE_M2,
	input  [SZ-1:0]	HWDATA_M2,
	output		HREADY_M2,
	output [SZ-1:0]	HRDATA_M2,
	
	input		HREADY,
	input  [SZ-1:0]	HRDATA,
	output [31:0] 	HADDR,
	output  [1:0] 	HTRANS,
	output        	HWRITE,
	output  [2:0] 	HSIZE,
	output [SZ-1:0]	HWDATA
);
	
	localparam [4:0] S0 = 1;
	localparam [4:0] S1 = 2;
	localparam [4:0] S2 = 4;
	localparam [4:0] S3 = 8;
	localparam [4:0] S4 = 16;

	reg [4:0] 		state, nstate;
	always @(posedge HCLK or negedge HRESETn)
		if(!HRESETn) state <= S0;
		else state <= nstate;

	always @* begin
		nstate = S0;
		case (state)
		  S0  : if(HTRANS_M1[1]) nstate = S1; else if(HTRANS_M2[1]) nstate = S2; else nstate = S0;
		  S1  : if(!HTRANS_M1[1] & HREADY) nstate = S2; else nstate = S1;
		  S2  : if(!HTRANS_M2[1] & HREADY) nstate = S1; else nstate = S2;
		endcase
	end

	assign HREADY_M1 = (state == S0) ? 1'b1 : (state == S1) ? HREADY : ((state == S2) && (HTRANS_M2[1] == 1'b0)) ? HREADY : 1'b0;
	assign HREADY_M2 = (state == S0) ? 1'b1 : (state == S2) ? HREADY : ((state == S1) && (HTRANS_M1[1] == 1'b0)) ? HREADY : 1'b0;
	
	assign HRDATA_M1 = HRDATA;
	assign HRDATA_M2 = HRDATA;
	
	reg [1:0] htrans;
	always @*
		case (state)
			S0: htrans = (HTRANS_M1[1]) ? HTRANS_M1 : 2'b00;
			S1: htrans = (HTRANS_M1[1]) ? HTRANS_M1 : HTRANS_M2;
			S2: htrans = (HTRANS_M2[1]) ? HTRANS_M2 : HTRANS_M1;
                        default: htrans = 2'b00;
		endcase
	
	reg [31:0] haddr;
	always @*
		case (state)
			S0: haddr = (HTRANS_M1[1]) ? HADDR_M1 : 32'b0;
			S1: haddr = (HTRANS_M1[1]) ? HADDR_M1 : HADDR_M2;
			S2: haddr = (HTRANS_M2[1]) ? HADDR_M2 : HADDR_M1;
                        default: haddr = 32'b0;
		endcase
	
	reg [0:0] hwrite;
	always @*
		case (state)
			S0: hwrite = (HTRANS_M1[1]) ? HWRITE_M1 : 1'b0;
			S1: hwrite = (HTRANS_M1[1]) ? HWRITE_M1 : HWRITE_M2;
			S2: hwrite = (HTRANS_M2[1]) ? HWRITE_M2 : HWRITE_M1;
                        default: hwrite = 1'b0;
		endcase
		
	reg [2:0] hsize;
	always @*
		case (state)
			S0: hsize = (HTRANS_M1[1]) ? HSIZE_M1 : 3'b0;
			S1: hsize = (HTRANS_M1[1]) ? HSIZE_M1 : HSIZE_M2;
			S2: hsize = (HTRANS_M2[1]) ? HSIZE_M2 : HSIZE_M1;
                        default: hsize = 3'b0;
		endcase
			
	reg [SZ-1:0] hwdata;
	always @*
		case (state)
			S0: hwdata = 64'b0;
			S1: hwdata = HWDATA_M1;
			S2: hwdata = HWDATA_M2;
                        default: hwdata = 64'b0;
		endcase
			
	assign HTRANS = htrans;
	assign HADDR = haddr;
	assign HWDATA = hwdata;
	assign HSIZE = hsize;
	assign HWRITE = hwrite;
	
endmodule