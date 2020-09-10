ADPLL_SW_DIR:=$(ADPLL_DIR)/software/driver

#include
INCLUDE+=-I$(ADPLL_SW_DIR)

#headers
HDR+=$(ADPLL_SW_DIR)/*.h

#sources
SRC+=$(ADPLL_SW_DIR)/*.c
