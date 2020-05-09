// Created by ihdl
`timescale 10ps/1ps

`celldefine

module DFZCLRBHHD(Q, QB, D, TD, CK, RB, SEL, LD);
   reg flag; // Notifier flag
   reg  D_flag1, RB_flag1, SEL_flag1, LD_flag1;
   wire D_flag, RB_flag, SEL_flag, LD_flag;
   output Q, QB;
   input D, TD, CK, RB, SEL, LD;
   supply1 vcc;

   wire d_CK, d_D, d_LD, d_RB, d_SEL, d_TD;

//Function Block
`protect
   buf b1 (D_, d_D );      //Avoid MIPD.
   buf b2 (TD_, d_TD );    //Avoid MIPD.
   buf b3 (RB_, d_RB );    //Avoid MIPD.
   buf b4 (SEL_, d_SEL );  //Avoid MIPD.
   buf b5 (LD_, d_LD );    //Avoid MIPD.
   buf g3(Q, qt);
   not g1(QB, qt);
   dffrsb_udp g2(qt,  d1,  d_CK,  vcc,  vcc,  flag );
   and g4(D_tmp, di, RB_);
   mux2_udp g5(di, qt, D_, LD_);
   mux2_udp g9(d1, D_tmp, TD_, SEL_);
// Define the flag for timing check
  assign D_flag   = D_flag1;    // For Model-Tec complier
  assign LD_flag   = LD_flag1;  // For Model-Tec complier
  assign SEL_flag = SEL_flag1;  // For Model-Tec complier
  assign RB_flag  = RB_flag1;   // For Model-Tec complier
  always @(SEL_ or RB_ or LD_)
    begin
      if ((SEL_ === 1'b0) && (RB_ === 1'b1) && (LD_ === 1'b1))
         D_flag1 = 1'b1;
      else
         D_flag1 = 1'b0;
    end
  always @(SEL_ or di)
    begin
      if ((SEL_ === 1'b0) && (di === 1'b1))
         RB_flag1 = 1'b1;
      else
         RB_flag1 = 1'b0;
    end
  always @(D_tmp or TD_)
    begin
      if (D_tmp !== TD_)
         SEL_flag1 = 1'b1;
      else
         SEL_flag1 = 1'b0;
    end
  always @(D_ or Q or RB_ or SEL_)
    begin
      if ((D_ !== Q) && (SEL_ === 1'b0) && (RB_ === 1'b1))
         LD_flag1 = 1'b1;
      else
         LD_flag1 = 1'b0;
    end

//Specify Block
   specify

      //  Module Path Delay
      (posedge CK *> (Q :1'bx)) = (12.31:12.31:12.31, 12.32:12.32:12.32);
      (posedge CK *> (QB :1'bx)) = (18.61:18.61:18.61, 18.74:18.74:18.74);

      //  Setup and Hold Time
      specparam setup_D_CK = 14.89;
      specparam hold_D_CK = 0.00;
      specparam setup_LD_CK = 18.75;
      specparam hold_LD_CK = 0.00;
      specparam setup_RB_CK = 16.99;
      specparam hold_RB_CK = 0.00;
      specparam setup_SEL_CK = 7.77;
      specparam hold_SEL_CK = 0.00;
      specparam setup_TD_CK = 8.10;
      specparam hold_TD_CK = 0.00;
      $setuphold(posedge CK, posedge D &&& D_flag, 14.82:14.82:14.82, -10.96:-10.96:-10.96, flag,,,d_CK, d_D);
      $setuphold(posedge CK, negedge D &&& D_flag, 15.55:15.55:15.55, -10.72:-10.72:-10.72, flag,,,d_CK, d_D);
      $setuphold(posedge CK, posedge LD &&& LD_flag, 18.02:18.02:18.02, -12.69:-12.69:-12.69, flag,,,d_CK, d_LD);
      $setuphold(posedge CK, negedge LD &&& LD_flag, 18.51:18.51:18.51, -10.96:-10.96:-10.96, flag,,,d_CK, d_LD);
      $setuphold(posedge CK, posedge RB &&& RB_flag, 15.55:15.55:15.55, -12.20:-12.20:-12.20, flag,,,d_CK, d_RB);
      $setuphold(posedge CK, negedge RB &&& RB_flag, 14.57:14.57:14.57, -8.99:-8.99:-8.99, flag,,,d_CK, d_RB);
      $setuphold(posedge CK, posedge SEL &&& SEL_flag, 28.62:28.62:28.62, -7.51:-7.51:-7.51, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK, negedge SEL &&& SEL_flag, 12.10:12.10:12.10, -4.31:-4.31:-4.31, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK, posedge TD &&& SEL, 13.09:13.09:13.09, -8.00:-8.00:-8.00, flag,,,d_CK, d_TD);
      $setuphold(posedge CK, negedge TD &&& SEL, 28.62:28.62:28.62, -11.78:-11.78:-11.78, flag,,,d_CK, d_TD);

      //  Minimum Pulse Width
      specparam mpw_neg_CK = 26.43;
      specparam mpw_pos_CK = 23.99;
      $width(negedge CK, 18.44:18.44:18.44, 0, flag);
      $width(posedge CK, 10.07:10.07:10.07, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
