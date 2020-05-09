// Created by ihdl
`timescale 10ps/1ps

`celldefine

module NR2GHD(O, I1, I2);
   output O;
   input I1, I2;

//Function Block
`protect
   nor g1(O, I1, I2);

//Specify Block
   specify

      //  Module Path Delay
      (I1 *> O) = (2.93:2.93:2.93, 1.69:1.69:1.69);
      (I2 *> O) = (2.16:2.16:2.16, 1.32:1.32:1.32);
   endspecify
`endprotect
endmodule

`endcelldefine
