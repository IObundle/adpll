// Created by ihdl
`timescale 10ps/1ps

`celldefine

module DFERSBHHD(Q, QB, D, CK, EB, RB, SB);

  output Q, QB;
  input D, CK, EB, RB, SB;
  reg flag; // Notifier flag
  supply1 vcc;
  reg flag_two1;
  wire d_CK, d_D, d_EB, D_flag;
  wire d_RB, d_SB;

//Function Block
`protect
  buf b1 (D_, d_D );      //Avoid MIPD.
  buf b2 (EB_, d_EB );      //Avoid MIPD.
  mux2_udp g1(qt_i,  D_,  qt,  d_EB );
  dffrsb_udp g2(qt,  qt_i,  d_CK,  d_RB,  d_SB,  flag );  
  buf g3(Q, qt);
  not g4(qb1, qt);
  or g5(rs, d_RB, d_SB);
  and g6(QB, qb1, rs);

//Append pseudo gate for timing violation checking
  and (_SB_and_RB_, d_SB, d_RB);
  or (_SB_or_RB_, d_SB, d_RB);
  assign D_flag   = flag_two1;    // For Model-Tec complier
  always @(EB_ or D_ or qt)
    begin
      if (EB_ === 1'b0)
           flag_two1 = D_;
      else
           flag_two1 = qt;
    end

//Timing violation checking statement
always @(negedge _SB_or_RB_) if(_SB_or_RB_ === 0)
  $display($time, " ****Warning! Set and Reset of %m are low simultaneously");

//Specify Block
   specify

      //  Module Path Delay
      (posedge CK *> (Q :1'bx)) = (15.95:15.95:15.95, 16.63:16.63:16.63);
      (posedge CK *> (QB :1'bx)) = (23.19:23.19:23.19, 23.13:23.13:23.13);
      (negedge RB *> (Q :1'bx)) = (0.00:0.00:0.00, 6.63:6.63:6.63);
      (negedge RB *> (QB :1'bx)) = (13.13:13.13:13.13, 0.00:0.00:0.00);
      (negedge SB *> (Q :1'bx)) = (19.05:19.05:19.05, 0.00:0.00:0.00);
      (negedge SB *> (QB :1'bx)) = (0.00:0.00:0.00, 8.18:8.18:8.18);

      //  Setup and Hold Time
      specparam setup_D_CK = 33.05;
      specparam hold_D_CK = 4.97;
      specparam setup_EB_CK = 34.40;
      specparam hold_EB_CK = 9.62;
      $setuphold(posedge CK &&& _SB_and_RB_, posedge D &&& ~EB, 12.35:12.35:12.35, -2.83:-2.83:-2.83, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& _SB_and_RB_, negedge D &&& ~EB, 16.05:16.05:16.05, -4.31:-4.31:-4.31, flag,,,d_CK, d_D);
      $setuphold(posedge CK &&& _SB_and_RB_, posedge EB, 9.88:9.88:9.88, -3.07:-3.07:-3.07, flag,,,d_CK, d_EB);
      $setuphold(posedge CK &&& _SB_and_RB_, negedge EB, 16.54:16.54:16.54, -8.90:-8.90:-8.90, flag,,,d_CK, d_EB);

      //  Recovery Time
      specparam recovery_RB_CK = 11.71;
      specparam recovery_SB_CK = 16.24;
      specparam recovery_CK_RB = 33.62;
      specparam recovery_CK_SB = 33.62;
      $recrem(posedge RB, posedge CK &&& D_flag, 0.00:0.00:0.00, 6.79:6.79:6.79, flag,,,d_RB,d_CK);
      $recrem(posedge SB, posedge CK &&& ~D_flag, 2.73:2.73:2.73, 0.13:0.13:0.13, flag,,,d_SB,d_CK);

      //  Minimum Pulse Width
      specparam mpw_neg_RB = 64.75;
      specparam mpw_neg_SB = 66.19;
      specparam mpw_pos_CK = 67.31;
      specparam mpw_neg_CK = 67.05;
      $width(negedge RB, 12.04:12.04:12.04, 0, flag);
      $width(negedge SB, 23.86:23.86:23.86, 0, flag);
      $width(posedge CK, 12.90:12.90:12.90, 0, flag);
      $width(negedge CK, 19.92:19.92:19.92, 0, flag);
   endspecify
`endprotect

endmodule

`endcelldefine
