// Created by ihdl
`timescale 10ps/1ps

`celldefine

module QDFZRBEHD(Q, D, TD, CK, SEL, RB);
   reg flag; // Notifier flag
   output Q;
   input D, CK, TD, RB, SEL;
   supply1 vcc;
   reg D_flag;
   wire D_flag1;
   wire d_CK, d_D, d_SEL, d_TD;
   wire d_RB;

//Function Block
`protect
   buf b3 (SEL_, d_SEL );  //Avoid MIPD.

   buf g3(Q, qt);
   dffrsb_udp g2(qt,  d1,  d_CK,  d_RB,  vcc,  flag );
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
      (posedge CK *> (Q :1'bx)) = (12.52:12.52:12.52, 12.20:12.20:12.20);
      (negedge RB *> (Q :1'bx)) = (0.00:0.00:0.00, 5.09:5.09:5.09);

      //  Setup and Hold Time
      specparam setup_D_CK = 6.30;
      specparam hold_D_CK = 0.00;
      specparam setup_SEL_CK = 8.40;
      specparam hold_SEL_CK = 0.00;
      specparam setup_TD_CK = 8.40;
      specparam hold_TD_CK = 0.00;
      $setuphold(posedge CK &&& RB, posedge D &&& ~SEL, 7.91:7.91:7.91, -4.80:-4.80:-4.80, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& RB, negedge D &&& ~SEL, 8.90:8.90:8.90, -4.06:-4.06:-4.06, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& RB, posedge SEL, 28.62:28.62:28.62, -8.00:-8.00:-8.00, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK &&& RB, negedge SEL, 12.60:12.60:12.60, -4.55:-4.55:-4.55, flag,,,d_CK, d_SEL);
      $setuphold(posedge CK &&& RB, posedge TD &&& SEL, 12.35:12.35:12.35, -8.50:-8.50:-8.50, flag,,,d_CK, d_TD);
      $setuphold(posedge CK &&& RB, negedge TD &&& SEL, 29.36:29.36:29.36, -11.12:-11.12:-11.12, flag,,,d_CK, d_TD);

      //  Recovery Time
      specparam recovery_RB_CK = 4.30;
      specparam recovery_CK_RB = 8.90;
      $recrem(posedge RB, posedge CK &&& D_flag1, 0.00:0.00:0.00, 8.27:8.27:8.27, flag,,,d_RB,d_CK);

      //  Minimum Pulse Width
      specparam mpw_neg_RB = 3.87;
      specparam mpw_neg_CK = 14.46;
      specparam mpw_pos_CK = 13.61;
      $width(negedge RB, 10.07:10.07:10.07, 0, flag);
      $width(negedge CK, 19.92:19.92:19.92, 0, flag);
      $width(posedge CK, 8.59:8.59:8.59, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
