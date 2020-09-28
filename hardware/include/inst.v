      // ADPLL CPU interface
      reg [`DATA_W-1:0] adpll_rdata_reg;
      reg adpll_ready_reg;
      always @(posedge clk, posedge reset) begin
         if (reset) begin
            adpll_rdata_reg <= {DATA_W{1'b0}};
            adpll_ready_reg <= 1'b0;
         end else begin
            adpll_rdata_reg <= {{(DATA_W-2){1'b0}}, adpll_rdata};
            adpll_ready_reg <= adpll_ready;
         end
      end

      assign adpll_valid = slaves_req[`valid(`ADPLL)];
      assign adpll_address = slaves_req[`address(`ADPLL,`ADPLL_ADDR_W+2)-2];
      assign adpll_wdata = slaves_req[`wdata(`ADPLL)-(`DATA_W-`ADPLL_DATA_W)];
      assign adpll_wstrb = |slaves_req[`wstrb(`ADPLL)];
      assign slaves_resp[`rdata(`ADPLL)] = adpll_rdata_reg;
      assign slaves_resp[`ready(`ADPLL)] = adpll_ready_reg;

