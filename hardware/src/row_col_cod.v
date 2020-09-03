`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 24/01/2019
// Module: row_col_cod.sv
// Project: WSN DCO Model 
// Description:  Number of row/col must be a power of 2. Codes binary into
//               col/row selector
//				 
// Change history: 4/2/2021 - rall is now zero active
module row_col_cod #(
		     parameter WORD_W = 8,
		     parameter ROW_W = 4, //2^ number of rows = 2^ number of col
			 parameter SIZE = (1<<ROW_W)
		     )
   (
    input 		  rst,
    input 		  en,
    input 		  clk,
    input [WORD_W-1:0] 	  word,
    output reg [SIZE-1:0] r_all_nxt, 
    output reg [SIZE-1:0] row_nxt,
    output reg [SIZE-1:0] col_nxt);

    //parameter SIZE = (1<<ROW_W); // number of rows = number of cols
   integer 		  i;
   
   reg [WORD_W-ROW_W-1:0] 	  r_all_bin, col_bin;
   

   always @ word begin
      r_all_nxt[SIZE-1] = 1'b1;
      //row_nxt = row;
      //col_nxt = col;


      r_all_bin = word>>ROW_W; // number of r_all to be active
      //binary to therm convertion
      for(i = 0; i < SIZE ; i=i+1)begin
	 if( i < r_all_bin)
	   r_all_nxt[i] = 1'b0;
	 else
	   r_all_nxt[i] = 1'b1;
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
   


endmodule 
