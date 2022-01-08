`timescale 1fs / 1fs

///////////////////////////////////////////////////////////////////////////////
// Date: 06/02/2020
// Module: tdc_analog.sv 
// Project: WSN DCO Model (Non-Synt)
// Description: behaviour model of the tdc
//              			 
//

module tdc_analog (
	      input [31:0]  osc_period_fs,
	      input 	    clk,
	      input 	    pd,
	      input 	    pd_inj,
	      input [2:0]   ctr_freq,
	      output [6:0]  ripple_count,
	      output [15:0] phase);

   wire [31:0] 		    osc_period_fs_aux;
   //if injection is power down, the RO runs fixed at 2.5GHz
   assign osc_period_fs_aux = (pd_inj==0)? osc_period_fs : 31'd400000;
   
 //instantiate ring oscillator
   wire [15:0] osc_phases;
   ring_osc ring_osc0(
		      //Inputs
		      .osc_period_fs(osc_period_fs_aux),
		      .en(~pd),
		      //Outputs
		      .inv_out(osc_phases));

   wire [7:0]  clk_ff_ret;
   wire [7:0]  in_ff_ret;
   wire [7:0]  out_ff_ret;
   wire [15:0] osc_phases_aux;
   
   
   
   generate
      genvar 		    i;
      // inverters phases of even osc_phases
      for(i=0; i<16; i=i+1) begin
	 if(i%2 == 1)
	   assign osc_phases_aux[i] = ~osc_phases[i];
	 else
	   assign osc_phases_aux[i] = osc_phases[i];
      end     
      for(i=0; i<16; i=i+1) begin: ff_phase_samp
	 d_ff1 d_ff1_phase_samp (
			   .d(osc_phases_aux[i]),
			   .clk(clk),
			   .q(phase[i]),
			   .q_bar()
			   );      end
      
      for(i=0; i<8; i=i+1) begin: ff_ideal_ret
	 d_ff2 d_ff1_idealret (
			   .d(in_ff_ret[i]),
			   .clk(clk_ff_ret[i]),
			   .q(out_ff_ret[i]),
			   .q_bar()
			   );      end
      for(i=0; i<8; i=i+1) begin
	 if( i==3 || i == 7)
	   assign clk_ff_ret[i] = ~osc_phases_aux[0];
	 else
	   assign clk_ff_ret[i] = osc_phases_aux[0];
      end
   endgenerate

   assign in_ff_ret[0] = clk;
   assign in_ff_ret[1] = out_ff_ret[0];
   assign in_ff_ret[2] = out_ff_ret[1];
   
   assign in_ff_ret[3] = clk;
   assign in_ff_ret[4] = out_ff_ret[3];
   assign in_ff_ret[5] = out_ff_ret[4];
   
   //assign in_ff_ret[6] = ((~phase[0]) ~& out_ff_ret[2])~&(phase[0]~& out_ff_ret[5]);
   assign in_ff_ret[6] = ~((~((~phase[0])&out_ff_ret[2]))&(~(phase[0]& out_ff_ret[5])));
   assign in_ff_ret[7] = out_ff_ret[6];

    //instantiate counter
   counter counter0(
		      //Inputs
		      .data(osc_phases_aux[0]),
		      .clk(out_ff_ret[7]),
		      //Outputs
		      .count(ripple_count));
endmodule
