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
              input 	   pd,
	      input [1:0]  osc_gain,
	      input [4:0]  c_l_rall,
	      input [4:0]  c_l_row,
	      input [4:0]  c_l_col,
	      input [15:0] c_m_rall,
	      input [15:0] c_m_row,
	      input [15:0] c_m_col,
	      input [15:0] c_s_rall,
	      input [15:0] c_s_row,
	      input [15:0] c_s_col,
	      output reg   ckv,
	      output [31:0] period_fs);
   
   parameter real noise_floor_dBc = -150; //noise floor in dBc
   parameter real delta_f_wander =  1.0e6;
   parameter real PN_at_delta_t_dBc =  -120; //phase noise at delta frequency in dBc
   
   parameter real pi = 3.14159;
   parameter real noise_floor = 10**(noise_floor_dBc/10.0);
   parameter real SIGMA_JITTER = int'((1.0/(`F_OUT*2.0*pi))*$sqrt(noise_floor*`F_OUT)*1e15);
   parameter real PN_at_delta_t = 10**(PN_at_delta_t_dBc/10.0);
   parameter real SIGMA_WANDER = int'((1.0*delta_f_wander/`F_OUT)*$sqrt(1.0/`F_OUT)*$sqrt(PN_at_delta_t)*1e15); // in fs

   parameter int N_L = 25; // number of large capacitors
   parameter int N_M = 256; // number of medium capactiors
   parameter int N_S = 256; // number os small capacitors
   
		 
   int 		  dco_in_l;
   
   real 	  c_l, c_m, c_s, c_total;
   real 	  T_osc_true;
   real 	  rest = 0;
   /////////////////////////////////////////////////////////////////////////////
   // Instantiate the c_sel of Large C bank
   ////////////////////////////////////////////////////////////////////////////
   wire [N_L-1:0] c_l_val;
   generate
      genvar 	  il, jl;  
      for(il=0; il<5; il = il +1) begin : c_sel_cols_l
	 for(jl=0; jl < 5; jl = jl+1) begin : c_sel_rows_l	    
	    c_sel c_sel_l (
			   // inputs
			   .r_all(c_l_rall[il]),
			   .row(c_l_row[il]),
			   .col(c_l_col[jl]),
			   //ouputs
			   .out(c_l_val[5*jl+il]));	    
	 end
      end 
   endgenerate
   //sum of all L caps
   reg [4:0] 	  c_l_val_sum;
   integer kl;
   always @c_l_val begin
      c_l_val_sum = c_l_val[0]; 
      for(kl=1; kl<N_L; kl=kl+1)
	c_l_val_sum = c_l_val_sum + c_l_val[kl];
   end
 /////////////////////////////////////////////////////////////////////////////
 // Instantiate the c_sel of Medium C bank
 ////////////////////////////////////////////////////////////////////////////
   wire [N_M-1:0] c_m_val;
   generate
      genvar 	  im, jm;  
      for(im=0; im<16; im = im +1) begin : c_sel_cols_m
	 for(jm=0; jm < 16; jm = jm+1) begin : c_sel_rows_m	    
	    c_sel c_sel_m (
			   // inputs
			   .r_all(c_m_rall[im]),
			   .row(c_m_row[im]),
			   .col(c_m_col[jm]),
			   //ouputs
			   .out(c_m_val[16*jm+im]));	    
	 end
      end // block: c_sel_cols_m    
   endgenerate
   //sum of all M caps
   reg [8:0] 	  c_m_val_sum;
   integer km;
   always @c_m_val begin
      c_m_val_sum = c_m_val[0]; 
      for(km=1; km<N_M; km=km+1)
	c_m_val_sum = c_m_val_sum + c_m_val[km];
   end

 /////////////////////////////////////////////////////////////////////////////
 // Instantiate the c_sel of Small C bank
 ////////////////////////////////////////////////////////////////////////////
   wire [N_S-1:0] c_s_val;
   generate
      genvar 	  is, js;  
      for(is=0; is<16; is = is +1) begin : c_sel_cols_s
	 for(js=0; js < 16; js = js+1) begin : c_sel_rows_s	    
	    c_sel c_sel_s (
			   // inputs
			   .r_all(c_s_rall[is]),
			   .row(c_s_row[is]),
			   .col(c_s_col[js]),
			   //ouputs
			   .out(c_s_val[16*js+is]));	    
	 end
      end 
   endgenerate
   //sum of all M caps
   reg [8:0] 	  c_s_val_sum;
   integer ks;
   always @c_s_val begin
      c_s_val_sum = c_s_val[0]; 
      for(ks=1; ks<N_S; ks=ks+1)
	c_s_val_sum = c_s_val_sum + c_s_val[ks];
   end
   
   /////////////////////////////////////////////////////////////////////////////
   // Calculate total C of tank
   /////////////////////////////////////////////////////////////////////////////
   //initial  $monitor("c_l_val_sum = %d ,c_m_val_sum = %d, c_s_val_sum = %d ",c_l_val_sum,c_m_val_sum,c_s_val_sum  );

   //negative c gain
   assign c_l = (25-c_l_val_sum) * C_L_LSB; 
   assign c_m = (255-c_m_val_sum) * C_M_LSB;
   assign c_s = (255-c_s_val_sum) * C_S_LSB;
   assign c_total = c_l + c_m + c_s + C_FIXED; // in fF
   // Calculate DCO ideal period
   assign T_osc_true = 2*pi*$sqrt(c_total * L_IND * 1e6 ); // in fs
   
   real freq_dco;
   assign freq_dco = 1e15/T_osc_true;
   
   
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

      
   always @(smp, pd) begin
    if ( !init && (~pd) ) begin

       
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
       //tref = DCO_INIT_DLY;
       ckv <= 0;
       #period_fs
       smp <= 1;
       init <= 0;
    end  
   end

   

      
endmodule
   
   
   
