`timescale 1fs / 1fs

`include "adpll_defines.vh"

module adpll_ctr_module_tb
  (
   output                     clk32,
   output                     reset,

   // CPU interface
   output                     valid,
   output [`ADPLL_ADDR_W-1:0] address,
   output [`ADPLL_DATA_W-1:0] wdata,
   output                     wstrb,
   input [1:0]                rdata,
   input                      ready,

   output                     data_mod
   );

   reg                        clk;
   reg                        rst;

   // ADPLL CPU interface
   reg                        adpll_valid;
   reg [`ADPLL_ADDR_W-1:0]    adpll_address;
   reg [`ADPLL_DATA_W-1:0]    adpll_wdata;
   reg                        adpll_wstrb;
   wire [1:0]                 adpll_rdata;
   wire                       adpll_ready;

   reg                        adpll_data_mod;
   reg [1:0]                  rcv_adpll_word;
`include "adpll_tasks.v"

   localparam real            end_time_fs = `SIM_TIME * 1E9;
   reg [4:0]                  time_count;
   reg [`FCWW-1:0]            adpll_fcw;  // word in MHz
   reg                        channel_lock;

   assign clk32    = clk;
   assign reset    = rst;

   assign valid    = adpll_valid;
   assign address  = adpll_address;
   assign wdata    = adpll_wdata;
   assign wstrb    = adpll_wstrb;
   assign adpll_rdata = rdata;
   assign adpll_ready = ready;

   assign data_mod = adpll_data_mod;

   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   //32 MHz clock
   always #15625000 clk = ~clk;

   initial begin
      //$dumpfile("dump.vcd");
      //$dumpvars;
	  adpll_fcw = int'(`FREQ_CHANNEL*16384);
	  $display("freq_channel = %f MHz, adpll_mode = %1d", `FREQ_CHANNEL , `ADPLL_OPERATION);

      // init
      rst = 1;
      clk = 0;
	  
	  // tx data counter
	  time_count = 0; 
	  
      // init ADPLL cpu bus signals
      adpll_valid = 0;
      adpll_wstrb = 0;
	  adpll_data_mod = 0;

      channel_lock = 0;

      // deassert rst
      repeat (100) @(posedge clk);
      rst <= 0;

      //wait an arbitray (10) number of cycles
      repeat (10) @(posedge clk) #1;

      // configure ADPLL
      //adpll_config(adpll_fcw,`ADPLL_OPERATION);
	  adpll_write(`FCW, adpll_fcw);
      adpll_write(`ADPLL_MODE, `ADPLL_OPERATION);

      // enable ADPLL
      adpll_write(`ADPLL_EN, 1);

      // check if ADPLL is lock
      do begin
         adpll_read(`ADPLL_LOCK,rcv_adpll_word);
      end while(rcv_adpll_word != 1);
      channel_lock = 1;

   end

   // Serial input
   //wire                     data_mod = tx;

   // TX data generation
   always @(posedge clk)
     if (channel_lock  && `ADPLL_OPERATION == `TX) begin
	    time_count <= time_count + 1;
	    if (time_count == 5'd31)
	      adpll_data_mod <= $urandom%2;
     end

   initial #end_time_fs begin 		
	  $finish;
   end
 
   always #(end_time_fs /10) $write("Loading progress: %d percent \n", 
				                    int'(100 * $time  / end_time_fs));
endmodule
