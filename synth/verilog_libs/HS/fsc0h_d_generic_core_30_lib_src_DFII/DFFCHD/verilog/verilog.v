// Created by ihdl
`timescale 10ps/1ps

`celldefine

module DFFCHD(Q, QB, D, CK);
   reg flag; // Notifier flag
   output Q, QB;
   input D, CK;
   supply1 vcc;

   wire d_CK, d_D;

//Function Block
`protect
   buf g3(Q, qt);
   not g1(QB, qt);
   dffrsb_udp g2(qt,  d_D,  d_CK,  vcc,  vcc,  flag );

//Specify Block
   specify

      //  Module Path Delay
      (posedge CK *> (Q :1'bx)) = (12.36:12.36:12.36, 12.94:12.94:12.94);
      (posedge CK *> (QB :1'bx)) = (17.96:17.96:17.96, 17.70:17.70:17.70);

      //  Setup and Hold Time
      specparam setup_D_CK = 9.10;
      specparam hold_D_CK = 0.00;
      $setuphold(posedge CK, posedge D, 5.82:5.82:5.82, -2.09:-2.09:-2.09, flag,,,d_CK, d_D);
      $setuphold(posedge CK, negedge D, 6.92:6.92:6.92, -1.84:-1.84:-1.84, flag,,,d_CK, d_D);

      //  Minimum Pulse Width
      specparam mpw_neg_CK = 13.86;
      specparam mpw_pos_CK = 12.21;
      $width(negedge CK, 16.47:16.47:16.47, 0, flag);
      $width(posedge CK, 8.10:8.10:8.10, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
