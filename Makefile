# Caminhos
BIN_NAME = comitto
BIN_PATH = bin/comitto.sh
INSTALL_PATH = /usr/local/bin/$(BIN_NAME)

# Estilo de log
GREEN = \033[0;32m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: install uninstall status

install:
	@if [ ! -f $(BIN_PATH) ]; then \
		echo "$(RED)[erro]$(NC) Script $(BIN_PATH) não encontrado."; \
		exit 1; \
	fi
	@chmod +x $(BIN_PATH)
	@sudo ln -sf $(PWD)/$(BIN_PATH) $(INSTALL_PATH)
	@echo "$(GREEN)[ok]$(NC) $(BIN_NAME) instalado em $(INSTALL_PATH)"
	@$(MAKE) status

uninstall:
	@if [ -L $(INSTALL_PATH) ]; then \
		sudo rm -f $(INSTALL_PATH); \
		echo "$(GREEN)[ok]$(NC) Link simbólico removido de $(INSTALL_PATH)"; \
	else \
		echo "$(RED)[info]$(NC) Nenhum link simbólico encontrado em $(INSTALL_PATH)"; \
	fi

status:
	@if command -v $(BIN_NAME) >/dev/null 2>&1; then \
		echo "$(GREEN)[ok]$(NC) $(BIN_NAME) está acessível em $$($(BIN_NAME) --version 2>/dev/null || which $(BIN_NAME))"; \
	else \
		echo "$(RED)[erro]$(NC) $(BIN_NAME) não está no PATH."; \
	fi
