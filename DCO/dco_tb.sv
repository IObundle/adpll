`timescale 1fs / 1fs



///////////////////////////////////////////////////////////////////////////////
// Date: 19/01/2019
// Module: dco_tb.v
// Project: WSN (preparation)
// Description: 
//				 
// Change history: 12/12/19 - 

module dco_tb;

   reg en;
   wire ckv;
   longint mat_pdev;

   wire [4:0] c_l_r_all, c_l_row, c_l_col;
   wire [15:0] c_m_r_all, c_m_row, c_m_col;
   wire [15:0] c_s_r_all, c_s_row, c_s_col;
   reg [7:0] c_s_word, c_m_word;
   reg [4:0] c_l_word; 
   reg 	       clk, rst;
   
   // instantiate row_col_coder of Large c bank
   row_col_cod_5x5 row_col_cod_l(
			    //Inputs
			    .rst(rst),
			    .en(en),
			    .clk(clk),
			    .word(c_l_word),
			    //Outputs
			    .r_all(c_l_r_all),
			    .row(c_l_row),
			    .col(c_l_col)
			    );
   // instantiate row_col_coder of medium c bank
   row_col_cod row_col_cod_m(
			    //Inputs
			    .rst(rst),
			    .en(en),
			    .clk(clk),
			    .word(c_m_word),
			    //Outputs
			    .r_all(c_m_r_all),
			    .row(c_m_row),
			    .col(c_m_col)
			    );
   // instantiate row_col_coder of small c bank
   row_col_cod row_col_cod_s(
			    //Inputs
			    .rst(rst),
			    .en(en),
			    .clk(clk),
			    .word(c_s_word),
			    //Outputs
			    .r_all(c_s_r_all),
			    .row(c_s_row),
			    .col(c_s_col)
			    );
   
   
   // instantiate dco module
   dco dco0(
	   // Inputs
	   .en (en),
	   .c_l_r_all(c_l_r_all),
	   .c_l_row(c_l_row),
	   .c_l_col(c_l_col),
	   .c_m_r_all(c_m_r_all),
	   .c_m_row(c_m_row),
	   .c_m_col(c_m_col),
	   .c_s_r_all(c_s_r_all),
	   .c_s_row(c_s_row),
	   .c_s_col(c_s_col),
	   // Outputs
	   .ckv	(ckv)
	   );

   integer	  fp1;

   always #15625000 clk = ~clk;
   
   initial fp1 = $fopen("dco_ckv_time.txt","w");
   always @ (dco0.smp) $fwrite(fp1, "%0d ", $time);

   parameter real end_time_fs = 100E9;
   
   always #(end_time_fs /10) $write("Loading progress: %d percent \n", int'(100 * $time  / end_time_fs));

   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;

      clk = 0;
      rst = 0;
      en = 1;

      c_l_word = 8'd28;
      
      //c_l_r_all = 5'b11111;
      //c_l_row = 5'b1;
      //c_l_col = 5'b1;

      c_m_word = 8'd255;
      
      //c_m_r_all = 16'b0111111111111111;
      //c_m_row = 16'b1000000000000000;
      //c_m_col = 16'b1111111111111111;

      c_s_word = 8'd127;
      

      //c_s_r_all = 16'b0111111111111111;
      //c_s_row = 16'b1000000000000000;
      //c_s_col = 16'b1111111111111111;

      
      
      #1E9 rst = 1;
      #1E9 rst = 0;
 
      #2E9 c_s_word = 8'd50;
      //$display(" %e",SIGMA_WANDER);  
   end // initial begin


   initial       #end_time_fs $finish; 
endmodule
