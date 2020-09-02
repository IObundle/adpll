`timescale 1fs / 1fs
`include "adpll_defines.vh"

///////////////////////////////////////////////////////////////////////////////
// Module: adpll_ctr.v
// Project: WSN DCO Model 
// Description:  adpll0 with CPU interface
//               
//				 

module adpll_ctr(
		 input 			   rst,
		 input 			   clk,
		 //CPU interface
		 input 			   valid,
		 input [`ADPLL_ADDR_W-1:0] address,
		 input [31:0] 		   wdata,
		 input 			   wstrb,
		 output [31:0] 		   rdata,
		 output reg 		   ready,
		 
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
		 input [15:0] 		   tdc_phase
  			      
		 );

   wire signed [4:0]  dco_c_l_word;
   wire signed [7:0]  dco_c_m_word;
   wire signed [7:0]  dco_c_s_word;
   wire [11:0] 	      tdc_word;
   
   

   // cpu interface ready signal
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else 
       ready <= valid;
   
   ///////////////////////////////////////////////////////////////////
   /// List of accesible registers 
   ///////////////////////////////////////////////////////////////////

   reg 		      rst_soft;
   reg [`FCWW-1:0]    FCW;  
   reg [1:0] 	      adpll_mode;
   reg 		      en;
   reg [3:0] 	      alpha_l;
   reg [3:0] 	      alpha_m;
   reg [3:0] 	      alpha_s_rx;
   reg [3:0] 	      alpha_s_tx;
   reg [3:0] 	      beta;
   reg [2:0] 	      lambda_rx;
   reg [2:0] 	      lambda_tx;
   reg [1:0] 	      iir_n_rx;
   reg [1:0] 	      iir_n_tx;
   reg [4:0] 	      FCW_mod;
   reg signed [4:0]   dco_c_l_word_test;
   reg signed [7:0]   dco_c_m_word_test;
   reg signed [7:0]   dco_c_s_word_test;
   reg 		      dco_pd_test;
   reg 		      tdc_pd_test;
   reg 		      tdc_pd_inj_test;
   reg [2:0] 	      tdc_ctr_freq;
   reg [1:0] 	      dco_osc_gain;

   // soft reset pulse
   wire 	      rst_int;
   assign rst_int = rst | rst_soft;
   ///////////////////////////////////////////////////////////////////
   /// CPU Adress decoder 
   ///////////////////////////////////////////////////////////////////
   
   wire 	      channel_lock;
   wire               channel_sat; 	      
   
   // Read
   //always @*
    //address == `ADPLL_LOCK
   assign  rdata = (address == `ADPLL_LOCK) ? 
			{{31{1'b0}}, channel_lock} : ((address == `ADPLL_SAT) ? {{31{1'b0}}, channel_sat} : {{32{1'b1}});

   // Write  
   always @ (posedge clk, posedge rst)
     if(rst_int) begin
	rst_soft <= 1'b0;
	FCW <= `FCWW'h2620000; //2440 MHz
	adpll_mode <= 2'b0;
	en <= 1'b0;
	alpha_l <= 4'd14;
	alpha_m <= 4'd8;
	alpha_s_rx <= 4'd7;
	alpha_s_tx <= 4'd4;
	beta <= 4'd0;
	lambda_rx <= 3'd2;
	lambda_tx <= 3'd2;
	iir_n_rx <= 2'd3;
	iir_n_tx <= 2'd2;
	FCW_mod <= 5'b01001;//298kHz
	dco_c_l_word_test <= 5'sd0;
	dco_c_m_word_test <= 8'sd0;
	dco_c_s_word_test <= 8'sd0;
	dco_pd_test <= 1'b1;
	tdc_pd_test <= 1'b1;
	tdc_pd_inj_test <= 1'b1;
	tdc_ctr_freq <= 3'b100;
	dco_osc_gain <= 2'b10;
     end else if(valid && wstrb)	
       case (address)
	  `ADPLL_SOFT_RST: rst_soft <= wdata[0];
	  `FCW: FCW <= wdata[`FCWW-1:0];
	  `ADPLL_MODE: adpll_mode <= wdata[1:0];
	  `ADPLL_EN: en <= wdata[0];
	  `ALPHA_L: alpha_l <= wdata[3:0];
          `ALPHA_M: alpha_m <= wdata[3:0];
          `ALPHA_S_RX: alpha_s_rx <= wdata[3:0];
          `ALPHA_S_TX: alpha_s_tx <= wdata[3:0];
	  `BETA: beta <= wdata[3:0];
          `LAMBDA_RX: lambda_rx <= wdata[2:0];
          `LAMBDA_TX: lambda_tx <= wdata[2:0];
          `IIR_N_RX: iir_n_rx <= wdata[1:0];
	  `IIR_N_TX: iir_n_tx <= wdata[1:0];
          `FCW_MOD: FCW_mod <= wdata[4:0];
          `DCO_C_L_WORD_TEST: dco_c_l_word_test <= wdata[4:0];
          `DCO_C_M_WORD_TEST: dco_c_m_word_test <= wdata[7:0];
	  `DCO_C_S_WORD_TEST: dco_c_s_word_test <= wdata[7:0];
          `DCO_PD_TEST: dco_pd_test = wdata[0];
          `TDC_PD_TEST: tdc_pd_test = wdata[0];
          `TDC_PD_INJ_TEST: tdc_pd_inj_test = wdata[0];
	  `TDC_CTR_FREQ: tdc_ctr_freq = wdata[2:0];
          `DCO_OSC_GAIN: dco_osc_gain = wdata[1:0];
          default:;
       endcase

   // instantiate the adpll control module
   adpll_ctr0 adpll_ctr0(/*AUTOINST*/
			 // Outputs
			 .channel_lock	(channel_lock),
			 .channel_sat          (channel_sat),
			 .dco_pd		(dco_pd),
			 .dco_c_l_rall	(dco_c_l_rall[4:0]),
			 .dco_c_l_row		(dco_c_l_row[4:0]),
			 .dco_c_l_col		(dco_c_l_col[4:0]),
			 .dco_c_m_rall	(dco_c_m_rall[15:0]),
			 .dco_c_m_row		(dco_c_m_row[15:0]),
			 .dco_c_m_col		(dco_c_m_col[15:0]),
			 .dco_c_s_rall	(dco_c_s_rall[15:0]),
			 .dco_c_s_row		(dco_c_s_row[15:0]),
			 .dco_c_s_col		(dco_c_s_col[15:0]),
			 .tdc_pd		(tdc_pd),
			 .tdc_pd_inj		(tdc_pd_inj),
			 // Inputs
			 .rst			(rst),
			 .en			(en),
			 .clk			(clk),
			 .FCW			(FCW[`FCWW-1:0]),
			 .adpll_mode		(adpll_mode[1:0]),
			 .data_mod		(data_mod),
			 .tdc_ripple_count	(tdc_ripple_count[6:0]),
			 .tdc_phase		(tdc_phase[15:0]),
			 .alpha_l		(alpha_l[3:0]),
			 .alpha_m		(alpha_m[3:0]),
			 .alpha_s_rx		(alpha_s_rx[3:0]),
			 .alpha_s_tx		(alpha_s_tx[3:0]),
			 .beta			(beta[3:0]),
			 .lambda_rx		(lambda_rx[2:0]),
			 .lambda_tx		(lambda_tx[2:0]),
			 .iir_n_rx		(iir_n_rx[1:0]),
			 .iir_n_tx		(iir_n_tx[1:0]),
			 .FCW_mod		(FCW_mod[4:0]),
			 .dco_c_l_word_test	(dco_c_l_word_test[4:0]),
			 .dco_c_m_word_test	(dco_c_m_word_test[7:0]),
			 .dco_c_s_word_test	(dco_c_s_word_test[7:0]),
			 .dco_pd_test		(dco_pd_test),
			 .tdc_pd_test		(tdc_pd_test),
			 .tdc_pd_inj_test	(tdc_pd_inj_test));
   

endmodule 

   
   
   


   
	
   
