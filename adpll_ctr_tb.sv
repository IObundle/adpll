`timescale 1fs / 1fs


///////////////////////////////////////////////////////////////////////////////
// Date: 19/01/2019
// Module: adpll_ctr_tb.sv
// Project: WSN 
// Description: 
//				 


module adpll_ctr_tb;

   reg clk;
   reg rst,en;
   
   reg [25:0] FCW; // word in MHz


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
   initial fp1 = $fopen("dco_ckv_time.txt","w");
   always @ (dco0.smp) $fwrite(fp1, "%0d ", $time);

   integer	  fp2;  
   initial fp2 = $fopen("tdc_word.txt","w");
   always @ (negedge clk) $fwrite(fp2, "%0d ", adpll0.tdc_word);


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

   //initial $monitor("tdc_word = %d and osc_period_fs = %d, freq_dco = %d, ph_diff_accum_int = %d, ph_diff_accum= %d, dco_c_s_word = %d, word = %d", adpll0.tdc_word, osc_period_fs, 
   //		    dco0.freq_dco, adpll0.ph_diff_accum, adpll0.ph_diff_int,adpll0.dco_c_s_word, adpll0.row_col_cod_s.word);

   //instantiate adpll control
   reg [1:0]  adpll_mode;
   adpll_ctr adpll0(
				 //Inputs
				 .rst(rst),
				 .en(en),
				 .clk(clk),
				 .FCW(FCW),
				 .adpll_mode(adpll_mode),
				 .tdc_ripple_count(tdc_ripple_count),
				 .tdc_phase(tdc_phase),
				 //Outputs
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
				 .tdc_ctr_freq(tdc_ctr_freq)
				 );
   
						  
						  
   parameter real end_time_fs = 100E9;
   parameter real Fout = 2483.33; //in MHz
   
   always #(end_time_fs /10) $write("Loading progress: %d percent \n", 
				    int'(100 * $time  / end_time_fs));
   
   always #15625000 clk = ~clk; //32 MHz clock
   
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      //FCW = {7'd76,19'd0}; 	
      //FCW = {12'd2400,14'h00}; //aprox 2448MHz 				  
      clk = 0;
      rst = 0;
      en = 0;
      adpll_mode = 0;
      FCW = int'(Fout*16384);
      $display("Fin = %f MHz, FCW = %d", Fout, FCW);

      #1E8 rst = 1;
      #1E8 rst = 0;
      #1E8 en = 1;
      #1E8 adpll_mode = 2;
      
      //#2E8 FCW = {12'd2450,14'h0000}; //aprox 2448MHz 	

      


   end 


   initial  #end_time_fs  begin
      $finish;
   end
endmodule
