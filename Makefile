include theos/makefiles/common.mk

TWEAK_NAME = SMSTimestamps
SMSTimestamps_FILES = Tweak.xm
SMSTimestamps_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
