PACKAGE_VERSION = 1.0-1
ARCHS = armv6 armv7 armv7s arm64
THEOS_DEVICE_IP = 192.168.0.7

include theos/makefiles/common.mk

BUNDLE_NAME = SyslogToggle
SyslogToggle_FILES = Switch.x
SyslogToggle_FRAMEWORKS = UIKit
SyslogToggle_LIBRARIES = flipswitch
SyslogToggle_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

TOOL_NAME = syslogsw
syslogsw_FILES = main.mm
syslogsw_INSTALL_PATH = /Library/Switches/SyslogToggle.bundle

include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	sudo chown -R root:wheel $(THEOS_STAGING_DIR)
	sudo chmod 666 $(THEOS_STAGING_DIR)/Library/Switches/SyslogToggle.bundle/*.pdf
	sudo chmod 4755 $(THEOS_STAGING_DIR)/Library/Switches/SyslogToggle.bundle/syslogsw

after-install::
	install.exec "killall -9 backboardd"
	sudo rm -rf _
	rm -rf .obj
	rm -rf obj
#	rm -rf .theos
#	rm -rf *.deb
