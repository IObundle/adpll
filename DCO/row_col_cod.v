`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 24/01/2019
// Module: row_col_cod.sv
// Project: WSN DCO Model 
// Description:  Number of row/col must be a power of 2. Codes binary into
//               col/row selector
//				 
// Change history: 12/12/19 - 
module row_col_cod #(
		     parameter WORD_W = 8,
		     parameter ROW_W = 4 //2^ number of rows = 2^ number of col
		     )
   (
    input 		  rst,
    input 		  en,
    input 		  clk,
    input [WORD_W-1:0] 	  word,
    output reg [SIZE-1:0] r_all, 
    output reg [SIZE-1:0] row,
    output reg [SIZE-1:0] col);

    parameter SIZE = (1<<ROW_W); // number of rows = number of cols
   integer 		  i;
   
   reg [SIZE-1:0] 	  r_all_nxt, row_nxt, col_nxt;
   reg [WORD_W-ROW_W-1:0] 	  r_all_bin, col_bin;
   

   always @ word begin
      r_all_nxt = r_all;
      row_nxt = row;
      col_nxt = col;


      r_all_bin = word>>ROW_W; // number of r_all to be active
      //binary to therm convertion
      for(i = 0; i < SIZE ; i=i+1)begin
	 if( i < r_all_bin)
	   r_all_nxt[i] = 1'b1;
	 else
	   r_all_nxt[i] = 1'b0;
	 if(i == r_all_bin)
	   row_nxt[i] = 1'b1;
	 else
	   row_nxt[i] = 1'b0;
      end

      col_bin = (word<<ROW_W)>>ROW_W; //number of col to be active
      if(r_all_bin[0] == 0)
	for(i=0; i < SIZE; i = i+1)
	  if(i < col_bin)
	    col_nxt[i] = 1'b1;
	  else
	    col_nxt[i] = 1'b0;
      else
	for(i=(SIZE-1); i >= 0 ; i = i-1)
	  if(i >= (SIZE-col_bin))
	    col_nxt[i] = 1'b1;
	  else
	    col_nxt[i] = 1'b0;
      //$display(" r_all_nxt = %b ", r_all_nxt);
      //$display(" row_nxt = %b ", row_nxt);
      //$display(" col_nxt = %b ", col_nxt);
      
      
      
   end
   

   always @ (posedge rst, posedge clk) begin 
      if(rst == 1'b1)begin
	 r_all <= 0;
	 row <= 0;
	 col <= 0;
      end
      else if(en == 1'b1)begin
	 r_all <= r_all_nxt;
	 row <= row_nxt;
	 col <= col_nxt;

      end
   end 

endmodule // c_sel
