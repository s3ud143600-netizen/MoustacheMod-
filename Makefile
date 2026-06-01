THEOS = /home/runner/theos
export THEOS
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MoustacheMod
MoustacheMod_FILES = main.mm
MoustacheMod_FRAMEWORKS = UIKit QuartzCore CoreGraphics
MoustacheMod_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
