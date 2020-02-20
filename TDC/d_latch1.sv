`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: d_latch1.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: latch for the TDC model (no-reset)
//              negative enable			 
//

module d_latch1 (
	      input 	 d,
	      input 	 en_bar,
	      output reg q);

   parameter delay = 30e3; //50 ps
   initial q<=0;
   
   always @(~en_bar) 
     begin
	#delay	q <= d;
     end 
endmodule 
