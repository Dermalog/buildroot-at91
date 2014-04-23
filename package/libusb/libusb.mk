#############################################################
#
# libusb
#
#############################################################
LIBUSB_VERSION = 1.0.18
LIBUSB_SOURCE = libusb-$(LIBUSB_VERSION).tar.bz2
LIBUSB_SITE = http://downloads.sourceforge.net/project/libusb/libusb-1.0/libusb-$(LIBUSB_VERSION)
LIBUSB_LICENSE = LGPLv2.1+
LIBUSB_LICENSE_FILES = COPYING
LIBUSB_DEPENDENCIES = host-pkgconf 
LIBUSB_INSTALL_STAGING = YES
LIBUSB_CONF_OPT += --disable-udev

ifeq ($(BR2_avr32),y)
LIBUSB_CONF_OPT += --disable-timerfd
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
