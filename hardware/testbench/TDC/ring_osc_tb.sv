`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 04/02/2020
// Module: ring_osc_tb.v
// Project: WSN
// Description: testbench of the ring oscillator with variable input period
//				 
//
  
module ring_osc_tb;

   reg 	       en;
   reg [31:0]        osc_period_fs;
   

   
   //instantiate ring oscillator
   wire [31:0] osc_phases;
   ring_osc ring_osc0(
		      //Inputs
		      .osc_period_fs(osc_period_fs),
		      .en(en),
		      //Outputs
		      .inv_out(osc_phases));
   


   


   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      en = 1'b0;
      osc_period_fs = 32'd400003; //2.5 GHz
      
      #1e9 en = 1'b1;
      #1e9 osc_period_fs = 32'd4000003; //2 GHz
      #1e9 osc_period_fs = 32'd4000004; //2 GHz
      #1e9 osc_period_fs = 32'd4000030; //2 GHz
      #1e9 osc_period_fs = 32'd4000000; //2 GHz
      #1e9 osc_period_fs = 32'd4000016; //2 GHz

   end

   initial #1000e9 $finish;

endmodule
