`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: d_ff_retimer.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: d_ff to be used as retimer (metastability due tsu violation)
//              			 
//

module d_ff_retimer (
	      input 	 d,
	      input 	 clk,
	      output reg q,
	      output reg q_bar);
   
   parameter delay = 50e3; //50 ps
   parameter tsu = 1e3; // 1 ps
   reg 			 d_last_event;
   
   

   initial q <= $urandom%2;

   always @ d
     d_last_event <= $time;
   
   
   always @(posedge clk) 
     begin
	if( ($time-d_last_event) < tsu)
	  #delay	q <= 1'bx;	// q <= $urandom%2; 
	else
	  #delay	q <= d;
     end 
endmodule 
