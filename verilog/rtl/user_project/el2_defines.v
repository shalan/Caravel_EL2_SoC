/*
    Workaround for LVS issue:
        Shifts input port indicies by the defined values
        so that the port lower index is zero.
        EX: core_id[31:4] --> core_id[27:0]
*/
`define CORE_ID_SH 4
`define IRQ_SH 1
`define RST_VEC_SH 1
`define NMI_VEC_SH 1
`define JTAG_ID_SH 1