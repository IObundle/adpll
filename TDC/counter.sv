`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: counter.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: 7-bit ripple-counter with skew compensation
//              			 
//

module counter (
	      input 	   data,
	      input 	   clk,
	      output [6:0] count);
 
   wire [6:0] 		   div2;
   wire [6:0] 		   div_clk;
   wire [6:0] 		   clk_samp;
   wire [2:0] 		   in_latch;
   wire [2:0] 		   out_latch;
   wire [2:0] 		   en_latch;		   
   
   generate
      genvar 		       i;      
      for(i=0; i<7; i=i+1) begin: div2_chain
	 d_ff1 d_ff1_div2 (
			   .d(div2[i]),
			   .clk(div_clk[i]),
			   .q_bar(div2[i])
			   );      end
      for(i=1; i<7; i=i+1) 
	assign div_clk[i] = div2[i-1];

 
      for(i=0; i<7; i=i+1) begin: samp_chain
	 d_ff1 d_ff1_samp (
			   .d(div2[i]),
			   .clk(clk_samp[i]),
			   .q(count[i])
			   );
      end
      
      for(i=0; i<3; i=i+1) begin: latch_chain
	 d_latch1 d_latch1_samp (
				 .d(in_latch[i]),
				 .en_bar(en_latch[i]),
				 .q(out_latch[i])
				 );
      end
      for(i=0; i<3; i=i+1) 
	assign en_latch[i] = div2[i];
      
      for(i=1; i<3; i=i+1) 
	assign in_latch[i] = out_latch[i-1];

       for(i=1; i<7; i=i+1)begin
	  if(i>=3)
	    assign clk_samp[i]=out_latch[2];
	  else
	    assign clk_samp[i]=out_latch[i-1];
       end
      
   endgenerate

   assign div_clk[0] = data;
   assign in_latch[0] = clk;
   assign clk_samp[0] = clk;
   

endmodule
