// Created by ihdl
`timescale 10ps/1ps

`celldefine

module QDFZSBHHD(Q, D, TD, CK, SEL, SB);
   reg flag; // Notifier flag
   output Q;
   input D, CK, TD, SB, SEL;
   supply1 vcc;
   reg D_flag;
   wire d_CK, d_D, d_SEL, d_TD, D_flag1;
   wire d_SB;

//Function Block
`protect
   buf b3 (SEL_, d_SEL );  //Avoid MIPD.

   buf g3(Q, qt);
   dffrsb_udp g1(qt,  d1,  d_CK,  vcc,  d_SB,  flag );
   mux2_udp g4(d1,  d_D,  d_TD,  SEL_ );

//Append pseudo gate for timing violation checking
assign D_flag1 = D_flag;
always @(SEL_ or d_D or d_TD)
  begin
    if (SEL_ === 1'b0)
        D_flag = d_D;
    else
        D_flag = d_TD;
  end


//Specify Block
   specify

      //  Module Path Delay
      (posedge CK *> (Q :1'bx)) = (13.18:13.18:13.18, 12.79:12.79:12.79);
      (negedge SB *> (Q :1'bx)) = (14.87:14.87:14.87, 0.00:0.00:0.00);

      //  Setup and Hold Time
      specparam setup_D_CK = 6.90;
      specparam hold_D_CK = 0.00;
      specparam setup_SEL_CK = 9.50;
      specparam hold_SEL_CK = 0.00;
      specparam setup_TD_CK = 9.50;
      specparam hold_TD_CK = 0.00;
      $setuphold(posedge CK &&& SB, posedge D &&& ~SEL, 10.13:10.13:10.13, -4.31:-4.31:-4.31, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& SB, negedge D &&& ~SEL, 8.40:8.40:8.40, -3.07:-3.07:-3.07, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& SB, posedge SEL, 26.41:26.41:26.41, -7.26:-7.26:-7.26, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK &&& SB, negedge SEL, 14.82:14.82:14.82, -3.81:-3.81:-3.81, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK &&& SB, posedge TD &&& SEL, 14.57:14.57:14.57, -8.00:-8.00:-8.00, flag,,,d_CK, d_TD);
      $setuphold(posedge CK &&& SB, negedge TD &&& SEL, 26.90:26.90:26.90, -13.68:-13.68:-13.68, flag,,,d_CK, d_TD);

      //  Recovery Time
      specparam recovery_SB_CK = 1.50;
      specparam recovery_CK_SB = 4.00;
      $recrem(posedge SB, posedge CK &&& ~D_flag1, 0.00:0.00:0.00, 2.85:2.85:2.85, flag,,,d_SB,d_CK);

      //  Minimum Pulse Width
      specparam mpw_neg_SB = 10.98;
      specparam mpw_neg_CK = 15.84;
      specparam mpw_pos_CK = 15.14;
      $width(negedge SB, 17.95:17.95:17.95, 0, flag);
      $width(negedge CK, 18.69:18.69:18.69, 0, flag);
      $width(posedge CK, 10.07:10.07:10.07, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
