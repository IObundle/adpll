`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: d_ff1.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: d_ff to be used in the TDC model (no-reset)
//              			 
//

module d_ff1 (
	      input 	 d,
	      input 	 clk,
	      output reg q,
	      output reg q_bar);
   
   parameter delay = 50e3; //50 ps
   initial q_bar <= 1;
   initial q <= 0;
   
   always @(posedge clk) 
     begin
		q <= d;
	#delay q_bar <= ~d;
     end 
endmodule 
