`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 04/02/2020
// Module: ring_inv.sv
// Project: WSN DCO Model (Non-Synt)
// Description: inverter logic with variable delay
//				 
// Change history: 12/12/19 - 

module ring_inv (
              input [31:0] delay_fs, 
	      input 	 in,
	      output  out);
   
   assign #delay_fs out =~in;
   

endmodule 
