// Created by ihdl
`timescale 10ps/1ps

`celldefine

module DBFRSBHHD(Q, QB, D, CKB, RB, SB);
   reg flag; // Notifier flag
   output Q, QB;
   input D, CKB, RB, SB;

   wire d_CKB, d_D;
   wire d_RB, d_SB;

//Function Block
`protect
   buf g3(Q, qt);
   not g1(qb1, qt);
   dffrsb_udp g2(qt,  d_D,  ck,  d_RB,  d_SB,  flag );
   and g4(rb_and_sb, d_RB, d_SB);
   or g5(rs, d_RB, d_SB);
   and g6(QB, qb1, rs);
   not g7(ck,  d_CKB );

//Append pseudo gate for timing violation checking
and (_SB_and_RB_, d_SB, d_RB);
or (_SB_or_RB_, d_SB, d_RB);

//Timing violation checking statement
always @(negedge _SB_or_RB_) if(_SB_or_RB_ === 0)
  $display($time, " ****Warning! Set and Reset of %m are low simultaneously");

//Specify Block
   specify

      //  Module Path Delay
      (negedge CKB *> (Q :1'bx)) = (17.44:17.44:17.44, 16.81:16.81:16.81);
      (negedge CKB *> (QB :1'bx)) = (22.60:22.60:22.60, 23.62:23.62:23.62);
      (negedge RB *> (Q :1'bx)) = (0.00:0.00:0.00, 6.55:6.55:6.55);
      (negedge RB *> (QB :1'bx)) = (12.27:12.27:12.27, 0.00:0.00:0.00);
      (negedge SB *> (Q :1'bx)) = (18.66:18.66:18.66, 0.00:0.00:0.00);
      (negedge SB *> (QB :1'bx)) = (0.00:0.00:0.00, 7.18:7.18:7.18);

      //  Setup and Hold Time
      specparam setup_D_CKB = 6.66;
      specparam hold_D_CKB = 0.00;
      $setuphold(negedge CKB &&& _SB_and_RB_, posedge D, 7.91:7.91:7.91, 1.61:1.61:1.61, flag,,,d_CKB, d_D);
      $setuphold(negedge CKB &&& _SB_and_RB_, negedge D, 11.12:11.12:11.12, -1.10:-1.10:-1.10, flag,,,d_CKB, d_D);

      //  Recovery Time
      specparam recovery_RB_CKB = 3.81;
      specparam recovery_SB_CKB = 11.30;
      specparam recovery_CKB_RB = 8.90;
      specparam recovery_CKB_SB = 0.50;
      $recrem(posedge RB, negedge CKB &&& d_D, 0.00:0.00:0.00, 12.21:12.21:12.21, flag,,,d_RB,d_CKB);
      $recrem(posedge SB, negedge CKB &&& ~d_D, 1.99:1.99:1.99, 1.12:1.12:1.12, flag,,,d_SB,d_CKB);

      //  Minimum Pulse Width
      specparam mpw_neg_RB = 16.47;
      specparam mpw_neg_SB = 16.47;
      specparam mpw_pos_CKB = 12.39;
      specparam mpw_neg_CKB = 12.39;
      $width(negedge RB, 12.04:12.04:12.04, 0, flag);
      $width(negedge SB, 23.86:23.86:23.86, 0, flag);
      $width(posedge CKB, 12.04:12.04:12.04, 0, flag);
      $width(negedge CKB, 18.69:18.69:18.69, 0, flag);
   endspecify
`endprotect
endmodule

`endcelldefine
