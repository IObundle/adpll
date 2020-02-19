`timescale 1fs / 1fs

//`define ADPLL_MODE 2 //PD = 0, TEST = 1, RX = 2, TX = 3
//`define FREQ_CHANNEL 2480.000 // Channel freq in MHz
//`define SIM_TIME 120 //simulation time in us

///////////////////////////////////////////////////////////////////////////////
// Date: 17/02/2019
// Module: adpll_ctr_rx.sv
// Project: WSN 
// Description: Channel locking and then, signal modulation
//				 


module adpll_ctr_tb;

   reg clk;
   reg rst,en;
   reg data_mod;
   reg [25:0] FCW; // word in MHz
   reg [4:0]	      time_count;

   //cpu reg
   reg 		      sel, write;
   reg [4:0] 	      address;
   reg [31:0] 	      data_in;
   wire 	      ready;
   

   wire        dco_pd;
   wire [1:0]  dco_osc_gain;
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
   wire [31:0] osc_period_fs;
   
 
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
   integer 	  time_last;

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
   always @ (negedge clk) $fwrite(fp4, "%0d ", adpll0.dco_c_s_word);


   wire [6:0] tdc_ripple_count;
   wire [15:0] tdc_phase;

   wire        tdc_pd;
   wire        tdc_pd_inj;
   wire [2:0]  tdc_ctr_freq;  
   
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

   //instantiate adpll control
   reg [1:0]  adpll_mode;
   wire       channel_lock;
   adpll_ctr adpll0(
		    ///// Inputs
		    //general
		    .rst(rst),
		    .en(en),
		    .clk(clk),
		    .FCW(FCW),
		    .adpll_mode(adpll_mode),
		    .data_mod(data_mod),
		    //tdc_interface
		    .tdc_ripple_count(tdc_ripple_count),
		    .tdc_phase(tdc_phase),
		    ////// Outputs
		    //general
		    .channel_lock(channel_lock),
		    // dco interface
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
		    //tdc interface
		    .tdc_pd(tdc_pd),
		    .tdc_pd_inj(tdc_pd_inj),
		    .tdc_ctr_freq(tdc_ctr_freq),
		    //CPU interface
		    .sel(sel),
		    .ready(ready),
		    .write(write),
		    .address(address),
		    .data_in(data_in)
		    );
   
						  
/////////////////////////////// Input Parameters //////////////////////////						  
   parameter real end_time_fs = `SIM_TIME * 1E9;
   parameter real freq_channel = `FREQ_CHANNEL; //in MHz
   // ADPLL operation modes:
   parameter  PD = 2'd0, TEST = 2'd1, RX = 2'd2, TX = 2'd3;
//////////////////////////////////////////////////////////////////////////
   
   //32 MHz clock
   always #15625000 clk = ~clk; 
   
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;

      write = 0;
      sel = 0;
      address = 5'd0;
      data_in = 32'd0;
      
      clk = 0;
      rst = 0;
      en = 0;
      adpll_mode = `ADPLL_MODE; 
      data_mod = 0;
      FCW = int'(freq_channel*16384); // channel frequency
      $display("freq_channel = %f MHz, FCW = %d", freq_channel, FCW);
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

   initial #end_time_fs $finish;

      
   always #(end_time_fs /10) $write("Loading progress: %d percent \n", 
				    int'(100 * $time  / end_time_fs));
endmodule
