`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 23/01/2019
// Module: c_sel.sv
// Project: WSN DCO Model (Non-Synt)
// Description: logic to select the bank capacitance
//				 
// Change history: 12/12/19 - 

module c_sel (
              input 	 r_all, 
	      input 	 row,
	      input 	 col,
	      output  out);
   
   assign out =(col~&row)~&r_all;
   

endmodule // c_sel
