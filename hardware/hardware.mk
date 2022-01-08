include $(ADPLL_DIR)/adpll.mk

ADPLL_HW_DIR:=$(ADPLL_DIR)/hardware
ADPLL_PY_DIR:=$(ADPLL_DIR)/software/python

#include
ADPLL_INC_DIR:=$(ADPLL_HW_DIR)/include
INCLUDE+=$(incdir)$(ADPLL_INC_DIR)

#headers
VHDR+=$(wildcard $(ADPLL_INC_DIR)/*.vh)

#sources
ADPLL_SRC_DIR:=$(ADPLL_HW_DIR)/src
ADPLL_TB_DIR:=$(ADPLL_HW_DIR)/testbench
VSRC+=$(wildcard $(ADPLL_SRC_DIR)/*.v)
ADPLL_TB_SVSRC:=$(wildcard $(ADPLL_TB_DIR)/DCO/*.sv) \
$(wildcard $(ADPLL_TB_DIR)/TDC/*.sv)