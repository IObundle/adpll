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

INCLUDE=-I $(INC_DIR)
INCLUDE2=-incdir $(INC_DIR)

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

ifeq ($(SIM),)
SIM=icarus
endif

all: usage

usage:
	@echo "Usage: make target [parameters]"
	@echo "       For example, \"make run SIM=icarus\""

run: $(SIM) self-checker

run_cpu: $(SIM) self-checker-cpu

icarus_ctr0:
	$(CC) $(CFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.v
	./a.out

icarus_ctr:
	$(CC) $(CFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(SRC_DIR)/adpll_ctr.v $(TB_DIR)/module_tb.sv $(TB_DIR)/adpll_ctr_tb.v
	./a.out

xcelium:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_synth:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_synth.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_pr:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_PR.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) -sdf_cmd_file $(SYNTH_DIR)/adpll_ctr0_WC_AN_PR.sdf adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

cpu_synth:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_synth.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/adpll_cpu_tb.v
	xmelab $(XEFLAGS) adpll_cpu_tb
	xmsim $(XSFLAGS) adpll_cpu_tb

cpu_pr:
	xmvlog $(XCFLAGS) $(INCLUDE2) $(DEFINE2) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_PR.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/adpll_cpu_tb.v
	xmelab $(XEFLAGS) -sdf_cmd_file $(SYNTH_DIR)/adpll_ctr0_WC_AN_PR.sdf adpll_cpu_tb
	xmsim $(XSFLAGS) adpll_cpu_tb

plots_adpll:
	if [ $(ADPLL_OPERATION) -eq $(RX) ]; then python3 $(PY_DIR)/rx_calc.py $(INIT_TIME_RM); fi;
	if [ $(ADPLL_OPERATION) -eq $(TX) ]; then python3 $(PY_DIR)/tx_calc.py $(INIT_TIME_RM) $(FREQ_CHANNEL); fi;

self-checker:
	python3 $(PY_DIR)/self-checker.py $(INIT_TIME_RM) $(FREQ_CHANNEL)

self-checker-cpu:
	python3 $(PY_DIR)/self-checker.py $(INIT_TIME_RM) $(FREQ_CHANNEL) SoC0

clean_xcelium:
	@rm -rf xcelium.d
clean: clean_xcelium
	@rm -f  *~ *.vcd \#*\# a.out params.m *.hex *.txt *.log

.PHONY: all \
        usage \
        run \
        icarus \
        xcelium \
        xcelium_synth \
        xcelium_pr \
        plots_adpll_ctr0_tb \
        self-checker \
        clean_xcelium clean

