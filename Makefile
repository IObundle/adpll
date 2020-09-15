ROOT_DIR = .
HW_DIR = $(ROOT_DIR)/hardware
INC_DIR = $(HW_DIR)/include
SRC_DIR = $(HW_DIR)/src
TB_DIR = $(HW_DIR)/testbench
SYNTH_DIR = $(HW_DIR)/synth
SW_DIR = $(ROOT_DIR)/software
PY_DIR = $(SW_DIR)/python

defmacro:=-D

include $(ROOT_DIR)/adpll.mk

INCLUDE=-I$(INC_DIR)
INCLUDE2=-incdir$(ROOT_DIR)

DEFINE2=-DEFINE FREQ_CHANNEL=$(FREQ_CHANNEL) -DEFINE SIM_TIME=$(SIM_TIME) -DEFINE ADPLL_OPERATION=$(ADPLL_OPERATION) -DEFINE DCO_PN=$(DCO_PN)

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
CFLAGS = -Wall -g2005-sv

#Xcelium
XCFLAGS = -errormax 15 -status -update -linedebug -SV
XEFLAGS = -errormax 15 -access +wc -status
XSFLAGS = -errormax 15 -status

ifeq ($(MAKECMDGOALS),)
TRGT=icarus_adpll_ctr0_tb
else
TRGT=$(MAKECMDGOALS)
endif

run: $(TRGT) self-checker

icarus_adpll_ctr0_tb:
	$(CC) $(CFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.v
	./a.out

xcelium_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_synth_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_synth.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(SRC_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_pr_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_PR.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(SRC_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) -sdf_cmd_file $(SYNTH_DIR)/adpll_ctr0_WC_AN_PR.sdf adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

plots_adpll_ctr0_tb:
	cp $(SW_DIR)/*.txt .
	if [ $(ADPLL_OPERATION) -eq 2 ]; then python3 $(PY_DIR)/rx_calc.py $(INIT_TIME_RM); fi;
	if [ $(ADPLL_OPERATION) -eq 3 ]; then python3 $(PY_DIR)/tx_calc.py $(INIT_TIME_RM) $(FREQ_CHANNEL); fi;

self-checker:
	python3 $(PY_DIR)/self-checker.py $(INIT_TIME_RM) $(FREQ_CHANNEL)

clean_xcelium:
	@rm -rf xcelium.d
clean: clean_xcelium
	@rm -f  *~ *.vcd \#*\# a.out params.m *.hex *.txt *.log

.PHONY: icarus_adpll_ctr0_tb \
        xcelium_adpll_ctr0_tb \
        xcelium_synth_adpll_ctr0_tb \
        xcelium_pr_adpll_ctr0_tb \
        plots_adpll_ctr0_tb \
        self-checker \
        clean_xcelium clean

