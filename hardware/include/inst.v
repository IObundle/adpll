   adpll_ctr

   adpll_ctr0
     
     (

    // serial 
      .data_mod(data_mod), // data to be modulated

      // analog dco interface
      .dco_pd(dco_pd),
      .dco_osc_gain(dco_osc_gain),
      .dco_c_l_rall(dco_c_l_rall),
      .dco_c_l_row(dco_c_l_row),
      .dco_c_l_col(dco_c_l_col),
      .dco_c_m_rall(dco_c_m_rall),
      .dco_c_m_row(dco_c_m_row),
      .dco_c_m_col(dco_c_m_col),
      .dco_c_s_rall(dco_c_s_rall),
      .dco_c_s_row(dco_c_s_row),
      .dco_c_s_col(dco_c_s_col),
      //analog tdc interface
      .tdc_pd(tdc_pd),
      .tdc_pd_inj(tdc_pd_inj),
      .tdc_ctr_freq(tdc_ctr_freq),
      .tdc_ripple_count(tdc_ripple_count),
      .tdc_phase(tdc_phase),

      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`ADPLL)]),
      .address(slaves_req[`address(`ADPLL,`ADPLL_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`ADPLL)-(`DATA_W-32)]),
      .wstrb(|slaves_req[`wstrb(`ADPLL)]),
      .rdata(slaves_resp[`rdata(`ADPLL)]),
      .ready(slaves_resp[`ready(`ADPLL)])
      );
