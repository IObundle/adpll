`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: tdc_digital.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: digital control of the tdc
//              			 
//

module tdc_digital (
		    input 	  rst,
		    input 	  en,
		    input 	  clk,
		    input [6:0]  counter_in,
		    input [15:0] phase_in,
		    output [11:0] tdc_word);

  
   reg [6:0]				      counter;
   reg [15:0] 				      phase; 				      
   integer 				      i,j;
   //input sampling
   always @ (negedge clk, posedge rst) begin 
      if(rst == 1'b1) begin
	 for (i=0; i<7; i=i+1) 
	   counter[i] <= 1'b0;
	 for (i=0; i<16; i=i+1) 
	   phase[i] <= 1'b0;
      end
      else if(en == 1'b1) begin
	 for (i=0; i<7; i=i+1) 
	   counter[i] <= counter_in[i];
	 for (i=0; i<16; i=i+1) 
	   phase[i] <= phase_in[i];
      end
   end 
      

   wire [6:0]			      counter_aux,counter_mod;
   reg [6:0] 			      counter_last;
   
   // compensation due to multiple retiming choice algorithm   
   assign counter_aux = (phase[0] == 1) ? counter-1 : counter;
   
   // Modulo arithmetic accumulator calculation
   assign counter_mod = counter_last - counter_aux;
   

   reg 				      edge_flag;
   reg  [4:0] 			      edge_index,edge_index_last;
   wire [4:0] 			      phase_shift;
 			      
   //finds the index of 1->0 of cyclic thermometer word
   always @ phase begin
      edge_flag = 1'b0;
      for (j=1; j<16; j = j+1) begin
	 if(phase[j-1]==1'b1 && phase[j]==1'b0) begin
	    edge_index = j-1'd1;
	    edge_flag = 1'b1;
	 end
	 if(phase[j-1]==1'b0 && phase[j]==1'b1) begin
	    edge_index = j-1'b1 + 5'd16;
	    edge_flag = 1'b1;
	 end
      end
      // if there is no edge dectection, means that 
      // the edge_index is one of the two phase edges 
      if(edge_flag == 1'b0)
	if(phase[5] == 1'b1)
	  edge_index = 5'd15;
	else
	  edge_index = 5'd31;
      
   end 

   //assign phase_shift = edge_index - edge_index_last;

   assign tdc_word = (counter_mod<<5) + edge_index - edge_index_last;
   
     
   always @ (negedge clk, posedge rst)
     if(rst == 1'b1) begin
	counter_last <= 1'b0;
	edge_index_last <= 1'b0;
	end
     else if(en == 1'b1) begin
       counter_last <= counter_aux;
	edge_index_last <= edge_index;
     end	
endmodule
