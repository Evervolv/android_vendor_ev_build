# Recovery
BOARD_USES_FULL_RECOVERY_IMAGE ?= true

# Include kernel configs
include $(SRC_EVERVOLV_DIR)/build/target/board/BoardConfigKernel.mk

# Include vendor board platforms
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
    include build/make/target/board/BoardConfigPixelCommon.mk
    include device/qcom/common/BoardConfigQcom.mk
endif

# Include soong configs
include $(SRC_EVERVOLV_DIR)/build/target/board/BoardConfigSoong.mk
