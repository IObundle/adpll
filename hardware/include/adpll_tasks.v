   //
   // ADPLL TASKS
   //

   // 1-cycle write
   task adpll_write;
      input [`ADPLL_ADDR_W-1:0] adpllAddress;
      input [`ADPLL_DATA_W-1:0] adpllDataIn;

      # 1 adpll_address = adpllAddress;
      adpll_valid = 1;
      adpll_wstrb = 1;
      adpll_wdata = adpllDataIn;
      @ (posedge clk) #1 adpll_wstrb = 0;
      adpll_valid = 0;
   endtask //adpll_write

   // 2-cycle read
   task adpll_read;
      input [`ADPLL_ADDR_W-1:0] adpllAddress;
      output [1:0]              adpllDataOut;

      # 1 adpll_address = adpllAddress;
      adpll_valid = 1;
      @ (posedge clk) #1 adpllDataOut = adpll_rdata;
      @ (posedge clk) #1 adpll_valid = 0;
   endtask //adpll_read

   task adpll_config;
      input [`FCWW-1:0] adpll_fcw; //in MHz
	  input [1:0] adpll_mode;


      adpll_write(`FCW, adpll_fcw);
      adpll_write(`ADPLL_MODE, adpll_mode);
      /* adpll_write(`ALPHA_L, 14);
      adpll_write(`ALPHA_M, 8);
      adpll_write(`ALPHA_S_RX, 7);
      adpll_write(`ALPHA_S_TX, 4);
      adpll_write(`BETA, 0);
      adpll_write(`LAMBDA_RX, 2);
      adpll_write(`LAMBDA_TX, 2);
      adpll_write(`IIR_N_RX, 3);
      adpll_write(`IIR_N_TX, 2);
      adpll_write(`FCW_MOD, `ADPLL_DATA_W'b01001);
      adpll_write(`DCO_C_L_WORD_TEST, 0);
      adpll_write(`DCO_C_M_WORD_TEST, 0);
      adpll_write(`DCO_C_S_WORD_TEST, 0);
      adpll_write(`DCO_PD_TEST, 1);
      adpll_write(`TDC_PD_TEST, 1);
      adpll_write(`TDC_PD_INJ_TEST, 1);
      adpll_write(`TDC_CTR_FREQ, `ADPLL_DATA_W'b100);
      adpll_write(`DCO_OSC_GAIN, `ADPLL_DATA_W'b10); */
   endtask // adpll_config

   task adpll_on;
      adpll_write(`ADPLL_SOFT_RST, 1);
      adpll_write(`ADPLL_SOFT_RST, 0);
      adpll_write(`ADPLL_EN, 1);
   endtask

   task adpll_off;
      adpll_write(`ADPLL_MODE, `PD);
      adpll_write(`ADPLL_EN, 0);
   endtask
