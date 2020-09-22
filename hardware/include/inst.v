      // ADPLL CPU interface
      assign adpll_valid = slaves_req[`valid(`ADPLL)];
      assign adpll_address = slaves_req[`address(`ADPLL,`ADPLL_ADDR_W+2)-2];
      assign adpll_wdata = slaves_req[`wdata(`ADPLL)-(`DATA_W-`ADPLL_DATA_W)];
      assign adpll_wstrb = |slaves_req[`wstrb(`ADPLL)];
      assign slaves_resp[`rdata(`ADPLL)] = {{(DATA_W-2){1'b0}}, adpll_rdata};
      assign slaves_resp[`ready(`ADPLL)] = adpll_ready;
