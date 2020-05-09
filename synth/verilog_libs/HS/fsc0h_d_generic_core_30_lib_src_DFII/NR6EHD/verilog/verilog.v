// Created by ihdl
`timescale 10ps/1ps

`celldefine

module NR6EHD(O, I1, I2, I3, I4, I5, I6);
   output O;
   input I1, I2, I3, I4, I5, I6;

//Function Block
`protect
   nor g1(O, I1, I2, I3, I4, I5, I6);

//Specify Block
   specify

      //  Module Path Delay
      (I1 *> O) = (13.15:13.15:13.15, 10.12:10.12:10.12);
      (I2 *> O) = (12.56:12.56:12.56, 9.66:9.66:9.66);
      (I3 *> O) = (10.80:10.80:10.80, 8.85:8.85:8.85);
      (I4 *> O) = (12.43:12.43:12.43, 10.33:10.33:10.33);
      (I5 *> O) = (11.81:11.81:11.81, 9.85:9.85:9.85);
      (I6 *> O) = (10.18:10.18:10.18, 9.08:9.08:9.08);
   endspecify
`endprotect
endmodule

`endcelldefine
