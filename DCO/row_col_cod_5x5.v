`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 24/01/2019
// Module: row_col_cod.sv
// Project: WSN DCO Model 
// Description:  Number of row/col must be 5x5
//               col/row selector
//				 
// Change history: 4/2/2021 - rall is now zero active
module row_col_cod_5x5 #(
		     parameter MAX = 25 // max input word value
		     )
   (
    input 		  rst,
    input 		  en,
    input 		  clk,
    input [4:0] 	  word,
    output reg [4:0] r_all, 
    output reg [4:0] row,
    output reg [4:0] col);

    parameter SIZE = 3'd5; // number of rows = number of cols
   integer 		  i;
   
   reg [4:0] 	  r_all_nxt, row_nxt, col_nxt;
   reg [2:0] 	  r_all_bin; 
   reg [2:0] 	  col_bin;
   

   always @ word begin
      r_all_nxt = r_all;
      row_nxt = row;
      col_nxt = col;

      if(word > MAX)
	 r_all_nxt = {SIZE{1'b1}};
      else begin
	 // number of r_all to be active
	 if(word <= 5'd5)begin
	   r_all_bin = 3'd0;
	   col_bin = word;
	 end
	 else
	   if(word <= 5'd10)begin
	      r_all_bin = 3'd1;
	      col_bin = word - 5'd5;
	   end
	   else
	     if(word <= 5'd15)begin
		r_all_bin = 3'd2;
		col_bin = word - 5'd10;
	     end
	     else
	       if(word <= 5'd20)begin
		  r_all_bin = 3'd3;
		  col_bin = word - 5'd15;
	       end
	       else begin
		  r_all_bin = 3'd4;
		  col_bin = word - 5'd20;
	       end
	 
	 
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

	 //number of col to be active
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
	// $display(" r_all_nxt5 = %b ",r_all_nxt);
	// $display(" row_nxt5 = %b ", row_nxt);
	// $display(" col_nxt5 = %b ", col_nxt);
	 
      end
      
   end
   

   always @ (negedge clk, posedge rst) begin 
      if(rst)begin
	 //r_all <= 5'd3;
	 r_all <= 5'd28;
	 row <= 5'd4;
	 col <= 5'd7;
      end
      else if(en)begin
	 r_all <= r_all_nxt;
	 row <= row_nxt;
	 col <= col_nxt;

      end
   end 

endmodule // c_sel
