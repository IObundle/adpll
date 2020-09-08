ADPLL_OPERATION = 2 # PD = 0, TEST = 1, RX = 2, TX = 3
FREQ_CHANNEL = 2433.500 # Channel freq in MHz
SIM_TIME = 100 # simulation time in us
DCO_PN = 1 # dco phase noise flag
INIT_TIME_RM = 25 # initial transient time to remove in us (display purposes)
DEFINE = -DFREQ_CHANNEL=$(FREQ_CHANNEL) -DSIM_TIME=$(SIM_TIME) -DDCO_PN=$(DCO_PN) -DADPLL_OPERATION=$(ADPLL_OPERATION)

ROOT_DIR = .
HW_DIR = $(ROOT_DIR)/hardware
INC_DIR = $(HW_DIR)/include
SRC_DIR = $(HW_DIR)/src
TB_DIR = $(HW_DIR)/testbench
SYNTH_DIR = $(HW_DIR)/synth
PY_DIR = $(ROOT_DIR)/software/python

SRC = \
	$(SRC_DIR)/row_col_cod.v \
	$(SRC_DIR)/row_col_cod_reg.v \
	$(SRC_DIR)/row_col_cod_5x5.v \
	$(SRC_DIR)/tdc_digital.v

TB_SRC = \
	$(TB_DIR)/TDC/ring_osc.sv \
	$(TB_DIR)/TDC/ring_inv.sv \
	$(TB_DIR)/TDC/d_ff1.sv \
	$(TB_DIR)/TDC/d_ff2.sv \
	$(TB_DIR)/TDC/d_latch1.sv \
	$(TB_DIR)/TDC/counter.sv \
	$(TB_DIR)/TDC/tdc_analog.sv \
	$(TB_DIR)/DCO/dco.sv \
	$(TB_DIR)/DCO/c_sel.sv 

#Icarus 
CC = iverilog
CFLAGS = -Wall -g2005-sv -I$(INC_DIR)/

#Xcelium
XCFLAGS = -errormax 15 -status -update -linedebug -SV -DEFINE FREQ_CHANNEL=$(FREQ_CHANNEL) -DEFINE SIM_TIME=$(SIM_TIME) -DEFINE ADPLL_OPERATION=$(ADPLL_OPERATION) -DEFINE DCO_PN=$(DCO_PN) -incdir $(ROOT_DIR)/
XEFLAGS = -errormax 15 -access +wc -status
XSFLAGS = -errormax 15 -status

icarus_adpll_ctr0_tb:
	$(CC) $(CFLAGS) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.sv
	./a.out
	make plots_adpll_ctr0_tb

xcelium_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.sv
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_synth_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_synth.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(SRC_DIR)/adpll_ctr0_tb.sv
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_pr_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_PR.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(SRC_DIR)/adpll_ctr0_tb.sv
	xmelab $(XEFLAGS) -sdf_cmd_file $(SYNTH_DIR)/adpll_ctr0_WC_AN_PR.sdf adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb


plots_adpll_ctr0_tb:
	if [ $(ADPLL_OPERATION) -eq 2 ]; then python3 $(PY_DIR)/rx_calc.py $(INIT_TIME_RM); fi;
	if [ $(ADPLL_OPERATION) -eq 3 ]; then python3 $(PY_DIR)/tx_calc.py $(INIT_TIME_RM) $(FREQ_CHANNEL); fi;

clean_xcelium:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.log
	@rm -rf xcelium.d
clean:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.txt

.PHONY: icarus_adpll_ctr0_tb xcelium_adpll_ctr0_tb xcelium_synth_adpll_ctr0_tb xcelium_pr_adpll_ctr0_tb plots_adpll_ctr0_tb clean_xcelium clean

