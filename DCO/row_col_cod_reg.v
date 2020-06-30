`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 30/06/2020
// Module: row_col_cod_reg.v
// Project: WSN DCO Model 
// Description:  input sync with clk
//				 
// 
module row_col_cod_reg #(
		     parameter WORD_W = 8,
		     parameter ROW_W = 4, //2^ number of rows = 2^ number of col
			 parameter SIZE = (1<<ROW_W)
		     )
   (
    input 		  rst,
    input 		  en,
    input 		  clk,
	input [SIZE-1:0] r_all_nxt, 
    input [SIZE-1:0] row_nxt,
    input [SIZE-1:0] col_nxt,
    output reg [SIZE-1:0] r_all, 
    output reg [SIZE-1:0] row,
    output reg [SIZE-1:0] col);

   

   always @ (negedge clk, posedge rst) begin 
      if(rst)begin
	 //reset for 16x16 c bank with half on and half off
	 //r_all <= 16'd255;
	 r_all <= 16'd65280;
	 row <= 16'd256;
	 col <= 16'd0;
      end
      else if(en)begin
	 r_all <= r_all_nxt;
	 row <= row_nxt;
	 col <= col_nxt;

      end
   end 

endmodule
