// Created by ihdl
`timescale 10ps/1ps

`celldefine

module BUFCKEHD(O, I);
   output O;
   input I;

//Function Block
`protect
   buf g1(O, I);

//Specify Block
   specify

      //  Module Path Delay
      (I *> O) = (3.86:3.86:3.86, 3.87:3.87:3.87);
   endspecify
`endprotect
endmodule

`endcelldefine
