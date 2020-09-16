`timescale 1fs / 1fs

`include "adpll_defines.vh"		 

// Description: 
// 

module adpll_tb
  (
   input         clk,

   // Serial input
   output reg    data_mod, // data to be modulated

   // Analog DCO interface
   input         dco_pd,
   input [1:0]   dco_osc_gain,
   input [4:0]   dco_c_l_rall,
   input [4:0]   dco_c_l_row,
   input [4:0]   dco_c_l_col,
   input [15:0]  dco_c_m_rall,
   input [15:0]  dco_c_m_row,
   input [15:0]  dco_c_m_col,
   input [15:0]  dco_c_s_rall,
   input [15:0]  dco_c_s_row,
   input [15:0]  dco_c_s_col,

   // Analog TDC interface
   input         tdc_pd,
   input         tdc_pd_inj,
   input [2:0]   tdc_ctr_freq,
   output [6:0]  tdc_ripple_count,
   output [15:0] tdc_phase,

   // Simulation
   input         channel_lock,
   input [11:0]  tdc_word
   );

   reg [4:0]     time_count;

   wire          ckv;
   real          osc_period_fs;

   // Instantiate DCO module
   dco dco0
     (
	  // Inputs
	  .pd (dco_pd),
	  .osc_gain(dco_osc_gain),
	  .c_l_rall(dco_c_l_rall),
	  .c_l_row(dco_c_l_row),
	  .c_l_col(dco_c_l_col),
	  .c_m_rall(dco_c_m_rall),
	  .c_m_row(dco_c_m_row),
	  .c_m_col(dco_c_m_col),
	  .c_s_rall(dco_c_s_rall),
	  .c_s_row(dco_c_s_row),
	  .c_s_col(dco_c_s_col),

	  // Outputs
	  .ckv (ckv),
	  .period_fs(osc_period_fs)
	  );

   integer       fp1;
   initial fp1 = $fopen("dco_ckv_time.txt","w");
   always @ (posedge dco0.ckv) $fwrite(fp1, "%0d ", $time);

   integer       fp2;  
   initial fp2 = $fopen("tdc_word.txt","w");
   always @ (negedge clk) $fwrite(fp2, "%0d ", tdc_word);

   integer       fp3;  
   initial fp3 = $fopen("clkn_time.txt","w");
   always @ (negedge clk) $fwrite(fp3, "%0d ", $time);

   integer       fp4;  
   initial fp4 = $fopen("dco_s_word.txt","w");
   always @ (negedge clk) $fwrite(fp4, "%0d ", (dco0.c_s_val_sum == "x")? "x": dco0.c_s_val_sum);

   // Instantiate TDC module
   tdc_analog tdc_analog0
     (
	  // Inputs
	  .osc_period_fs(osc_period_fs),
	  .pd(tdc_pd),
	  .pd_inj(tdc_pd_inj),
	  .clk(clk),
	  .ctr_freq(tdc_ctr_freq),

      // Outputs
	  .ripple_count(tdc_ripple_count),
	  .phase(tdc_phase)
      );

/////////////////////////////// Input Parameters //////////////////////////
   parameter real end_time_fs = `SIM_TIME * 1E9;
   parameter real freq_channel = `FREQ_CHANNEL; // in MHz
   parameter adpll_mode =`ADPLL_OPERATION;
   // ADPLL operation modes:
   parameter PD = 2'd0, TEST = 2'd1, RX = 2'd2, TX = 2'd3;
//////////////////////////////////////////////////////////////////////////

   initial begin
      data_mod = 0;
      time_count = 0;
   end

   always @(posedge clk)
     if(channel_lock && adpll_mode == TX) begin
	    time_count <= time_count + 1;
	    if(time_count == 5'd31)
	      data_mod <= $urandom%2;
     end

   //always #(end_time_fs /10) $write("Loading progress: %d percent \n",
   //                                 int'(100 * $time  / end_time_fs));

endmodule
