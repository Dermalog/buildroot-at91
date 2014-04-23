#############################################################
#
# libusb
#
#############################################################
LIBUSB_LEGACY_VERSION = 0.1.12
LIBUSB_LEGACY_SOURCE = libusb-$(LIBUSB_LEGACY_VERSION).tar.gz
LIBUSB_LEGACY_SITE = http://downloads.sourceforge.net/project/libusb/libusb-0.1%20%28LEGACY%29/$(LIBUSB_LEGACY_VERSION)
LIBUSB_LEGACY_LICENSE = LGPLv2.1+
LIBUSB_LEGACY_LICENSE_FILES = COPYING
LIBUSB_LEGACY_DEPENDENCIES = host-pkgconf 
LIBUSB_LEGACY_INSTALL_STAGING = YES
# LIBUSB_LEGACY_CONF_OPT += --disable-udev

ifeq ($(BR2_avr32),y)
LIBUSB_LEGACY_CONF_OPT += --disable-timerfd
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
