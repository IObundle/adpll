`timescale 1fs / 1fs

`include "adpll_defines.vh"

//`define ADPLL_OPERATION 2 //PD = 0, TEST = 1, RX = 2, TX = 3
//`define FREQ_CHANNEL 2480.000 // Channel freq in MHz
//`define SIM_TIME 120 //simulation time in us

///////////////////////////////////////////////////////////////////////////////
// Date: 17/02/2019
// Module: adpll_ctr_rx.sv
// Project: WSN 
// Description: Channel locking and then, signal modulation
//				 


module adpll_ctr0_tb;

   reg clk;
   reg rst;
   reg data_mod;
   reg [4:0]	      time_count;
   

   wire        dco_pd;
   wire [4:0]  dco_c_l_rall;
   wire [4:0]  dco_c_l_row;
   wire [4:0]  dco_c_l_col;  
   wire [15:0] dco_c_m_rall;     
   wire [15:0] dco_c_m_row;
   wire [15:0] dco_c_m_col;  
   wire [15:0] dco_c_s_rall;  
   wire [15:0] dco_c_s_row;   
   wire [15:0] dco_c_s_col;
   wire        ckv;
   real        osc_period_fs;

   wire       channel_lock;
   
   // ADPLL external registers
   reg 		      rst_soft;
   reg [`FCWW-1:0]    FCW;  // word in MHz
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
 
   // instantiate dco module
   dco dco0(
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

   
   integer	  fp1;
   initial fp1 = $fopen("dco_ckv_time.txt","w");
   always @ (posedge dco0.ckv) $fwrite(fp1, "%0d ", $time);

   integer	  fp2;  
   initial fp2 = $fopen("tdc_word.txt","w");
   always @ (negedge clk) $fwrite(fp2, "%0d ", adpll0.tdc_word);

   integer	  fp3;  
   initial fp3 = $fopen("clkn_time.txt","w");
   always @ (negedge clk) $fwrite(fp3, "%0d ", $time);

   integer	  fp4;  
   initial fp4 = $fopen("dco_s_word.txt","w");
   //always @ (negedge clk) $fwrite(fp4, "%0d ", adpll0.dco_c_s_word);   
   always @ (negedge clk) $fwrite(fp4, "%0d ", (dco0.c_s_val_sum == "x")? "x": dco0.c_s_val_sum );

   wire [6:0] tdc_ripple_count;
   wire [15:0] tdc_phase;

   wire        tdc_pd;
   wire        tdc_pd_inj; 
   
   //instantiate tdc_analog
   tdc_analog tdc_analog0(
		      //Inputs
			  .osc_period_fs(osc_period_fs),
			  .pd(tdc_pd),
			  .pd_inj(tdc_pd_inj),
			  .clk(clk),
			  .ctr_freq(tdc_ctr_freq),
			  //Outputs
			  .ripple_count(tdc_ripple_count),
			  .phase(tdc_phase));



   // instantiate the adpll control module
   adpll_ctr0 adpll0(/*AUTOINST*/
		     // Outputs
		     .channel_lock	(channel_lock),
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


   
						  
/////////////////////////////// Input Parameters //////////////////////////						  
   parameter real end_time_fs = `SIM_TIME * 1E9;
   parameter real freq_channel = `FREQ_CHANNEL; //in MHz
   // ADPLL operation modes:
   parameter  PD = 2'd0, TEST = 2'd1, RX = 2'd2, TX = 2'd3;
//////////////////////////////////////////////////////////////////////////
   
   //32 MHz clock
   always #15625000 clk = ~clk; 
   reg [1:0] 	  testt;
   
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;

      data_mod = 0;
      
      clk = 0;
      rst = 0;
      adpll_mode =`ADPLL_OPERATION; 
      FCW = int'(freq_channel*16384); // channel frequency
      $display("freq_channel = %f MHz, FCW = %d, adpll_mode = %1d",
	       freq_channel, FCW , `ADPLL_OPERATION);

      rst_soft = 1'b0;
      en = 1'b0;
      alpha_l = 4'd14;
      alpha_m = 4'd8;
      alpha_s_rx = 4'd7;
      alpha_s_tx = 4'd4;
      beta = 4'd0;
      lambda_rx = 3'd2;
      lambda_tx = 3'd2;
      iir_n_rx = 2'd3;
      iir_n_tx = 2'd2;
      FCW_mod = 5'b01001;//288kHz
      dco_c_l_word_test = 5'sd0;
      dco_c_m_word_test = 8'sd0;
      dco_c_s_word_test = 8'sd0;
      dco_pd_test = 1'b1;
      tdc_pd_test = 1'b1;
      tdc_pd_inj_test = 1'b1;
      tdc_ctr_freq = 3'b100;
      dco_osc_gain = 2'b10;



      
      time_count = 0;

      #1E8 rst = 1;
      #1E8 rst = 0;
      #1E8 en = 1;

      //#30E9 FCW = int'((2310)*16384); // channel frequency
      //$display("freq_channel = %f MHz, FCW = %d", 2310, FCW);
      //#10E9 adpll_mode = 1 ;
      //#10E9 adpll_mode = 3;
      
   end 

   always @(posedge clk)
     if(channel_lock  && adpll_mode == TX) begin
	time_count <= time_count + 1;
	if(time_count == 5'd31)
	  data_mod <= $urandom%2;
     end

   initial #end_time_fs begin 		
		$finish;
	end
      
   always #(end_time_fs /10) $write("Loading progress: %d percent \n", 
				    int'(100 * $time  / end_time_fs));
endmodule
