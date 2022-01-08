`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: counter_tb.sv
// Project: WSN
// Description: testbench of ripple counter
//				 
//
  
module counter_tb;

   reg 	       ckv,clk;
   wire [6:0]        ripple_count;
   
   wire 	     clk_ret;
   
   
   //instantiate counter
   counter counter0(
		      //Inputs
		      .data(ckv),
		      .clk(clk_ret),
		      //Outputs
		      .count(ripple_count));

   d_ff2 d_ff2_ret (
			   .d(clk),
			   .clk(~ckv),
			   .q(clk_ret)
			   );     
   always #200e3 ckv = ~ckv;
   always #(31250e3/2) clk = ~clk;  //32 MHz clk

   //$monitor("ripple_count[6:0] = %d" ,ripple_count[0]);
   

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      clk = 0;
      ckv = 0;
      
 

   end

   initial #1e9 $finish;

endmodule
