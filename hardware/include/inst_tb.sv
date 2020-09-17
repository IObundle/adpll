
   wire channel_lock = uut.adpll_ctr0.adpll_ctr0.channel_lock;
   wire [11:0] tdc_word = uut.adpll_ctr0.adpll_ctr0.tdc_word;
   wire en = uut.adpll_ctr0.en;
   adpll_tb adpll_tb0
     (
      .clk (clk),

      // Analog DCO interface
      .data_mod(data_mod),
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

      // Analog TDC interface
      .tdc_pd(tdc_pd),
      .tdc_pd_inj(tdc_pd_inj),
      .tdc_ctr_freq(tdc_ctr_freq),
      .tdc_ripple_count(tdc_ripple_count),
      .tdc_phase(tdc_phase),

      // Simulation
      .channel_lock(channel_lock),
      .tdc_word(tdc_word),
      .en(en)
      );

