ROOT_DIR=.

# Default simulator (simulators: icarus xcelium)
SIM ?=icarus

# Debug active by default
DBG ?=1

#############################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE
#############################################################

#
# Paths
#

HW_DIR=$(ROOT_DIR)/hardware
INC_DIR=$(HW_DIR)/include
SRC_DIR=$(HW_DIR)/src
TB_DIR=$(HW_DIR)/testbench
SYNTH_DIR=$(HW_DIR)/synth
SW_DIR=$(ROOT_DIR)/software
PY_DIR=$(SW_DIR)/python

#
# Defines
#

ifeq ($(SIM),icarus)
defmacro:=-D
incdir:=-I
else
defmacro:=-define 
incdir:=-incdir 
endif

ifeq ($(DBG),1)
DEFINE+=$(defmacro)DBG
endif

include $(ROOT_DIR)/adpll.mk

#
# Includes
#

INCLUDE=$(incdir)$(INC_DIR)

#
# Sources
#

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

#
# Simulation flags
#

# Icarus
CC = iverilog
CFLAGS = -Wall -g2005-sv

# Xcelium
XCFLAGS = -errormax 15 -status -update -linedebug -SV
XEFLAGS = -errormax 15 -access +wc -status
XSFLAGS = -errormax 15 -status

ifneq ($(AMS_PN),)
EXTRA_ARGS=-ams_pn
endif

#
# Targets
#

all: usage

help: usage

usage:
	@echo "Usage: make target [parameters]"
	@echo "       For example, for running the ADPLL only, \"make run SIM=icarus\". For running"
	@echo "       the ADPLL with the CPU interface, \"make run_cpu SIM=xcelium\"."
	@echo ""
	@echo "       Note: To validate the simulation results, use plots_adpll or plots_adpll_cpu"
	@echo "       as target, according to the simulation made (ADPLL only or ADPLL with the"
	@echo "       CPU interface)."

run: $(SIM)_ctr0 self-checker

run_cpu: $(SIM)_ctr self-checker-cpu

icarus_ctr0:
	$(CC) $(CFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.v
	./a.out

icarus_ctr:
	$(CC) $(CFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(SRC_DIR)/adpll_ctr.v $(TB_DIR)/module_tb.sv $(TB_DIR)/adpll_ctr_tb.v
	./a.out

xcelium_ctr0:
	xmvlog $(XCFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_ctr:
	xmvlog $(XCFLAGS) $(INCLUDE) $(DEFINE) $(SRC) $(TB_SRC) $(SRC_DIR)/adpll_ctr0.v $(SRC_DIR)/adpll_ctr.v $(TB_DIR)/module_tb.sv $(TB_DIR)/adpll_ctr_tb.v
	xmelab $(XEFLAGS) adpll_ctr_tb
	xmsim $(XSFLAGS) adpll_ctr_tb

xcelium_synth_ctr0:
	xmvlog $(XCFLAGS) $(INCLUDE) $(DEFINE) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_synth.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_synth_ctr:
	xmvlog $(XCFLAGS) $(INCLUDE) $(DEFINE) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr_synth.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(SRC_DIR)/adpll_ctr.v $(TB_DIR)/module_tb.sv $(TB_DIR)/adpll_ctr_tb.v
	xmelab $(XEFLAGS) adpll_ctr_tb
	xmsim $(XSFLAGS) adpll_ctr_tb

xcelium_pr_ctr0:
	xmvlog $(XCFLAGS) $(INCLUDE) $(DEFINE) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr0_PR.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/adpll_ctr0_tb.v
	xmelab $(XEFLAGS) -sdf_cmd_file $(SYNTH_DIR)/adpll_ctr0_WC_AN_PR.sdf adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

xcelium_pr_ctr:
	xmvlog $(XCFLAGS) $(INCLUDE) $(DEFINE) $(TB_SRC) $(SYNTH_DIR)/adpll_ctr_PR.v $(SYNTH_DIR)/verilog_libs/fsc0l_d_generic_core_30.lib $(TB_DIR)/module_tb.sv $(TB_DIR)/adpll_ctr_tb.v
	xmelab $(XEFLAGS) -sdf_cmd_file $(SYNTH_DIR)/adpll_ctr_WC_AN_PR.sdf adpll_ctr_tb
	xmsim $(XSFLAGS) adpll_ctr_tb

plots_adpll:
	if [ $(ADPLL_OPERATION) -eq $(RX) ]; then python3 $(PY_DIR)/rx_calc.py -t $(INIT_TIME_RM) $(EXTRA_ARGS); fi;
	if [ $(ADPLL_OPERATION) -eq $(TX) ]; then python3 $(PY_DIR)/tx_calc.py $(INIT_TIME_RM) $(FREQ_CHANNEL); fi;

plots_adpll_cpu:
	if [ $(ADPLL_OPERATION) -eq $(RX) ]; then python3 $(PY_DIR)/rx_calc.py -t $(INIT_TIME_RM) -s soc0 $(EXTRA_ARGS); fi;
	if [ $(ADPLL_OPERATION) -eq $(TX) ]; then python3 $(PY_DIR)/tx_calc.py $(INIT_TIME_RM) $(FREQ_CHANNEL) soc0; fi;

self-checker:
	python3 $(PY_DIR)/self-checker.py $(INIT_TIME_RM) $(FREQ_CHANNEL)

self-checker-cpu:
	python3 $(PY_DIR)/self-checker.py $(INIT_TIME_RM) $(FREQ_CHANNEL) soc0

clean_xcelium:
	@rm -rf xcelium.d

clean: clean_xcelium
	@rm -f  *~ *.vcd \#*\# a.out params.m *.hex *.txt *.log

.PHONY: all \
        help usage \
        run run_cpu \
        icarus_ctr0 icarus_ctr \
        xcelium_ctr0 xcelium_ctr \
        xcelium_synth_ctr0 xcelium_synth_ctr \
        xcelium_pr_ctr0 xcelium_pr_ctr \
        plots_adpll plots_adpll_cpu \
        self-checker self-checker-cpu \
        clean_xcelium clean

