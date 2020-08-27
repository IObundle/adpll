SRC_DIR = .

SRC = \
	$(SRC_DIR)/ring_osc.sv \
	$(SRC_DIR)/ring_inv.sv
SRC1 = \
	$(SRC_DIR)/d_ff1.sv \
	$(SRC_DIR)/d_ff2.sv \
	$(SRC_DIR)/d_latch1.sv \
	$(SRC_DIR)/counter.sv
SRC2 = \
	$(SRC_DIR)/tdc_analog.sv
SRC3 = \
	$(SRC_DIR)/tdc_digital.v

#Icarus 
CC = iverilog
CFLAGS = -W all -g2005-sv 

tdc:
	$(CC) $(CFLAGS) $(SRC) $(SRC1) $(SRC2) $(SRC3) $(SRC_DIR)/tdc_tb.sv
	./a.out

tdc_analog:
	$(CC) $(CFLAGS) $(SRC) $(SRC1) $(SRC2) $(SRC_DIR)/tdc_analog_tb.sv
	./a.out

counter:  
	$(CC) $(CFLAGS) $(SRC1) $(SRC_DIR)/counter_tb.sv
	./a.out

ring_osc:  
	$(CC) $(CFLAGS) $(SRC) $(SRC_DIR)/ring_osc_tb.sv
	./a.out

clean:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.txt

.PHONY: dco clean

