ADPLL_OPERATION = 3 # PD = 0, TEST = 1, RX = 2, TX = 3
FREQ_CHANNEL = 2440.000 # Channel freq in MHz
SIM_TIME = 50 # simulation time in us
DCO_PN = 0 # dco phase noise flag
INIT_TIME_RM = 25 # initial transient time to remove in us (display purposes)
DEFINE = -DFREQ_CHANNEL=$(FREQ_CHANNEL) -DSIM_TIME=$(SIM_TIME) -DDCO_PN=$(DCO_PN) -DADPLL_OPERATION=$(ADPLL_OPERATION)

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


#Xcelium
XCFLAGS = -errormax 15 -status -update -linedebug -SV -DEFINE FREQ_CHANNEL=$(FREQ_CHANNEL) -DEFINE SIM_TIME=$(SIM_TIME) -DEFINE ADPLL_OPERATION=$(ADPLL_OPERATION)
XEFLAGS = -errormax 15 -access +wc -status
XSFLAGS = -errormax 15 -status

icarus_adpll_ctr0_tb:
	$(CC) $(CFLAGS) $(DEFINE) $(SRC) $(SRC1) $(SRC_DIR)/adpll_ctr0.v $(SRC_DIR)/adpll_ctr0_tb.sv
	./a.out
	make plots_adpll_ctr0_tb

xcelium_adpll_ctr0_tb:
	xmvlog $(XCFLAGS) $(SRC) $(SRC1) $(SRC_DIR)/adpll_ctr0.v $(SRC_DIR)/adpll_ctr0_tb.sv
	xmelab $(XEFLAGS) adpll_ctr0_tb
	xmsim $(XSFLAGS) adpll_ctr0_tb

plots_adpll_ctr0_tb:
	if [ $(ADPLL_OPERATION) -eq 2 ]; then python3 rx_calc.py $(INIT_TIME_RM); fi;
	if [ $(ADPLL_OPERATION) -eq 3 ]; then python3 tx_calc.py $(INIT_TIME_RM) $(FREQ_CHANNEL) ; fi;

clean:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.txt

.PHONY: adpll_ctr_tb clean

