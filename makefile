NAME=taildrop_wrapper
BUILD_DIR=build
OUTPUT=$(BUILD_DIR)/$(NAME)
INSTALL_DIR=/usr/local/bin
INSTALL_PATH=$(INSTALL_DIR)/$(NAME)
ICONS_DIR=/usr/share/icons/hicolor

EXTRA_DIR=extra
THUNAR_INTEGRATION_DIR=~/.local/share/Thunar/sendto
THUNAR_INTEGRATION_FILE=taildrop_wrapper.desktop

RED = \033[0;31m
BOLD = \033[1m
NC = \033[0m# No Color

build:
	mkdir -p $(BUILD_DIR)
	dart compile exe bin/main.dart -o $(OUTPUT)
	@echo -e "$(BOLD)Build successful! Now to install, run 'sudo make install'$(NC)"

yad-installed:
	@command -v yad &> /dev/null || (echo -e "$(RED)yad is not installed. Please install yad first.$(NC)" && exit 1)

fm-integrate: thunar-integration

fm-integration-uninstall: thunar-integration-uninstall

thunar-integration:
	@if command -v thunar &> /dev/null; then \
		mkdir -p $(THUNAR_INTEGRATION_DIR); \
		cp $(EXTRA_DIR)/$(THUNAR_INTEGRATION_FILE) $(THUNAR_INTEGRATION_DIR)/$(THUNAR_INTEGRATION_FILE); \
	fi

thunar-integration-uninstall:
	rm -f $(THUNAR_INTEGRATION_DIR)/$(THUNAR_INTEGRATION_FILE)

install: yad-installed
	install -m 755 $(OUTPUT) $(INSTALL_PATH)
	@for i in 16 32 256 1024; do \
		install -m 644 $(EXTRA_DIR)/icon$$i.png $(ICONS_DIR)/$$i"x"$$i/apps/$(NAME).png; \
	done
	gtk-update-icon-cache $(ICONS_DIR)
	@echo -e "$(BOLD)Install successful! Now you can optionally integrate with your file manager(s) by running 'make fm-integrate'$(NC)"

clean:
	rm -rf $(BUILD_DIR)

uninstall:
	rm $(INSTALL_PATH)
	@for i in 16 32 256 1024; do \
		rm $(ICONS_DIR)/$$i"x"$$i/apps/$(NAME).png; \
	done
	gtk-update-icon-cache $(ICONS_DIR)
	@echo -e "$(BOLD)Uninstall successful$(NC)"

.PHONY: build yad-installed fm-integrate fm-integrate-uninstall thunar-integration thunar-integration-uninstall install clean uninstall
