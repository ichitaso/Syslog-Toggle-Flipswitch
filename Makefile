PACKAGE_VERSION = 1.0-4
ARCHS = armv6 armv7 armv7s arm64
THEOS_DEVICE_IP = 192.168.0.6

BUNDLE_NAME = SyslogToggle
SyslogToggle_FILES = Switch.x
SyslogToggle_FRAMEWORKS = UIKit
SyslogToggle_LIBRARIES = flipswitch
SyslogToggle_INSTALL_PATH = /Library/Switches

TOOL_NAME = syslogsw
syslogsw_FILES = main.mm
syslogsw_INSTALL_PATH = /Library/Switches/SyslogToggle.bundle

SUBPROJECTS += preinst
SUBPROJECTS += postrm

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	sudo chown -R root:wheel $(THEOS_STAGING_DIR)
	sudo chmod 755 $(THEOS_STAGING_DIR)
	sudo chmod 666 $(THEOS_STAGING_DIR)/Library/Switches/SyslogToggle.bundle/*.pdf
	sudo chmod 4755 $(THEOS_STAGING_DIR)/Library/Switches/SyslogToggle.bundle/syslogsw

after-install::
	install.exec "killall -9 backboardd"
	sudo rm -rf _
	rm -rf .obj
	rm -rf obj
#	rm -rf .theos
#	rm -rf *.deb
