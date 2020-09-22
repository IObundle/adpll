`define ADPLL_ADDR_W 5


`define ADPLL_LOCK (`ADPLL_ADDR_W'd0)  // read
`define ADPLL_SAT (`ADPLL_ADDR_W'd23)  // read

`define ADPLL_SOFT_RST (`ADPLL_ADDR_W'd1) //write
`define FCW (`ADPLL_ADDR_W'd2) //write
`define ADPLL_MODE (`ADPLL_ADDR_W'd3) //write
`define ADPLL_EN (`ADPLL_ADDR_W'd4) //write
`define ALPHA_L (`ADPLL_ADDR_W'd5) //write
`define ALPHA_M (`ADPLL_ADDR_W'd6) //write
`define ALPHA_S_RX (`ADPLL_ADDR_W'd7) //write
`define ALPHA_S_TX (`ADPLL_ADDR_W'd8) //write
`define BETA (`ADPLL_ADDR_W'd9) //write
`define LAMBDA_RX (`ADPLL_ADDR_W'd10) //write
`define LAMBDA_TX (`ADPLL_ADDR_W'd11) //write
`define IIR_N_RX (`ADPLL_ADDR_W'd12) //write
`define IIR_N_TX (`ADPLL_ADDR_W'd13) //write
`define FCW_MOD (`ADPLL_ADDR_W'd14) //write
`define DCO_C_L_WORD_TEST (`ADPLL_ADDR_W'd15) //write
`define DCO_C_M_WORD_TEST (`ADPLL_ADDR_W'd16) //write
`define DCO_C_S_WORD_TEST (`ADPLL_ADDR_W'd17) //write
`define DCO_PD_TEST (`ADPLL_ADDR_W'd18) //write
`define TDC_PD_TEST (`ADPLL_ADDR_W'd19) //write
`define TDC_PD_INJ_TEST (`ADPLL_ADDR_W'd20) //write
`define TDC_CTR_FREQ (`ADPLL_ADDR_W'd21) //write
`define DCO_OSC_GAIN (`ADPLL_ADDR_W'd22) //write

`define FCWW 26 // FCW word width
`define ACCW 27 // Phase Accumulator width
`define INTW 12 // FCW integer part word width
`define FRAW 14 // FCW fractional part word width

// FCW width it's the biggest register width that CPU can access
`define ADPLL_DATA_W `FCWW

//`define DEBUG_CAD //if enabled, debug flags can be visualized

