// Created by ihdl
`timescale 10ps/1ps

`celldefine

module AOI112HHD(O, A1, B1, C1, C2);
   output O;
   input A1, B1, C1, C2;

//Function Block
`protect
   and g1(o1, C1, C2);
   nor g2(O, A1, B1, o1);

//Specify Block
   specify

      //  Module Path Delay (state dependent)
      if (C1 == 1 && C2 == 0) (B1 *> O) = (12.29:12.29:12.29, 7.95:7.95:7.95);
      if (C1 == 0 && C2 == 1) (B1 *> O) = (11.14:11.14:11.14, 7.57:7.57:7.57);
      if (C1 == 0 && C2 == 0) (B1 *> O) = (9.83:9.83:9.83, 7.56:7.56:7.56);
      ifnone (B1 *> O) = (9.83:9.83:9.83, 7.56:7.56:7.56);
      if (C1 == 0 && C2 == 0) (A1 *> O) = (8.63:8.63:8.63, 6.84:6.84:6.84);
      if (C1 == 1 && C2 == 0) (A1 *> O) = (10.58:10.58:10.58, 7.20:7.20:7.20);
      if (C1 == 0 && C2 == 1) (A1 *> O) = (9.41:9.41:9.41, 6.84:6.84:6.84);
      ifnone (A1 *> O) = (9.41:9.41:9.41, 6.84:6.84:6.84);

      //  Module Path Delay
      (C1 *> O) = (12.65:12.65:12.65, 7.53:7.53:7.53);
      (C2 *> O) = (13.66:13.66:13.66, 7.60:7.60:7.60);
   endspecify
`endprotect
endmodule

`endcelldefine
