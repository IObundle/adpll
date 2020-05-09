// Created by ihdl
`timescale 10ps/1ps

`celldefine

module DLAHCHD(Q, QB, D, G);
   reg flag; // Notifier flag
   output Q, QB;
   input D, G;
   supply1 vcc;

   wire d_G, d_D;

//Function Block
`protect
   buf g3(Q, qt);
   not g1(QB, qt);
   dlhrb_udp g2(qt,  d_D,  d_G,  vcc,  flag );

//Specify Block
   specify

      //  Module Path Delay
      (posedge G *> (Q :1'bx)) = (10.84:10.84:10.84, 10.26:10.26:10.26);
      (posedge G *> (QB :1'bx)) = (15.35:15.35:15.35, 15.30:15.30:15.30);
      (D *> Q) = (6.64:6.64:6.64, 7.41:7.41:7.41);
      (D *> QB) = (12.51:12.51:12.51, 11.09:11.09:11.09);

      //  Setup and Hold Time
      specparam setup_D_G = 28.88;
      specparam hold_D_G = 8.13;
      $setuphold(negedge G, posedge D, 3.87:3.87:3.87, 0.23:0.23:0.23, flag,,,d_G, d_D);
      $setuphold(negedge G, negedge D, 6.33:6.33:6.33, -2.48:-2.48:-2.48, flag,,,d_G, d_D);

      //  Minimum Pulse Width
      specparam mpw_pos_G = 42.82;
      $width(posedge G, 10.56:10.56:10.56, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
