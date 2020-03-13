`timescale 1fs / 1fs
`include "adpll_defines.v"

`define FCWW 26 // FCW word width
`define ACCW 27 // Phase Accumulator width
`define INTW 12 // FCW integer part word width
`define FRAW 14 // FCW fractional part word width

///////////////////////////////////////////////////////////////////////////////
// Date: 08/02/2020
// Module: adpll_ctr0.v
// Project: WSN DCO Model 
// Description:  adpll control without CPU interface
//               
//				 

module adpll_ctr0(
    input 	      rst,
    input 	      en,
    input 	      clk,
    input [`FCWW-1:0] FCW,
    input [1:0]       adpll_mode,
    output 	      channel_lock,
    input 	      data_mod,
    // analog dco interface
    output 	      dco_pd,
    output [4:0]      dco_c_l_rall,
    output [4:0]      dco_c_l_row,
    output [4:0]      dco_c_l_col,
    output [15:0]     dco_c_m_rall,
    output [15:0]     dco_c_m_row,
    output [15:0]     dco_c_m_col,
    output [15:0]     dco_c_s_rall,
    output [15:0]     dco_c_s_row,
    output [15:0]     dco_c_s_col,
    //analog tdc interface
    output 	      tdc_pd,
    output 	      tdc_pd_inj,
    input [6:0]       tdc_ripple_count,
    input [15:0]      tdc_phase,
    //external registers
    input [3:0]       alpha_l,
    input [3:0]       alpha_m,
    input [3:0]       alpha_s_rx,
    input [3:0]       alpha_s_tx,
    input [3:0]       beta,
    input [2:0]       lambda_rx,
    input [2:0]       lambda_tx,
    input [1:0]       iir_n_rx,
    input [1:0]       iir_n_tx, 
    input [4:0]       FCW_mod,
    input [4:0]       dco_c_l_word_test,
    input [7:0]       dco_c_m_word_test,
    input [7:0]       dco_c_s_word_test,
    input 	      dco_pd_test,
    input 	      tdc_pd_test,
    input 	      tdc_pd_inj_test		 
		 );

   wire signed [4:0]  dco_c_l_word;
   wire signed [7:0]  dco_c_m_word;
   wire signed [7:0]  dco_c_s_word;
   wire [11:0] 	      tdc_word;
   
   
   ///////////////////////////////////////////////////////////////////
   /// Col-Row Decoders Instantiation
   ///////////////////////////////////////////////////////////////////
   // instantiate row_col_coder of Large c bank
   row_col_cod_5x5 row_col_cod_l(
			    //Inputs
			    .rst(rst),
			    .en(en),
			    .clk(clk),
			    //two's comp to abs convertion
			    .word((dco_c_l_word[4]==0)?dco_c_l_word+5'd13:
				  dco_c_l_word-5'd19),
			    //Outputs
			    .r_all(dco_c_l_rall),
			    .row(dco_c_l_row),
			    .col(dco_c_l_col)
			    );
   // instantiate row_col_coder of medium c bank
   
   row_col_cod row_col_cod_m(
			    //Inputs
			    .rst(rst),
			    .en(en),
			    .clk(clk),
			     //two's comp to abs convertion
			    .word({~dco_c_m_word[7],dco_c_m_word[6:0]}), 
			    //Outputs
			    .r_all(dco_c_m_rall),
			    .row(dco_c_m_row),
			    .col(dco_c_m_col)
			    );
   // instantiate row_col_coder of small c bank
   row_col_cod row_col_cod_s(
			    //Inputs
			    .rst(rst),
			    .en(en),
			    .clk(clk),
			     //two's comp to abs convertion
			    .word({~dco_c_s_word[7],dco_c_s_word[6:0]}),
			    //Outputs
			    .r_all(dco_c_s_rall),
			    .row(dco_c_s_row),
			    .col(dco_c_s_col)
			    );
   // instantiate tdc digital interface (half clk delay)
   tdc_digital tdc_digital0(
		      //Inputs
			  .clk(clk),
			  .rst(rst),
			  .en(en),
			  .counter_in(tdc_ripple_count),
			  .phase_in(tdc_phase),
			  //Outputs
			  .tdc_word(tdc_word));

   
   assign dco_pd = (adpll_mode == TEST)? dco_pd_test : dco_pd_state;
   assign tdc_pd = (adpll_mode == TEST)? tdc_pd_test : tdc_pd_state;
   assign tdc_pd_inj = (adpll_mode == TEST)? tdc_pd_inj_test : tdc_pd_inj_state;
   
   ///////////////////////////////////////////////////////////////////
   /// ADPLL state machine
   ///////////////////////////////////////////////////////////////////
   reg [`FCWW-1:0] FCW_last;
   reg [1:0] 	   adpll_mode_last;
   reg [3:0] 	   alpha;
   reg [8:0] 	   time_count, time_count_nxt;
   reg 		   dco_pd_state, dco_pd_state_nxt;
   reg 		   tdc_pd_state, tdc_pd_state_nxt;
   reg 		   tdc_pd_inj_state, tdc_pd_inj_state_nxt;
   reg [2:0] 	   state_rx, state_rx_nxt;
   reg 		   rst_accum, rst_accum_nxt;
   reg [4:0] 	   c_l_word_freeze;
   reg 		   rst_lock_detect_nxt, rst_lock_detect;
   reg 		   en_lock_detect_nxt, en_lock_detect;
   reg 		   channel_lock, channel_lock_nxt;
   reg 		   en_integral, en_integral_nxt;
   reg 		   en_mod,en_mod_nxt;
         
      
   parameter IDLE = 3'd0, PU = 3'd1, C_L = 3'd2, C_M = 3'd3, C_S = 3'd4;
   parameter  PD = 2'd0, TEST = 2'd1, RX = 2'd2, TX = 2'd3;

   reg signed [7:0] 		otw_int_round_sat;
   reg signed [4:0] 		otw_l_fixed, otw_l_fixed_nxt;
   reg signed [7:0] 		otw_m_fixed, otw_m_fixed_nxt;
   reg signed [7:0] 		otw_s_fixed, otw_s_fixed_nxt;

   ///// Phase Diference and Accumulator /////
   wire signed [`ACCW-1:0] 	      ph_diff;
   wire signed [`ACCW-1:0] 	      ph_diff_accum;
   reg signed [`ACCW-1:0] 	ph_diff_accum_last;
   wire signed [`ACCW-1:0] 	ph_diff_mod;
   wire signed [`ACCW-1:0] 	freq_dev;

      
   assign ph_diff = FCW - {tdc_word,{{(`FRAW){1'b0}}}};

   ////// Modulation /////
   assign freq_dev = (data_mod == 1'b1)? 
		     {{{(`INTW+1){1'b0}}},FCW_mod,{{(`FRAW-5){1'b0}}}}:
		     ~{{{(`INTW+1){1'b0}}},FCW_mod,{{(`FRAW-5){1'b0}}}}+1;
	
   assign ph_diff_mod = (en_mod==1'b0)? ph_diff: ph_diff + freq_dev;
   
   assign ph_diff_accum = ph_diff_accum_last + ph_diff_mod;

   always @ (negedge clk, posedge rst|rst_accum )
     if(rst|rst_accum == 1'b1)
       ph_diff_accum_last <= `ACCW'd0;
     else if(en == 1'b1)
       ph_diff_accum_last <= ph_diff_accum;
   

   ///// Integral Filter Accumulator /////
   wire signed [`ACCW-1:0] 	integral;
   wire signed [`ACCW-1:0] 	integral_beta;
   reg signed [`ACCW-1:0] 	integral_last;
   
   assign integral = iir_out + integral_last;
   assign integral_beta = integral >>> beta;
   always @ (negedge clk, posedge rst)
      if(rst|rst_accum == 1'b1)
	 integral_last <= iir_out;
      else if(en == 1'b1)
	 integral_last <= integral;

    ///// IIR filters /////
   reg [1:0] 			iir_n;
   reg [2:0] 			lambda;
   wire signed [`ACCW-1:0] 	iir_out;
   wire signed [`ACCW-1:0] 	iir1_in, iir2_in, iir3_in;
   wire signed [`ACCW-1:0] 	iir1_out, iir2_out, iir3_out;
   reg signed [`ACCW-1:0] 	iir1_out_last, iir2_out_last, iir3_out_last;

   assign iir1_in = ph_diff_accum;
   assign iir1_out = (iir1_in>>>lambda)-(iir1_out_last>>>lambda)+iir1_out_last;
   assign iir2_in = iir1_out;
   assign iir2_out = (iir2_in>>>lambda)-(iir2_out_last>>>lambda)+iir2_out_last;
   assign iir3_in = iir2_out;
   assign iir3_out = (iir3_in>>>lambda)-(iir3_out_last>>>lambda)+iir3_out_last;
   
   //assign iir_out = ph_diff_accum;
   //4->1 mux
   assign iir_out = iir_n[1] ? (iir_n[0] ? iir3_out : iir2_out) :
		    (iir_n[0] ? iir1_out : iir1_in);

   always @ (negedge clk, posedge rst )
     if(rst|rst_accum == 1'b1) begin
	iir1_out_last <= `ACCW'd0;
	iir2_out_last <= `ACCW'd0;
	iir3_out_last <= `ACCW'd0;
     end
     else if(en == 1'b1) begin
	iir1_out_last <= iir1_out;
	iir2_out_last <= iir2_out;
	iir3_out_last <= iir3_out;
     end 

   wire signed [`ACCW-1:0] 	ntw;
   wire signed [`ACCW-1:0] 	otw;
   wire [`FRAW-1:0] 		otw_frac;
   wire signed [`ACCW-1-`FRAW:0] otw_int;
   wire signed [`ACCW-1-`FRAW:0] otw_int_round; 
  
        
   assign ntw = (en_integral == 1'b1)? integral_beta + (iir_out >>> alpha) :
		iir_out >>> alpha;
   
   assign otw = (ntw << 7) + (ntw << 6);
   
   assign otw_int = otw[`ACCW-1:`FRAW];
    //round of decimal part (otw_frac width = 14)
   assign otw_int_round = (otw[13]) ? otw_int + 1 : otw_int;

   //C banks word limiter
   assign otw_int_round_sat = (state_rx == C_L)? ((otw_int_round > 16'sd12 ) ? 8'sd12 :
   			      ((otw_int_round < -16'sd13 ) ? -8'sd13:otw_int_round )) : 
			      (otw_int_round > 16'sd127 ) ? 8'sd127 :
			      ((otw_int_round < -16'sd128 ) ? -8'sd128: otw_int_round); 
   
   
   assign dco_c_l_word = (adpll_mode == TEST)? dco_c_l_word_test :
			 (((state_rx == C_L) && ~rst_accum )? otw_int_round_sat :
			  otw_l_fixed);
   assign dco_c_m_word = (adpll_mode == TEST)? dco_c_m_word_test :
			 (((state_rx == C_M) && ~rst_accum )? otw_int_round_sat :
			 otw_m_fixed);
   assign dco_c_s_word = (adpll_mode == TEST)? dco_c_s_word_test :
			 (((state_rx == C_S) && ~rst_accum )? otw_int_round_sat :
			 otw_s_fixed);
   
   
   always @ (FCW, adpll_mode, state_rx, time_count, otw_int_round_sat, lock_detect) begin
      state_rx_nxt = state_rx;
      otw_l_fixed_nxt = otw_l_fixed;
      otw_m_fixed_nxt = otw_m_fixed;
      otw_s_fixed_nxt = otw_s_fixed;
      time_count_nxt = time_count;
      dco_pd_state_nxt = dco_pd_state;
      tdc_pd_state_nxt = tdc_pd_state;
      tdc_pd_inj_state_nxt = tdc_pd_inj_state;  
      rst_accum_nxt = rst_accum;
      rst_lock_detect_nxt = rst_lock_detect;
      en_lock_detect_nxt = en_lock_detect;
      alpha = alpha_s_rx;
      channel_lock_nxt = channel_lock;
      en_integral_nxt = en_integral;
      lambda = lambda_rx;
      iir_n = 2'd0;
      en_mod_nxt = en_mod;
      
      // Detection FCW or adpll_mode change         
      if( (FCW != FCW_last) || (adpll_mode != adpll_mode_last))
	state_rx_nxt = IDLE;
      else
	case(state_rx)
	  IDLE:
	    begin
	       time_count_nxt = 9'd0;
	       otw_l_fixed_nxt = 5'sd0;
	       otw_m_fixed_nxt = 8'sd0;
	       otw_s_fixed_nxt = 8'sd0;
	       en_lock_detect_nxt = 1'b0;
	       rst_lock_detect_nxt = 1'b1;
	       channel_lock_nxt = 1'b0;
	       en_integral_nxt = 1'b0;
	       en_mod_nxt = 1'b0;
	       if(adpll_mode == PD) begin
		  dco_pd_state_nxt = 1'b1;
		  tdc_pd_state_nxt = 1'b1;
		  tdc_pd_inj_state_nxt = 1'b1;
	       end
	       
	       if(adpll_mode == RX || adpll_mode == TX )
		 state_rx_nxt = PU;
	    end
	  PU://power up of analog blocks
	    begin
	       time_count_nxt = time_count + 9'd1;
	       dco_pd_state_nxt = 1'b0;
	       case(time_count)
		 6'd16: tdc_pd_state_nxt = 1'b0;
		 6'd32: tdc_pd_inj_state_nxt = 1'b0;
		 6'd48:
		   begin 
		      state_rx_nxt = C_L;
		      rst_accum_nxt = 1'b1;
		      time_count_nxt = 9'd0; 
		   end
	       endcase
	    end 
	  C_L: // Large C bank operation
	    begin
	       rst_accum_nxt = 1'b0;
	       rst_lock_detect_nxt = 1'b0;
	       alpha = alpha_l;
	       en_lock_detect_nxt = 1'b1;
	       if(lock_detect)begin
		  otw_l_fixed_nxt = lock_detect_word;	      
		  state_rx_nxt = C_M;
		  rst_accum_nxt = 1'b1;
		  rst_lock_detect_nxt = 1'b1;
	       end
	    end 
	  C_M: // Medium C bank operation
	    begin
	       rst_accum_nxt = 1'b0;
	       alpha = alpha_m;
	       rst_lock_detect_nxt = 1'b0;
	       if(lock_detect)begin		  
		  otw_m_fixed_nxt = lock_detect_word;  
		  state_rx_nxt = C_S;
		  rst_accum_nxt = 1'b1;
		  en_lock_detect_nxt = 1'b0;
	       end
	    end //
	  C_S: // Small C bank operation
	    begin 
	       case(adpll_mode)
		 RX: 
		   begin
		      rst_accum_nxt = 1'b0;
		      alpha = alpha_s_rx;
		      iir_n = iir_n_rx;
		      lambda = lambda_rx;
		      time_count_nxt = time_count + 9'd1;
		      if(beta > 4'd0)
			en_integral_nxt = 1'b1;
		      
		      case(time_count)
			9'd480: channel_lock_nxt = 1'b1;  // 15us	    
		      endcase 
		   end 
		 TX:
		   begin
		      rst_accum_nxt = 1'b0;
		      alpha = alpha_s_tx;
		      iir_n = iir_n_tx;
		      lambda = lambda_tx;
		      time_count_nxt = time_count + 9'd1;
		      case(time_count)
			9'd480: channel_lock_nxt = 1'b1;  // 15us
		      endcase
		      if(channel_lock == 1'b1) 
			en_mod_nxt = 1'b1;
		      
		   end
	       endcase
	    end


	endcase // case (state_rx)
   end
   
   always @ (negedge clk, posedge rst)
     if(rst == 1'b1)begin
	state_rx <= IDLE;
	time_count <= 9'd0;
	dco_pd_state <= 1'b1;
	tdc_pd_state <= 1'b1;
	tdc_pd_inj_state <= 1'b1;
	rst_accum <= 1'b0;
	otw_l_fixed <= 5'sd0;
	otw_m_fixed <= 8'sd0;
	otw_s_fixed <= 8'sd0;
	en_lock_detect <= 1'b0;
	rst_lock_detect <= 1'b0;
	channel_lock <= 1'b0;
	en_integral <= 1'b0;
	en_mod <= 1'b0;
	FCW_last <= FCW;
	adpll_mode_last <= adpll_mode;
     end
     else if(en == 1'b1)begin
	state_rx <= state_rx_nxt;
	time_count <= time_count_nxt;
	dco_pd_state <= dco_pd_state_nxt;
	tdc_pd_state <= tdc_pd_state_nxt;
	tdc_pd_inj_state <= tdc_pd_inj_state_nxt;
   	rst_accum <= rst_accum_nxt;
	otw_l_fixed <= otw_l_fixed_nxt;
	otw_m_fixed <= otw_m_fixed_nxt;
	otw_s_fixed <= otw_s_fixed_nxt;
	en_lock_detect <= en_lock_detect_nxt;
	rst_lock_detect <= rst_lock_detect_nxt ;
	channel_lock <= channel_lock_nxt;
	en_integral <= en_integral_nxt;
	en_mod <= en_mod_nxt;
	FCW_last <= FCW;
	adpll_mode_last <= adpll_mode;
     end 

      
   //////////////////////////////////////////////////////////////////////////
   ////// Fine frequency lock detector 
   //////////////////////////////////////////////////////////////////////////

   reg signed [`ACCW-1-`FRAW:0]      aux1, aux1_nxt, aux2, aux2_nxt;
   reg [3:0] 			      aux1_count, aux1_count_nxt, aux2_count, aux2_count_nxt;
   reg 				      lock_detect, lock_detect_nxt;
   reg signed [`ACCW-1-`FRAW:0]       lock_detect_word, lock_detect_word_nxt;
   				      
   
   always @ (otw_int_round_sat, lock_detect) begin
      
      aux1_nxt = aux1;
      aux2_nxt = aux2;
      aux1_count_nxt = aux1_count;
      aux2_count_nxt = aux2_count;
      lock_detect_nxt = lock_detect;
      lock_detect_word_nxt = lock_detect_word;
            
      if(otw_int_round_sat == aux1) begin
	 aux1_count_nxt = aux1_count_nxt + 4'd1;
	 if(aux1_count_nxt == 13'd8)begin
	    lock_detect_nxt = 1'b1;
	    lock_detect_word_nxt = aux1;
	 end
      end
      else 
	if(otw_int_round_sat == aux2) begin
	   aux2_count_nxt = aux2_count_nxt + 4'd1;
	   if(aux2_count_nxt == 13'd8)begin
	      lock_detect_nxt = 1'b1;
	      lock_detect_word_nxt = aux2;   
	   end	   
	end
	else begin
	   aux1_nxt = otw_int_round;
	   aux1_count_nxt = 4'd1;
	   aux2_nxt = aux1;
	   aux2_count_nxt = aux1_count;
	end 


   end 
   always @ (negedge clk, posedge rst|rst_lock_detect )
     if(rst|rst_lock_detect)begin
	aux1 <= {(`ACCW-`FRAW){1'b1}};
     aux2 <= {(`ACCW-`FRAW){1'b1}};
     aux1_count <=4'h0;
     aux2_count <= 4'h0;
     lock_detect <= 1'b0;
     lock_detect_word <= {(`ACCW-`FRAW){1'b1}};
  end
     else if(en & en_lock_detect)begin
	aux1 <= aux1_nxt;
	aux2 <= aux2_nxt;
	aux1_count <= aux1_count_nxt;
	aux2_count <= aux2_count_nxt;
	lock_detect <= lock_detect_nxt;
	lock_detect_word <= lock_detect_word_nxt;
     end

   ///////////////////////////////////////////////////////////////////
   /// DEBUG MODE
   ///////////////////////////////////////////////////////////////////
/*
   // used in debug mode
   wire [`INTW-1:0] 		      FCW_int;
   wire [`FRAW-1:0] 		      FCW_frac;
   assign FCW_int = FCW[`FCWW-1:`FRAW];
   assign FCW_frac = FCW[`FRAW-1:0];
   
   wire signed [`INTW:0] 	      ph_diff_int; 
   assign ph_diff_int = FCW_int - tdc_word; 
*/  
   
   
endmodule 

   
   
   


   
	
   
