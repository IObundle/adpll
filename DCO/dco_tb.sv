`timescale 1fs / 1fs



///////////////////////////////////////////////////////////////////////////////
// Date: 19/01/2019
// Module: dco_tb.v
// Project: WSN (preparation)
// Description: 
//				 
// Change history: 12/12/19 - 

module dco_tb;

   int dco_in_l, dco_in_m, dco_in_s;
   bit en;
   wire ckv;
   longint mat_pdev;

   
  
   
   // instantiate dco module
   dco dco0(
	   // Inputs
	   .en (en),
	   .dco_in_l (dco_in_l),
	   .dco_in_m (dco_in_m),
	   .dco_in_s (dco_in_s),
	   // Outputs
	   .ckv	(ckv)
	   );

   integer	  fp1;
   initial fp1 = $fopen("dco_ckv_time.txt","w");
   always @ (dco0.smp) $fwrite(fp1, "%0d ", $time);

   parameter real end_time_fs = 1000E9;
   
   always #(end_time_fs /10) $write("Loading progress: %d percent \n", int'(100 * $time  / end_time_fs));

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;

      en = 1;
      dco_in_l = 13;
      dco_in_m = 127;
      dco_in_s = 128;
      
      #1E9 en = 1;
      
      //$display(" %e",SIGMA_WANDER);  
   end // initial begin


   initial       #end_time_fs $finish; 
endmodule
