ADPLL_MODE = 2 # PD = 0, TEST = 1, RX = 2, TX = 3
FREQ_CHANNEL = 2480.000 # Channel freq in MHz
SIM_TIME = 60 # simulation time in us
DCO_PN = 0 # dco phase noise flag

DEFINE = -DADPLL_MODE=$(ADPLL_MODE) -DFREQ_CHANNEL=$(FREQ_CHANNEL) -DSIM_TIME=$(SIM_TIME) -DDCO_PN=$(DCO_PN)

SRC_DIR = .

SRC = \
	$(SRC_DIR)/DCO/dco.sv \
	$(SRC_DIR)/DCO/row_col_cod.v \
	$(SRC_DIR)/DCO/row_col_cod_5x5.v \
	$(SRC_DIR)/DCO/c_sel.sv
SRC1 = \
	$(SRC_DIR)/TDC/ring_osc.sv \
	$(SRC_DIR)/TDC/ring_inv.sv \
	$(SRC_DIR)/TDC/d_ff1.sv \
	$(SRC_DIR)/TDC/d_ff2.sv \
	$(SRC_DIR)/TDC/d_latch1.sv \
	$(SRC_DIR)/TDC/counter.sv \
	$(SRC_DIR)/TDC/tdc_analog.sv \
	$(SRC_DIR)/TDC/tdc_digital.v

#Icarus 
CC = iverilog
CFLAGS = -W all -g2005-sv 


adpll_ctr_tb:
	$(CC) $(CFLAGS) $(DEFINE) $(SRC) $(SRC1) $(SRC_DIR)/adpll_ctr.v $(SRC_DIR)/adpll_ctr_tb.sv
	./a.out
	if [ $(ADPLL_MODE) -eq 2 ]; then python3 pn_calc.py; fi;
	if [ $(ADPLL_MODE) -eq 3 ]; then python3 eye_calc.py; fi;

clean:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.txt

.PHONY: adpll_ctr_tb clean

