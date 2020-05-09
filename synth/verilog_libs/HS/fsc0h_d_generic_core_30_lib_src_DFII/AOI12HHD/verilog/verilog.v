// Created by ihdl
`timescale 10ps/1ps

`celldefine

module AOI12HHD(O, A1, B1, B2);
   output O;
   input A1, B1, B2;

//Function Block
`protect
   and g1(o1, B1, B2);
   nor g2(O, A1, o1);

//Specify Block
   specify

      //  Module Path Delay (state dependent)
      if (B1 == 0 && B2 == 0) (A1 *> O) = (8.34:8.34:8.34, 7.39:7.39:7.39);
      if (B1 == 1 && B2 == 0) (A1 *> O) = (10.39:10.39:10.39, 7.45:7.45:7.45);
      if (B1 == 0 && B2 == 1) (A1 *> O) = (9.38:9.38:9.38, 7.06:7.06:7.06);
      ifnone (A1 *> O) = (9.38:9.38:9.38, 7.06:7.06:7.06);

      //  Module Path Delay
      (B1 *> O) = (8.17:8.17:8.17, 5.94:5.94:5.94);
      (B2 *> O) = (9.06:9.06:9.06, 6.02:6.02:6.02);
   endspecify
`endprotect
endmodule

`endcelldefine
