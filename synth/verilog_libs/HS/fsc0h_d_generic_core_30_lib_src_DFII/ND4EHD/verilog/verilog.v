// Created by ihdl
`timescale 10ps/1ps

`celldefine

module ND4EHD(O, I1, I2, I3, I4);
   output O;
   input I1, I2, I3, I4;

//Function Block
`protect
   nand g1(O, I1, I2, I3, I4);

//Specify Block
   specify

      //  Module Path Delay
      (I1 *> O) = (9.24:9.24:9.24, 8.48:8.48:8.48);
      (I2 *> O) = (9.80:9.80:9.80, 8.55:8.55:8.55);
      (I3 *> O) = (9.95:9.95:9.95, 9.42:9.42:9.42);
      (I4 *> O) = (10.52:10.52:10.52, 9.49:9.49:9.49);
   endspecify
`endprotect
endmodule

`endcelldefine
