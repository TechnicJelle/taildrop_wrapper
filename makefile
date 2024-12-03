NAME=taildrop_wrapper
BUILD_DIR=build
OUTPUT=$(BUILD_DIR)/$(NAME)
INSTALL_DIR=/usr/local/bin
INSTALL_PATH=$(INSTALL_DIR)/$(NAME)

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

thunar-integration:
	@if command -v thunar &> /dev/null; then \
		mkdir -p $(THUNAR_INTEGRATION_DIR); \
		cp $(EXTRA_DIR)/$(THUNAR_INTEGRATION_FILE) $(THUNAR_INTEGRATION_DIR)/$(THUNAR_INTEGRATION_FILE); \
	fi

thunar-integration-uninstall:
	rm -f $(THUNAR_INTEGRATION_DIR)/$(THUNAR_INTEGRATION_FILE)

install: yad-installed
	install -m 755 $(OUTPUT) $(INSTALL_PATH)

clean:
	rm -rf $(BUILD_DIR)

uninstall:
	rm $(INSTALL_PATH)

.PHONY: build yad-installed thunar-integration thunar-integration-uninstall install clean uninstall
