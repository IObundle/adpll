// Created by ihdl
`timescale 10ps/1ps

`celldefine

module QDFZRSBHHD(Q, D, TD, CK, SEL, RB, SB);
   reg flag; // Notifier flag
   output Q;
   input D, TD, CK, RB, SB, SEL;
   reg D_flag;
   wire d_CK, d_D, d_SEL, d_TD, D_flag1;
   wire d_RB, d_SB;

//Function Block
`protect
   buf b3 (SEL_, d_SEL );  //Avoid MIPD.

   buf g2(Q, qt);
   dffrsb_udp g1(qt,  d1,  d_CK,  d_RB,  d_SB,  flag );
   mux2_udp g4(d1,  d_D,  d_TD,  SEL_ );

//Append pseudo gate for timing violation checking
and (_SB_and_RB_, d_SB, d_RB);
or (_SB_or_RB_, d_SB, d_RB);
assign D_flag1 = D_flag;
always @(SEL_ or d_D or d_TD)
  begin
    if (SEL_ === 1'b0)
        D_flag = d_D;
    else
        D_flag = d_TD;
  end

//Timing violation checking statement
always @(negedge _SB_or_RB_) if(_SB_or_RB_ === 0)
  $display($time, " ****Warning! Set and Reset of %m are low simultaneously");




//Specify Block
   specify

      //  Module Path Delay
      (posedge CK *> (Q :1'bx)) = (15.26:15.26:15.26, 15.88:15.88:15.88);
      (negedge SB *> (Q :1'bx)) = (18.33:18.33:18.33, 0.00:0.00:0.00);
      (negedge RB *> (Q :1'bx)) = (0.00:0.00:0.00, 6.17:6.17:6.17);

      //  Setup and Hold Time
      specparam setup_D_CK = 9.00;
      specparam hold_D_CK = 0.00;
      specparam setup_SEL_CK = 8.50;
      specparam hold_SEL_CK = 0.00;
      specparam setup_TD_CK = 8.71;
      specparam hold_TD_CK = 0.00;
      $setuphold(posedge CK &&& _SB_and_RB_, posedge D &&& ~SEL, 12.35:12.35:12.35, -3.07:-3.07:-3.07, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& _SB_and_RB_, negedge D &&& ~SEL, 11.36:11.36:11.36, -2.09:-2.09:-2.09, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& _SB_and_RB_, posedge SEL, 30.84:30.84:30.84, -4.80:-4.80:-4.80, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK &&& _SB_and_RB_, negedge SEL, 16.79:16.79:16.79, -2.33:-2.33:-2.33, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK &&& _SB_and_RB_, posedge TD &&& SEL, 16.79:16.79:16.79, -5.79:-5.79:-5.79, flag,,,d_CK, d_TD);
      $setuphold(posedge CK &&& _SB_and_RB_, negedge TD &&& SEL, 31.58:31.58:31.58, -10.22:-10.22:-10.22, flag,,,d_CK, d_TD);

      //  Recovery Time
      specparam recovery_RB_CK = 5.90;
      specparam recovery_SB_CK = 10.35;
      specparam recovery_CK_RB = 8.80;
      specparam recovery_CK_SB = 1.29;
      $recrem(posedge RB, posedge CK &&& D_flag1, 0.00:0.00:0.00, 6.79:6.79:6.79, flag,,,d_RB,d_CK);
      $recrem(posedge SB, posedge CK &&& ~D_flag1, 2.49:2.49:2.49, 0.13:0.13:0.13, flag,,,d_SB,d_CK);

      //  Minimum Pulse Width
      specparam mpw_neg_RB = 7.17;
      specparam mpw_neg_SB = 20.89;
      specparam mpw_neg_CK = 15.11;
      specparam mpw_pos_CK = 13.02;
      $width(negedge RB, 10.93:10.93:10.93, 0, flag);
      $width(negedge SB, 23.86:23.86:23.86, 0, flag);
      $width(negedge CK, 22.63:22.63:22.63, 0, flag);
      $width(posedge CK, 12.04:12.04:12.04, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
