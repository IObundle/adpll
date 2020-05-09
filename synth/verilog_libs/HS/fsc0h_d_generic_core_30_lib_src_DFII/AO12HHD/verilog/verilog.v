// Created by ihdl
`timescale 10ps/1ps

`celldefine

module AO12HHD(O, A1, B1, B2);
   output O;
   input A1, B1, B2;

//Function Block
`protect
   and g1(o1, B1, B2);
   nor g2(o2, A1, o1);
   not g3(O, o2);

//Specify Block
   specify

      //  Module Path Delay (state dependent)
      if (B1 == 0 && B2 == 0) (A1 *> O) = (5.45:5.45:5.45, 6.77:6.77:6.77);
      if (B1 == 1 && B2 == 0) (A1 *> O) = (5.43:5.43:5.43, 8.93:8.93:8.93);
      if (B1 == 0 && B2 == 1) (A1 *> O) = (5.15:5.15:5.15, 8.04:8.04:8.04);
      ifnone (A1 *> O) = (5.15:5.15:5.15, 8.04:8.04:8.04);

      //  Module Path Delay
      (B1 *> O) = (4.21:4.21:4.21, 6.85:6.85:6.85);
      (B2 *> O) = (4.28:4.28:4.28, 7.60:7.60:7.60);
   endspecify
`endprotect
endmodule

`endcelldefine
