// Created by ihdl
`timescale 10ps/1ps

`celldefine

module ND5HHD(O, I1, I2, I3, I4, I5);
   output O;
   input I1, I2, I3, I4, I5;

//Function Block
`protect
   nand g1(O, I1, I2, I3, I4, I5);

//Specify Block
   specify

      //  Module Path Delay
      (I1 *> O) = (9.01:9.01:9.01, 8.86:8.86:8.86);
      (I2 *> O) = (10.02:10.02:10.02, 9.14:9.14:9.14);
      (I3 *> O) = (10.97:10.97:10.97, 9.29:9.29:9.29);
      (I4 *> O) = (7.56:7.56:7.56, 8.67:8.67:8.67);
      (I5 *> O) = (8.49:8.49:8.49, 8.83:8.83:8.83);
   endspecify
`endprotect
endmodule

`endcelldefine
