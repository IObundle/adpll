ADPLL_OPERATION = 2 # PD = 0, TEST = 1, RX = 2, TX = 3
FREQ_CHANNEL = 2433.500 # Channel freq in MHz
SIM_TIME = 150 # simulation time in us
DCO_PN = 1 # dco phase noise flag
INIT_TIME_RM = 25 # initial transient time to remove in us (display purposes)

DEFINE+=$(defmacro)FREQ_CHANNEL=$(FREQ_CHANNEL) $(defmacro)SIM_TIME=$(SIM_TIME) $(defmacro)DCO_PN=$(DCO_PN) $(defmacro)ADPLL_OPERATION=$(ADPLL_OPERATION)
