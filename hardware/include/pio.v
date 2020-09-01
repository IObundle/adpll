	         // serial input
		 input 			   data_mod, // data to be modulated

		 // analog dco interface
		 output 		   dco_pd,
		 output [1:0] 		   dco_osc_gain,
		 output [4:0] 		   dco_c_l_rall,
		 output [4:0] 		   dco_c_l_row,
		 output [4:0] 		   dco_c_l_col,
		 output [15:0] 		   dco_c_m_rall,
		 output [15:0] 		   dco_c_m_row,
		 output [15:0] 		   dco_c_m_col,
		 output [15:0] 		   dco_c_s_rall,
		 output [15:0] 		   dco_c_s_row,
		 output [15:0] 		   dco_c_s_col,
		 //analog tdc interface
		 output 		   tdc_pd,
		 output 		   tdc_pd_inj,
		 output [2:0] 		   tdc_ctr_freq,
		 input [6:0] 		   tdc_ripple_count,
		 input [15:0] 		   tdc_phase,
