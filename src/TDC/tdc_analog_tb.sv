`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: tdc_analog_tb.sv
// Project: WSN
// Description: testbench of the tdc analog part
//				 
//
  
module tdc_analog_tb;

   reg 	       pd,pd_inj;
   reg [31:0]  osc_period_fs;
   reg 	       clk;
   

   wire [6:0]  ripple_count;
   wire [15:0] phases;
   //instantiate tdc_analog
   tdc_analog tdc_analog0(
		      //Inputs
			  .osc_period_fs(osc_period_fs),
			  .pd(pd),
			  .pd_inj(pd_inj),
			  .clk(clk),
			  //Outputs
			  .ripple_count(ripple_count),
			  .phase(phases));

    always #31250e3 clk = ~clk;  //32 MHz clk
   
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      clk = 1'b0;
      pd = 1'b1;
      pd_inj = 1'b1;
      osc_period_fs = 32'd4200003; //2.5 GHz
      
      #1e9 pd = 1'b0;
      #1e9 pd_inj = 1'b0;
      
      #1e9 osc_period_fs = 32'd4000003; //2 GHz
      #1e9 osc_period_fs = 32'd4000004; //2 GHz
      #1e9 osc_period_fs = 32'd4000030; //2 GHz
      #1e9 osc_period_fs = 32'd4000000; //2 GHz
      #1e9 osc_period_fs = 32'd4000016; //2 GHz

   end

   initial #6e9 $finish;
endmodule
