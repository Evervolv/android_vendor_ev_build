# Include vendor board platforms
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include device/qcom/common/BoardConfigQcom.mk
endif
