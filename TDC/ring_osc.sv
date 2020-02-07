`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 04/02/2020
// Module: ring_osc.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: ring oscillator with variable delay inverters
//             oscilator feq = 1/ (inv_delay*2*16)  			 
//

module ring_osc (
		 input 	[31:0]    osc_period_fs,
		 input 	       en,
		 output [15:0] inv_out);


   real		       inv_delay [15:0];
   int		       inv_delay_max_idx [15:0]; 	       
   wire [15:0] 		       inv_in;
   integer 		       k,j,N;
   real		       inv_delay_min, inv_delay_max;
   int	       rand_idx;
   real        aux;
   logic     N_rest;
   

   // Instantiate the inverter chain in open-loop
   generate
      genvar 		       i;
      
      for(i=0; i<16; i=i+1) begin: inv_chain_inst
	 ring_inv ring_inv_chain (
				  .delay_fs(inv_delay[i]),
				  .in(inv_in[i]),
				  .out(inv_out[i])
				  );
      end
      for(i=1; i<16; i=i+1) 
	assign inv_in[i] = inv_out[i-1]; 
   endgenerate
   initial N_rest = 0;
   
   assign inv_in[0] = ~(inv_out[15] & en);
   
   always @ osc_period_fs begin
      // number of inv delay with max delay
      N = osc_period_fs % 32;
      
      //$display("N = %d ",N);
      
      // min inv delay
      inv_delay_min = $floor(osc_period_fs / 32);
      // max inv delay
      inv_delay_max = inv_delay_min + 1;
     
      N = $floor((N+N_rest)/2);
      N_rest = (N+N_rest)%2;
      
      for(j=0; j<16; j=j+1) begin
	 if (j< N )
	   inv_delay[j]=inv_delay_max;
	 else
	   inv_delay[j]=inv_delay_min;
      end
   
      /*
      // randomization of inv_delay array mismatch due time resolution
      for(j=0; j<16; j = j+1)begin
	 rand_idx = $urandom%16;
	 aux = inv_delay[rand_idx];
	 inv_delay[rand_idx] = inv_delay[j];
	 inv_delay[j] = aux;
      end
      */ 
     // for(j=0; j<16; j=j+1) $display("inv_delay = %d ",inv_delay[j]);
   end
endmodule
      

      
	 
      
