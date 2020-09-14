# PD = 0, TEST = 1, RX = 2, TX = 3
ADPLL_OPERATION=2

# Channel freq in MHz
FREQ_CHANNEL=2433.500

# simulation time in us
SIM_TIME=150

# dco phase noise flag
DCO_PN=1

# initial transient time to remove in us (display purposes)
INIT_TIME_RM=25

DEFINE+=$(defmacro)FREQ_CHANNEL=$(FREQ_CHANNEL) $(defmacro)SIM_TIME=$(SIM_TIME) $(defmacro)DCO_PN=$(DCO_PN) $(defmacro)ADPLL_OPERATION=$(ADPLL_OPERATION)
