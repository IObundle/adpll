// Created by ihdl
`timescale 10ps/1ps

`celldefine

module AN2EHD(O, I1, I2);
   output O;
   input I1, I2;

//Function Block
`protect
   and g1(O, I1,I2);

//Specify Block
   specify

      //  Module Path Delay
      (I1 *> O) = (4.36:4.36:4.36, 5.45:5.45:5.45);
      (I2 *> O) = (4.44:4.44:4.44, 6.03:6.03:6.03);
   endspecify
`endprotect
endmodule

`endcelldefine
