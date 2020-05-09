// Created by ihdl
`timescale 10ps/1ps

`celldefine

module AOI13KHD(O, A1, B1, B2, B3);
   output O;
   input A1, B1, B2, B3;

//Function Block
`protect
   and g1(o1, B1, B2, B3);
   nor g2(O, A1, o1);

//Specify Block
   specify

      //  Module Path Delay (state dependent)
      if (B1 == 1 && B2 == 0 && B3 == 0) (A1 *> O) = (9.19:9.19:9.19, 8.13:8.13:8.13);
      if (B1 == 0 && B2 == 1 && B3 == 0) (A1 *> O) = (8.16:8.16:8.16, 7.65:7.65:7.65);
      if (B1 == 0 && B2 == 0 && B3 == 1) (A1 *> O) = (8.16:8.16:8.16, 7.65:7.65:7.65);
      if (B1 == 1 && B2 == 1 && B3 == 0) (A1 *> O) = (11.57:11.57:11.57, 8.48:8.48:8.48);
      if (B1 == 1 && B2 == 0 && B3 == 1) (A1 *> O) = (10.46:10.46:10.46, 8.13:8.13:8.13);
      if (B1 == 0 && B2 == 1 && B3 == 1) (A1 *> O) = (9.14:9.14:9.14, 7.65:7.65:7.65);
      if (B1 == 0 && B2 == 0 && B3 == 0) (A1 *> O) = (7.81:7.81:7.81, 7.64:7.64:7.64);
      ifnone (A1 *> O) = (7.81:7.81:7.81, 7.64:7.64:7.64);

      //  Module Path Delay
      (B1 *> O) = (11.16:11.16:11.16, 8.84:8.84:8.84);
      (B2 *> O) = (12.41:12.41:12.41, 9.14:9.14:9.14);
      (B3 *> O) = (13.40:13.40:13.40, 9.25:9.25:9.25);
   endspecify
`endprotect
endmodule

`endcelldefine
