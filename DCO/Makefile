SRC_DIR = .

SRC = \
	$(SRC_DIR)/dco.sv \
	$(SRC_DIR)/row_col_cod.v \
	$(SRC_DIR)/row_col_cod_5x5.v \
	$(SRC_DIR)/c_sel.sv

#Icarus 
CC = iverilog
CFLAGS = -W all -g2005-sv 


# DCO time-model in System Verilog (icarus tool)
dco:  
	$(CC) $(CFLAGS) $(SRC) $(SRC_DIR)/dco_tb.sv
	./a.out

clean:
	@rm -f  *~ *.vcd \#*\# a.out params.m  *.hex *.txt

.PHONY: dco clean

