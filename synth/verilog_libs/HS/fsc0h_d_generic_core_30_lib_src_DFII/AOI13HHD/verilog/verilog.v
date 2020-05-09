// Created by ihdl
`timescale 10ps/1ps

`celldefine

module AOI13HHD(O, A1, B1, B2, B3);
   output O;
   input A1, B1, B2, B3;

//Function Block
`protect
   and g1(o1, B1, B2, B3);
   nor g2(O, A1, o1);

//Specify Block
   specify

      //  Module Path Delay (state dependent)
      if (B1 == 1 && B2 == 0 && B3 == 0) (A1 *> O) = (8.17:8.17:8.17, 6.70:6.70:6.70);
      if (B1 == 0 && B2 == 1 && B3 == 0) (A1 *> O) = (7.17:7.17:7.17, 6.24:6.24:6.24);
      if (B1 == 0 && B2 == 0 && B3 == 1) (A1 *> O) = (7.17:7.17:7.17, 6.24:6.24:6.24);
      if (B1 == 1 && B2 == 1 && B3 == 0) (A1 *> O) = (10.41:10.41:10.41, 6.99:6.99:6.99);
      if (B1 == 1 && B2 == 0 && B3 == 1) (A1 *> O) = (9.34:9.34:9.34, 6.69:6.69:6.69);
      if (B1 == 0 && B2 == 1 && B3 == 1) (A1 *> O) = (8.06:8.06:8.06, 6.24:6.24:6.24);
      if (B1 == 0 && B2 == 0 && B3 == 0) (A1 *> O) = (6.85:6.85:6.85, 6.23:6.23:6.23);
      ifnone (A1 *> O) = (6.85:6.85:6.85, 6.23:6.23:6.23);

      //  Module Path Delay
      (B1 *> O) = (10.08:10.08:10.08, 7.31:7.31:7.31);
      (B2 *> O) = (11.29:11.29:11.29, 7.61:7.61:7.61);
      (B3 *> O) = (12.24:12.24:12.24, 7.73:7.73:7.73);
   endspecify
`endprotect
endmodule

`endcelldefine
