# Board platform lists to be used for platform specific features.

# UM Families
UM_3_18_FAMILY := \
    msm8937 \
    msm8953 \
    msm8996

UM_4_4_FAMILY := \
    msm8998 \
    sdm660

UM_4_9_FAMILY := \
    sdm845 \
    sdm710

# Define platform variable names, QCOM didn't drop them for production, e.g.
# ifneq ($(filter $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
MSMSTEPPE := sm6150
TRINKET := trinket #SM6125

UM_4_14_FAMILY := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    msmnile \
    atoll

UM_4_19_FAMILY := \
    kona \
    lito \
    bengal

UM_5_4_FAMILY := \
    holi \
    lahaina

UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)
QCOM_BOARD_PLATFORMS += $(UM_PLATFORMS)
QSSI_SUPPORTED_PLATFORMS := $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)

# List of board platforms that use master side content protection.
MASTER_SIDE_CP_TARGET_LIST := msm8996 $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)

# List of boards platforms that use video hardware.
MSM_VIDC_TARGET_LIST := $(UM_PLATFORMS)
