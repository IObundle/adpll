`timescale 1fs / 1fs

`define F_OUT 2448e6


///////////////////////////////////////////////////////////////////////////////
// Date: 22/01/2019
// Module: dco.v
// Project: WSN DCO Model (Non-Synt)
// Description: 
//				 
// Change history: 12/12/19 - 

module dco #(
	     parameter real C_L_LSB = 19.14, // in fF
	     parameter real C_M_LSB = 0.18078, // in fF
	     parameter real C_S_LSB = 0.00434, // in fF
	     parameter real C_FIXED = 784, // in fF
	     parameter real L_IND = 4, //in nH

	     parameter DCO_INIT_DLY = 0)
             (
              input 	 en, 
	      input int  dco_in_l,
	      input int  dco_in_m,
	      input int  dco_in_s,
	      output bit ckv);

   parameter real noise_floor_dBc = -140; //noise floor in dBc
   parameter real delta_f_wander =  1.0e6;
   parameter real PN_at_delta_t_dBc =  -100; //phase noise at delta frequency in dBc
   
   parameter real pi = 3.14159;
   parameter real noise_floor = 10**(noise_floor_dBc/10.0);
   parameter real SIGMA_JITTER = int'((1.0/(`F_OUT*2.0*pi))*$sqrt(noise_floor*`F_OUT)*1e15);
   parameter real PN_at_delta_t = 10**(PN_at_delta_t_dBc/10.0);
   parameter real SIGMA_WANDER = int'((1.0*delta_f_wander/`F_OUT)*$sqrt(1.0/`F_OUT)*$sqrt(PN_at_delta_t)*1e15); // in fs
   
   real 	  c_l, c_m, c_s, c_total;
   real 	  T_osc_true;
   real 	  rest = 0;
   
 	  
   // Calculate total C of tank
   assign c_l = dco_in_l * C_L_LSB;
   assign c_m = dco_in_m * C_M_LSB;
   assign c_s = dco_in_s * C_S_LSB;
   assign c_total = c_l + c_m + c_s + C_FIXED; // in fF
   // Calculate DCO ideal period
   assign T_osc_true = 2*pi*$sqrt(c_total * L_IND * 1e6 ); // in fs  

   
   /////////////////////////////////////////////////////////////////////////////
   // Period-Controled Oscillator (PCO)
   /////////////////////////////////////////////////////////////////////////////

   bit smp = 0;
   real period_fs;
   int tdiff_fs;

   bit init = 1;
   int jitter = 0;
   int jitter_prev = 0;
   int wander = 0;
   int seed = -1;

      
   always @(smp, en) begin
    if ( !init && en ) begin

       
       // adjust the next VCO period
       //T_osc = $floor(T_osc_true + rest );
       //rest <= rest + T_osc_true - T_osc ;
       period_fs = T_osc_true;

       //$display(" %f, %f, %f", T_osc_true, period_fs, rest);
       
       if (SIGMA_JITTER != 0) begin
	  // add Gaussian-distributed jitter
	  jitter = $dist_normal(seed, 0, SIGMA_JITTER);
	  if ($abs(jitter) >= period_fs/2)
	    jitter = 0;
	  //$display(" %e, %e",jitter, jitter_prev);
	  period_fs = period_fs + jitter - jitter_prev;
	  jitter_prev = jitter;
       end
       
       	  
       if (SIGMA_WANDER != 0) begin
	  // add Gaussian-distributed wander
	  wander = $dist_normal(seed, 0, SIGMA_WANDER);
	  
	  if ($abs(wander) >= period_fs/2)
	    wander = 0;
	  period_fs = period_fs + wander;
       end

	
       #(period_fs/2.0)
       ckv <= 0;
       #(period_fs/2.0) 
       ckv <= 1;
       smp <= ~smp;
    end 
    else begin
       period_fs = T_osc_true;
       tref = DCO_INIT_DLY;
       ckv <= 0;
       #period_fs
       smp <= 1;
       init <= 0;
    end  
   end

   

      
endmodule
   
   
   
