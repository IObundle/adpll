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


adpll_ctr:  
	$(CC) $(CFLAGS) $(SRC) $(SRC1) $(SRC_DIR)/adpll_ctr.v $(SRC_DIR)/adpll_ctr_tb.sv
	./a.out

clean:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.txt

.PHONY: dco clean

