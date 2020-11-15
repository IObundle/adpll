`timescale 1fs / 1fs

`include "adpll_defines.vh"

module adpll_ctr_tb;
   // ADPLL CPU interface
   reg                     adpll_valid;
   reg [`ADPLL_ADDR_W-1:0] adpll_address;
   reg [`ADPLL_DATA_W-1:0] adpll_wdata;
   reg                     adpll_wstrb;
   wire [1:0]               adpll_rdata;
   wire                     adpll_ready;
   
   reg 						adpll_data_mod;
   reg [1:0]                rcv_adpll_word;
   reg 			    clk;
   reg 			    rst;
`include "adpll_tasks.v"

   parameter real end_time_fs = `SIM_TIME * 1E9;
   reg [4:0]	      time_count;
   reg [`FCWW-1:0]    adpll_fcw;  // word in MHz
   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   //32 MHz clock
   always #15625000 clk = ~clk;   
   
   // TX data generation
   always @(posedge clk)
      if(channel_lock  && `ADPLL_OPERATION == `TX) begin
	     time_count <= time_count + 1;
	     if(time_count == 5'd31)
	        adpll_data_mod <= $urandom%2;
     end
	 
    initial #end_time_fs begin 		
		$finish;
	end
      
    always #(end_time_fs /10) $write("Loading progress: %d percent \n", 
				    int'(100 * $time  / end_time_fs));
   
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
	  adpll_fcw = int'(`FREQ_CHANNEL*16384);
	  $display("freq_channel = %f MHz, adpll_mode = %1d", `FREQ_CHANNEL , `ADPLL_OPERATION);
	  
	  // tx data counter
	  time_count = 0; 
	  
      // init ADPLL cpu bus signals
      adpll_valid = 0;
      adpll_wstrb = 0;
      rst = 1;
      clk = 0;
	  adpll_data_mod = 0;

      // deassert rst
      repeat (100) @(posedge clk);
      rst <= 0;

      //wait an arbitray (10) number of cycles
      repeat (10) @(posedge clk) #1;
      

      // configure ADPLL
      //adpll_config(adpll_fcw,`ADPLL_OPERATION);
	  adpll_write(`FCW, adpll_fcw);
      adpll_write(`ADPLL_MODE, `ADPLL_OPERATION);

      // enable ADPLL
      adpll_write(`ADPLL_EN, 1);

      // check if ADPLL is lock
      //do begin
      //  adpll_read(`ADPLL_LOCK,rcv_adpll_word);
      //end while(rcv_adpll_word != 1);
      

   end

   //
   // INSTANTIATE COMPONENTS
   //

   // Serial input
   //wire                     data_mod = tx;

   // Analog DCO interface
   wire                     dco_pd;
   wire [1:0]               dco_osc_gain;
   wire [4:0]               dco_c_l_rall;
   wire [4:0]               dco_c_l_row;
   wire [4:0]               dco_c_l_col;
   wire [15:0]              dco_c_m_rall;
   wire [15:0]              dco_c_m_row;
   wire [15:0]              dco_c_m_col;
   wire [15:0]              dco_c_s_rall;
   wire [15:0]              dco_c_s_row;
   wire [15:0]              dco_c_s_col;
   wire                     dco_ckv;

   // Analog TDC interface
   wire                     tdc_pd;
   wire                     tdc_pd_inj;
   wire [2:0]               tdc_ctr_freq;
   wire [6:0]               tdc_ripple_count;
   wire [15:0]              tdc_phase;
   adpll_ctr adpll_ctr
     (
      // Serial
      .data_mod(adpll_data_mod),

      // Analog DCO interface
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

      // CPU interface
      .clk       (clk),
      .rst       (rst),
      .valid     (adpll_valid),
      .address   (adpll_address),
      .wdata     (adpll_wdata),
      .wstrb     (adpll_wstrb),
      .rdata     (adpll_rdata),
      .ready     (adpll_ready)
      );

   wire                     channel_lock = adpll_ctr.channel_lock;
   wire [11:0]              tdc_word = adpll_ctr.adpll_ctr0.tdc_word;
   wire                     en = adpll_ctr.en;
   adpll_tb #(
              .ID(0)
              )
   adpll_tb0
     (
      .clk (clk),

      // Analog DCO interface
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
      .dco_ckv(dco_ckv),

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

endmodule
