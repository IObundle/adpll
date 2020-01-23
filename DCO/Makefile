
SRC_DIR = .

SRC = \
	$(SRC_DIR)/dco.sv 

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

