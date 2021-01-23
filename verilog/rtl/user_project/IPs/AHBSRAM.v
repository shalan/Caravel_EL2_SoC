
`ifndef AW
`define AW 32
`endif

`ifndef DW
`define DW 64
`endif

module AHBSRAM #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter AW       = 9) // Address width
 (
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
  input  wire           HCLK,      // system bus clock
  input  wire           HRESETn,   // system bus reset
  input  wire           HSEL,      // AHB peripheral select
  input  wire           HREADY,    // AHB ready input
  input  wire [1:0]     HTRANS,    // AHB transfer type
  input  wire [2:0]     HSIZE,     // AHB hsize
  input  wire           HWRITE,    // AHB hwrite
  input  wire [`AW-1:0] HADDR,     // AHB address bus
  input  wire [`DW-1:0] HWDATA,    // AHB write data bus
  output wire           HREADYOUT, // AHB ready output to S->M mux
  output wire [1:0]     HRESP,     // AHB response
  output wire [`DW-1:0] HRDATA,    // AHB read data bus

  input  wire [`DW-1:0] SRAMRDATA, // SRAM Read Data
  output wire [7:0]     SRAMWEN,   // SRAM write enable (active high)
  output wire [`DW-1:0] SRAMWDATA, // SRAM write data
  output wire           SRAMCS0,
  output wire [AW:0]   SRAMADDR  // SRAM address
);   // SRAM Chip Select  (active high)

   // ----------------------------------------------------------
   // Internal state
   // ----------------------------------------------------------
   reg  [AW:0]               buf_addr;        // Write address buffer
   reg  [ 7:0]               buf_we;          // Write enable buffer (data phase)
   reg                       buf_hit;         // High when AHB read address
                                              // matches buffered address
   reg  [`DW-1:0]            buf_data;        // AHB write bus buffered
   reg                       buf_pend;        // Buffer write data valid
   reg                       buf_data_en;     // Data buffer write enable (data phase)

   // ----------------------------------------------------------
   // Read/write control logic
   // ----------------------------------------------------------

   wire        ahb_access   = HTRANS[1] & HSEL & HREADY;
   wire        ahb_write    = ahb_access &  HWRITE;
   wire        ahb_read     = ahb_access & (~HWRITE);


   // Stored write data in pending state if new transfer is read
   //   buf_data_en indicate new write (data phase)
   //   ahb_read    indicate new read  (address phase)
   //   buf_pend    is registered version of buf_pend_nxt
   wire        buf_pend_nxt = (buf_pend | buf_data_en) & ahb_read;

   // RAM write happens when
   // - write pending (buf_pend), or
   // - new AHB write seen (buf_data_en) at data phase,
   // - and not reading (address phase)
   wire        ram_write    = (buf_pend | buf_data_en)  & (~ahb_read); // ahb_write

   // RAM WE is the buffered WE
   assign      SRAMWEN  = {8{ram_write}} & buf_we[7:0];

   // RAM address is the buffered address for RAM write otherwise HADDR
   assign      SRAMADDR = ahb_read ? HADDR[AW+2:3] : buf_addr;

   // RAM chip select during read or write
   wire SRAMCS_src; 
   assign      SRAMCS_src   = ahb_read | ram_write;
   assign SRAMCS0 = SRAMCS_src; 
  
   // ----------------------------------------------------------
   // Byte lane decoder and next state logic
   // ----------------------------------------------------------
  
  // REVISE ? 
   wire       tx_byte        = (~HSIZE[1]) & (~HSIZE[0]);  // 00
   wire       tx_half        = (~HSIZE[1]) &   HSIZE[0];   // 01
   wire       tx_word        =   HSIZE[1]  & (~HSIZE[0]);  // 10
   wire       tx_double_word =   HSIZE[1]  &   HSIZE[0];   // 11

   wire       byte_at_000 = tx_byte & (~HADDR[2]) & (~HADDR[1]) &  (~HADDR[0]);
   wire       byte_at_001 = tx_byte & (~HADDR[2]) & (~HADDR[1]) &  (HADDR[0]);
   wire       byte_at_010 = tx_byte & (~HADDR[2]) & (HADDR[1])  &  (~HADDR[0]);
   wire       byte_at_011 = tx_byte & (~HADDR[2]) & (HADDR[1])  &  (HADDR[0]);

   wire       byte_at_100 = tx_byte & (HADDR[2]) & (~HADDR[1])  &  (~HADDR[0]);
   wire       byte_at_101 = tx_byte & (HADDR[2]) & (~HADDR[1])  &  (HADDR[0]);
   wire       byte_at_110 = tx_byte & (HADDR[2]) & (HADDR[1])   &  (~HADDR[0]);
   wire       byte_at_111 = tx_byte & (HADDR[2]) & (HADDR[1])   &  (HADDR[0]);

   wire       half_at_000 = tx_half & (~HADDR[2]) & (~HADDR[1]);
   wire       half_at_010 = tx_half & (~HADDR[2]) & HADDR[1];

   wire       half_at_100 = tx_half & HADDR[2] & (~HADDR[1]);
   wire       half_at_110 = tx_half & HADDR[2] &  HADDR[1];

   wire       word_at_000 = tx_word & (~HADDR[2]);
   wire       word_at_100 = tx_word & HADDR[2];

   wire       double_word_at_00 = tx_double_word;

   wire       byte_sel_0 = double_word_at_00 | word_at_000 | half_at_000 | byte_at_000;
   wire       byte_sel_1 = double_word_at_00 | word_at_000 | half_at_000 | byte_at_001;
   wire       byte_sel_2 = double_word_at_00 | word_at_000 | half_at_010 | byte_at_010;
   wire       byte_sel_3 = double_word_at_00 | word_at_000 | half_at_010 | byte_at_011;

   wire       byte_sel_4 = double_word_at_00 | word_at_100 | half_at_100 | byte_at_100;
   wire       byte_sel_5 = double_word_at_00 | word_at_100 | half_at_100 | byte_at_101;
   wire       byte_sel_6 = double_word_at_00 | word_at_100 | half_at_110 | byte_at_110;
   wire       byte_sel_7 = double_word_at_00 | word_at_100 | half_at_110 | byte_at_111;

   // Address phase byte lane strobe
   wire [7:0] buf_we_nxt = { byte_sel_7 & ahb_write,
                             byte_sel_6 & ahb_write,
                             byte_sel_5 & ahb_write,
                             byte_sel_4 & ahb_write,
                             byte_sel_3 & ahb_write,
                             byte_sel_2 & ahb_write,
                             byte_sel_1 & ahb_write,
                             byte_sel_0 & ahb_write };

   // ----------------------------------------------------------
   // Write buffer
   // ----------------------------------------------------------

   // buf_data_en is data phase write control
   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_data_en <= 1'b0;
     else
       buf_data_en <= ahb_write;
    
   always @(posedge HCLK)
     if(buf_we[7] & buf_data_en)
       buf_data[63:56] <= HWDATA[63:56];

   always @(posedge HCLK)
     if(buf_we[6] & buf_data_en)
       buf_data[55:48] <= HWDATA[55:48];
   
   always @(posedge HCLK)
     if(buf_we[5] & buf_data_en)
       buf_data[47:40] <= HWDATA[47:40];
   
   always @(posedge HCLK)
     if(buf_we[4] & buf_data_en)
       buf_data[39:32] <= HWDATA[39:32];

   always @(posedge HCLK)
     if(buf_we[3] & buf_data_en)
       buf_data[31:24] <= HWDATA[31:24];

   always @(posedge HCLK)
     if(buf_we[2] & buf_data_en)
       buf_data[23:16] <= HWDATA[23:16];

   always @(posedge HCLK)
     if(buf_we[1] & buf_data_en)
       buf_data[15: 8] <= HWDATA[15: 8];

   always @(posedge HCLK)
     if(buf_we[0] & buf_data_en)
       buf_data[ 7: 0] <= HWDATA[ 7: 0];

   // buf_we keep the valid status of each byte (data phase)
   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_we <= 8'b0000;
     else if(ahb_write)
       buf_we <= buf_we_nxt;

   always @(posedge HCLK or negedge HRESETn)
     begin
     if (~HRESETn)
       buf_addr <= {AW{1'b0}};
     else if (ahb_write)
         buf_addr <= HADDR[AW+2:3];
     end
   // ----------------------------------------------------------
   // Buf_hit detection logic
   // ----------------------------------------------------------
   
   // REVISE ? 
   wire  buf_hit_nxt = (HADDR[AW+2:3] == buf_addr);

   // ----------------------------------------------------------
   // Read data merge : This is for the case when there is a AHB
   // write followed by AHB read to the same address. In this case
   // the data is merged from the buffer as the RAM write to that
   // address hasn't happened yet
   // ----------------------------------------------------------

   wire [7:0] merge1  = {7{buf_hit}} & buf_we; // data phase, buf_we indicates data is valid

   assign HRDATA =
              { 
                merge1[7] ? buf_data[63:56] : SRAMRDATA[63:56],
                merge1[6] ? buf_data[55:48] : SRAMRDATA[55:48],
                merge1[5] ? buf_data[47:40] : SRAMRDATA[47:40],
                merge1[4] ? buf_data[39:32] : SRAMRDATA[39:32],
                merge1[3] ? buf_data[31:24] : SRAMRDATA[31:24],
                merge1[2] ? buf_data[23:16] : SRAMRDATA[23:16],
                merge1[1] ? buf_data[15:8]  : SRAMRDATA[15: 8],
                merge1[0] ? buf_data[7:0]   : SRAMRDATA[ 7: 0] };

   // ----------------------------------------------------------
   // Synchronous state update
   // ----------------------------------------------------------

   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_hit <= 1'b0;
     else if(ahb_read)
       buf_hit <= buf_hit_nxt;

   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_pend <= 1'b0;
     else
       buf_pend <= buf_pend_nxt;

   // if there is an AHB write and valid data in the buffer, RAM write data
   // comes from the buffer. otherwise comes from the HWDATA
   assign SRAMWDATA = (buf_pend) ? buf_data : HWDATA[`DW-1:0];

   // ----------------------------------------------------------
   // Assign outputs
   // ----------------------------------------------------------
   assign HREADYOUT = 1'b1;
   assign HRESP     = 2'b0;


endmodule
