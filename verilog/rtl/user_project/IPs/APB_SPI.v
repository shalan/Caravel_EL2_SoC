/*
	Mohamed Shalan (mshalan@aucegypt.edu)
*/
/*
  Registers
    datain (W): 0-7: data in  [0x00]
    datao (R): 0-7: data out  [0x00]
    cfg (W): 0:cpol, 1:cpha, 8-15: clock divider  [0x08]
    status (R): 0: done       [0x10]
    ctrl (RW): 0: go, 1:ssb    [0x18] -- updated for 64-bit arch; e.g., EL2
    IM (RW): Interrup mask regsiter [0x20] 

*/



`timescale 1ns/1ps
`default_nettype none

module APB_SPI(

    input wire PCLK,
    input wire PRESETn,
    input wire PWRITE,
    input wire [31:0] PWDATA,
    input wire [31:0] PADDR,
    input wire PENABLE,

    input PSEL,

    output wire PREADY,
    output wire [31:0] PRDATA,

    input  wire MSI,
    output wire MSO,
    output wire SSn,
    output wire SCLK,

    output IRQ

);

  parameter [2:0]   DATA_OFF  = 3'h0,
                    CFG_OFF   = 3'h1,
                    STATUS_OFF= 3'h2,
                    CTRL_OFF  = 3'h3,
                    IM_OFF    = 3'h4;

  reg   [7:0]   SPI_DATAi_REG;
  wire  [7:0]   SPI_DATAo_REG;

  reg   [1:0]   SPI_CTRL_REG;
  wire          SPI_STATUS_REG;
  reg   [9:0]   SPI_CFG_REG;

  reg   [0:0]   SPI_IM_REG;

  wire go, cpol, cpha, done, busy, csb;
  wire [7:0] datai, datao, clkdiv;

  // The Control Register -- Size: 2 -- offset: 4
  always @(posedge PCLK, negedge PRESETn)
  begin
    if(!PRESETn)
    begin
      SPI_CTRL_REG <= 2'b0;
    end
    else if(PENABLE & PWRITE & PREADY & PSEL & (PADDR[5:3] == CTRL_OFF))
      SPI_CTRL_REG <= PWDATA[1:0];
  end

  // Configuration Register -- Size; 10 -- Offset: 8
  always @(posedge PCLK, negedge PRESETn)
  begin
    if(!PRESETn)
    begin
      SPI_CFG_REG <= 10'b0;
    end
    else if(PENABLE & PWRITE & PREADY & PSEL & (PADDR[5:3] == CFG_OFF))
      SPI_CFG_REG <= PWDATA[9:0];
  end

  // Data Register -- Size: 8 -- Offset: 0
  always @(posedge PCLK, negedge PRESETn)
  begin
    if(!PRESETn)
    begin
      SPI_DATAi_REG <= 8'b0;
    end
    else if(PENABLE & PWRITE & PREADY & PSEL & (PADDR[5:3] == DATA_OFF))
      SPI_DATAi_REG <= PWDATA[7:0];
  end


  // IM Register -- Size: 1 -- Offset: 0x20
  always @(posedge PCLK, negedge PRESETn)
  begin
    if(!PRESETn)
    begin
      SPI_IM_REG <= 1'b0;
    end
    else if(PENABLE & PWRITE & PREADY & PSEL & (PADDR[5:3] == IM_OFF))
      SPI_IM_REG <= PWDATA[0:0];
  end

  assign datai          = SPI_DATAi_REG[7:0];
  assign go             = SPI_CTRL_REG[0];
  assign SSn            = ~SPI_CTRL_REG[1];
  assign cpol           = SPI_CFG_REG[0];
  assign cpha           = SPI_CFG_REG[1];
  assign clkdiv         = SPI_CFG_REG[9:2];

  assign SPI_STATUS_REG = DONE;
  assign SPI_DATAo_REG  = datao;
  
  reg DONE;

  always @(posedge PCLK, negedge PRESETn)
     begin
       if(!PRESETn)
       begin
         DONE <= 1'b0;
       end
       else if(done)
         DONE <= 1'b1;
       else if(go)
         DONE <= 1'b0;
  end

  spi_master
    #(
      .DATA_WIDTH(8),
      .CLK_DIVIDER_WIDTH(8)
      ) SPI_CTRL (
         .clk(PCLK),
         .resetb(PRESETn),
         .CPOL(cpol),
         .CPHA(cpha),
         .clk_divider(clkdiv),

         .go(go),
         .datai(datai),
         .datao(datao),
         //.busy(busy),
         .done(done),

         .dout(MSI),
         .din(MSO),
         //.csb(ss),
         .sclk(SCLK)
  );

  assign PRDATA[31:0] = (PADDR[5:3] == IM_OFF) ? {31'd0, SPI_IM_REG} :
                        (PADDR[5:3] == CTRL_OFF) ? {30'd0,SPI_CTRL_REG} :
                        (PADDR[5:3] == CFG_OFF) ? {{22'd0,SPI_CFG_REG}} :
                        (PADDR[5:3] == STATUS_OFF) ? {31'd0,SPI_STATUS_REG} :
                        (PADDR[5:3] == DATA_OFF) ? {24'd0,SPI_DATAo_REG} : 32'h0BAD_ADD0;

  assign PREADY = 1'b1;

  assign IRQ = SPI_IM_REG[0] & DONE;

endmodule