// Created by ihdl
`timescale 10ps/1ps

`celldefine

module OAI112EHD(O, A1, B1, C1, C2);
   output O;
   input A1, B1, C1, C2;

//Function Block
`protect
   or g1(o1, C1, C2);
   nand g2(O, A1, B1, o1);

//Specify Block
   specify

      //  Module Path Delay (state dependent)
      if (C1 == 1 && C2 == 1) (A1 *> O) = (8.56:8.56:8.56, 7.27:7.27:7.27);
      if (C1 == 1 && C2 == 0) (A1 *> O) = (8.58:8.58:8.58, 7.74:7.74:7.74);
      if (C1 == 0 && C2 == 1) (A1 *> O) = (9.25:9.25:9.25, 8.66:8.66:8.66);
      ifnone (A1 *> O) = (9.25:9.25:9.25, 8.66:8.66:8.66);
      if (C1 == 1 && C2 == 0) (B1 *> O) = (9.29:9.29:9.29, 8.00:8.00:8.00);
      if (C1 == 0 && C2 == 1) (B1 *> O) = (9.96:9.96:9.96, 8.91:8.91:8.91);
      if (C1 == 1 && C2 == 1) (B1 *> O) = (9.25:9.25:9.25, 7.43:7.43:7.43);
      ifnone (B1 *> O) = (9.25:9.25:9.25, 7.43:7.43:7.43);

      //  Module Path Delay
      (C2 *> O) = (11.01:11.01:11.01, 9.47:9.47:9.47);
      (C1 *> O) = (10.37:10.37:10.37, 8.66:8.66:8.66);
   endspecify
`endprotect
endmodule

`endcelldefine
