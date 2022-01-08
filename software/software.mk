ADPLL_SW_DIR:=$(ADPLL_DIR)/software/driver
ADPLL_INC_DIR:=$(ADPLL_DIR)/hardware/include

#include
INCLUDE+=-I$(ADPLL_SW_DIR)

#headers
HDR+=$(ADPLL_SW_DIR)/*.h \
adpll_mem_map.h

#sources
SRC+=$(ADPLL_SW_DIR)/*.c

adpll_mem_map.h:
	sed -n 's/`ADPLL_ADDR_W//p' $(ADPLL_INC_DIR)/adpll_defines.vh | sed 's/`/#/g' | sed "s/('d//g" | sed 's/)//g' > ./$@
