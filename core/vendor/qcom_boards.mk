# Board platform lists to be used for platform specific features.
# TARGET_BOARD_PLATFORM specific featurization

# Platform name variables - used in makefiles everywhere
KONA := kona #SM8250
LITO := lito #SM7250
BENGAL := bengal #SM6115
MSMNILE := msmnile #SM8150
MSMSTEPPE := sm6150
TRINKET := trinket #SM6125
ATOLL := atoll #SM6250
LAHAINA := lahaina #SM8350
HOLI := holi #SM4350

# A Family
A_FAMILY := \
    msm8660 \
    msm8960

# B Family
B_FAMILY := \
    apq8084 \
    msm8226 \
    msm8610 \
    msm8974

# B64 Family
B64_FAMILY := \
    msm8992 \
    msm8994

# BR Family
BR_FAMILY := \
    msm8909 \
    msm8916 \
    msm8952

# UM Families
UM_3_18_FAMILY := \
    msm8937 \
    msm8953 \
    msm8996

UM_4_4_FAMILY := \
    msm8998 \
    sdm660

UM_4_9_FAMILY := \
    sdm710 \
    sdm845

UM_4_14_FAMILY := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    $(MSMNILE) \
    $(ATOLL)

UM_4_19_FAMILY := \
    $(KONA) \
    $(LITO) \
    $(BENGAL)

UM_5_4_FAMILY := \
    $(HOLI) \
    $(LAHAINA)

UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)
LEGACY_UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)
LEGACY_QCOM_PLATFORMS := $(A_FAMILY) $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY) $(LEGACY_UM_PLATFORMS)
QCOM_BOARD_PLATFORMS += $(A_FAMILY) $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY) $(UM_PLATFORMS)
QSSI_SUPPORTED_PLATFORMS := $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)

# List of board platforms that use master side content protection.
MASTER_SIDE_CP_TARGET_LIST := msm8996 $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)

# List of boards platforms that use video hardware.
MSM_VIDC_TARGET_LIST := $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY) $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)
