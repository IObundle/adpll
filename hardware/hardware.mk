ADPLL_HW_DIR:=$(ADPLL_DIR)/hardware

#include
ADPLL_INC_DIR:=$(ADPLL_HW_DIR)/include
INCLUDE+=$(incdir) $(ADPLL_INC_DIR)

#headers
VHDR+=$(wildcard $(ADPLL_INC_DIR)/*.vh)

#sources
ADPLL_SRC_DIR:=$(ADPLL_DIR)/hardware/src
VSRC+=$(wildcard $(ADPLL_HW_DIR)/src/*.v)
