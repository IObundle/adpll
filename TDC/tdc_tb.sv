`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: tdc_tb.sv
// Project: WSN
// Description: testbench of the tdc analog and digital parts
//				 
//
  
module tdc_tb;

   reg 	       en,rst;
   reg 	       pd, pd_inj;
   reg [31:0]  osc_period_fs;
   reg 	       clk;
   

   wire [6:0]  ripple_count;
   wire [15:0] phase;
   wire [11:0] tdc_word;
   wire [2:0]  ctr_freq;
   
   //instantiate tdc_analog
   tdc_analog tdc_analog0(
		      //Inputs
			  .osc_period_fs(osc_period_fs),
			  .pd(pd),
			  .pd_inj(pd_inj),
			  .clk(clk),
			  .ctr_freq(ctr_freq),
			  //Outputs
			  .ripple_count(ripple_count),
			  .phase(phase));

    tdc_digital tdc_digital0(
		      //Inputs
			  .clk(clk),
			  .rst(rst),
			  .en(en),
			  .counter_in(ripple_count),
			  .phase_in(phase),
			  //Outputs
			  .tdc_word(tdc_word));


   initial $monitor("tdc_word = %d", tdc_word);
   
   
    always #(31250e3/2) clk = ~clk;  //32 MHz clk
   
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      rst = 1'b0;
      clk = 1'b0;
      en = 1'b0;
      pd = 1'b1;
      pd_inj = 1'b1;
      
      osc_period_fs = 32'd420000; //2.5 GHz
      #5e8 rst = 1'b1;
      #8e8 rst = 1'b0; 
      #1e9 en = 1'b1;
      pd = 1'b0;
      #1e9 pd_inj = 1'b0;
      
      #1e9 osc_period_fs = 32'd400023; //2 GHz
      /*
      #1e9 osc_period_fs = 32'd400004; //2 GHz
      #1e9 osc_period_fs = 32'd400030; //2 GHz
      #1e9 osc_period_fs = 32'd400000; //2 GHz
      #1e9 osc_period_fs = 32'd400016; //2 GHz
       */
   end

   initial #6e9 $finish;
endmodule
