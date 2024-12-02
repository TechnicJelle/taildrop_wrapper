NAME=taildrop_wrapper
BUILD_DIR=build
OUTPUT=$(BUILD_DIR)/$(NAME)
INSTALL_DIR=/usr/local/bin
INSTALL_PATH=$(INSTALL_DIR)/$(NAME)

RED = \033[0;31m
BOLD = \033[1m
NC = \033[0m# No Color

build:
	mkdir -p $(BUILD_DIR)
	dart compile exe bin/main.dart -o $(OUTPUT)
	@echo -e "$(BOLD)Build successful! Now to install, run 'sudo make install'$(NC)"

yad-installed:
	@which yad &> /dev/null || (echo -e "$(RED)yad is not installed. Please install yad first.$(NC)" && exit 1)

install: yad-installed
	install -m 755 $(OUTPUT) $(INSTALL_PATH)

clean:
	rm -rf $(BUILD_DIR)

uninstall:
	rm $(INSTALL_PATH)

.PHONY: build yad-installed install clean uninstall
