################################################################################
#
# wayland
#
################################################################################

#WAYLAND_VERSION = 1.24.0
ifeq ($(BR2_PACKAGE_WAYLAND_VERSION),)
WAYLAND_VERSION = 1.11.0
WAYLAND_SITE = http://wayland.freedesktop.org/releases
else
WAYLAND_VERSION = $(subst ",,$(BR2_PACKAGE_WAYLAND_VERSION))
WAYLAND_SITE = https://gitlab.freedesktop.org/wayland/wayland/-/releases/$(WAYLAND_VERSION)/downloads
endif
WAYLAND_SOURCE = wayland-$(WAYLAND_VERSION).tar.xz
WAYLAND_LICENSE = MIT
WAYLAND_LICENSE_FILES = COPYING
WAYLAND_INSTALL_STAGING = YES
WAYLAND_DEPENDENCIES = host-pkgconf host-wayland expat libffi libxml2

HOST_WAYLAND_VERSION = 1.15.0
HOST_WAYLAND_SITE = http://wayland.freedesktop.org/releases
HOST_WAYLAND_SOURCE = wayland-$(HOST_WAYLAND_VERSION).tar.xz
HOST_WAYLAND_DEPENDENCIES = host-pkgconf host-expat host-libffi host-libxml2

ifeq ($(shell printf "%s\n" $(WAYLAND_VERSION) 1.18.0 | sort -V | head -n1),1.18.0)
WAYLAND_IS_118_OR_NEWER := y
undefine HOST_WAYLAND_VERSION
endif

# wayland-scanner is only needed for building, not on the target
ifeq ($(WAYLAND_IS_118_OR_NEWER),y)
WAYLAND_CONF_OPTS = -Dtests=false -Ddocumentation=false
HOST_WAYLAND_CONF_OPTS = -Dtests=false -Ddocumentation=false
else
WAYLAND_CONF_OPTS = --disable-scanner --with-host-scanner
endif

# Remove the DTD from the target, it's not needed at runtime
define WAYLAND_TARGET_CLEANUP
	rm -rf $(TARGET_DIR)/usr/share/wayland
endef
WAYLAND_POST_INSTALL_TARGET_HOOKS += WAYLAND_TARGET_CLEANUP

# The wayland-scanner.pc installed by the target wayland package is
# used to find the wayland-scanner tool, which in a cross-compilation
# context is compiled for the host (and in Buildroot, compiled by
# host-wayland). Below, we tweak the target wayland-scanner.pc so that
# when the wayland_scanner variable is requested through pkg-config,
# it points to the host wayland_scanner tool.
ifeq ($(WAYLAND_IS_118_OR_NEWER),y)
define WAYLAND_TWEAK_WAYLAND_SCANNER_PATH
	$(SED) 's%^wayland_scanner=.*%wayland_scanner=$(HOST_DIR)/bin/wayland-scanner%' \
		$(STAGING_DIR)/usr/lib/pkgconfig/wayland-scanner.pc
endef
WAYLAND_POST_INSTALL_TARGET_HOOKS += WAYLAND_TWEAK_WAYLAND_SCANNER_PATH

$(eval $(meson-package))
$(eval $(host-meson-package))
else
$(eval $(autotools-package))
$(eval $(host-autotools-package))
endif
