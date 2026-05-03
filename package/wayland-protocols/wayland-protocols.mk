################################################################################
#
# wayland-protocols
#
################################################################################

WAYLAND_PROTOCOLS_VERSION = 1.11
WAYLAND_PROTOCOLS_SITE = http://wayland.freedesktop.org/releases
WAYLAND_PROTOCOLS_SOURCE = wayland-protocols-$(WAYLAND_PROTOCOLS_VERSION).tar.xz
WAYLAND_PROTOCOLS_LICENSE = MIT
WAYLAND_PROTOCOLS_LICENSE_FILES = COPYING
WAYLAND_PROTOCOLS_INSTALL_STAGING = YES
WAYLAND_PROTOCOLS_INSTALL_TARGET = NO
# needs wayland-scanner
WAYLAND_PROTOCOLS_DEPENDENCIES = host-wayland

# webOS 26 uses wayland 1.22 with wayland-protocols 1.33, so use latest
ifeq ($(shell printf "%s\n" $(BR2_PACKAGE_WAYLAND_VERSION) 1.22.0 | sort -V | head -n1),1.22.0)
WAYLAND_PROTOCOLS_VERSION = 1.45
WAYLAND_PROTOCOLS_SITE = https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/$(WAYLAND_PROTOCOLS_VERSION)/downloads
WAYLAND_PROTOCOLS_CONF_OPTS = -Dtests=false
$(eval $(meson-package))
else
$(eval $(autotools-package))
endif
