BUILDDIR := $(shell pwd)
ADDONS ?= all
ADDON_SRC_PREFIX :=

-include ../../Makefile.include
include ../../xbmc-addons.include

clean:
	$(MAKE) -C $(PLATFORM) clean
	rm -f .installed-$(PLATFORM)

distclean:
	rm -rf $(PLATFORM) .installed-$(PLATFORM)
