// Created by ihdl
`timescale 10ps/1ps

`celldefine

module ND3CHD(O, I1, I2, I3);
   output O;
   input I1, I2, I3;

//Function Block
`protect
   nand g1(O, I1, I2, I3);

//Specify Block
   specify

      //  Module Path Delay
      (I1 *> O) = (2.84:2.84:2.84, 1.93:1.93:1.93);
      (I2 *> O) = (3.47:3.47:3.47, 2.20:2.20:2.20);
      (I3 *> O) = (4.01:4.01:4.01, 2.36:2.36:2.36);
   endspecify
`endprotect
endmodule

`endcelldefine
