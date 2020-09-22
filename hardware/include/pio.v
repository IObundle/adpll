         // ADPLL CPU interface
         output                     adpll_valid,
         output [`ADPLL_ADDR_W-1:0] adpll_address,
         output [`ADPLL_DATA_W-1:0] adpll_wdata,
         output                     adpll_wstrb,
         input [1:0]                adpll_rdata,
         input                      adpll_ready,
