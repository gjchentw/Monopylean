.PHONY: help lake standalone mathlib clean project update-toolchain install-lean

# 預設目標
.DEFAULT_GOAL := help

# 專案名稱（可通過環境變數覆蓋）
PROJECT_NAME ?= $(shell basename $(PWD))
LEAN_TOOLCHAIN_STANDALONE := leanprover/lean4:stable
LEAN_TOOLCHAIN_MATHLIB := leanprover-community/mathlib4:lean-toolchain

# 顏色輸出
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# ============================================================================
# 工具檢查
# ============================================================================

LAKEFILE := lakefile.lean
LEAN_TOOLCHAIN := lean-toolchain

.PHONY: check-elan
check-elan:
	@if ! command -v elan > /dev/null 2>&1; then \
		echo "$(YELLOW)📥 elan not found. Installing...$(NC)"; \
		$(MAKE) install-lean; \
	else \
		echo "$(GREEN)✅ elan is already installed$(NC)"; \
	fi

.PHONY: check-lake
check-lake: check-elan
	@if ! command -v lake > /dev/null 2>&1; then \
		echo "$(YELLOW)📥 lake not found. Updating elan...$(NC)"; \
		elan update; \
	else \
		echo "$(GREEN)✅ lake is already installed$(NC)"; \
	fi

# ============================================================================
# Lean 4 安裝
# ============================================================================

.PHONY: install-lean
install-lean:
	@echo "$(YELLOW)📥 Installing Lean 4 toolchain (elan)...$(NC)"
	@echo "$(BLUE)This will install elan, which manages Lean versions.$(NC)"
	@if command -v curl > /dev/null 2>&1; then \
		curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y; \
		echo ""; \
		echo "$(YELLOW)Updating PATH environment...$(NC)"; \
		. $(HOME)/.profile; \
		echo "$(GREEN)✅ Lean 4 installation completed!$(NC)"; \
		echo ""; \
		echo "$(YELLOW)Please run the following command to apply changes:$(NC)"; \
		echo "  source $(HOME)/.profile"; \
		echo ""; \
		echo "$(YELLOW)Then try again:$(NC)"; \
		echo "  make standalone  or  make mathlib"; \
	else \
		echo "$(RED)❌ curl not found. Please install curl first.$(NC)"; \
		exit 1; \
	fi

# ============================================================================
# 主要目標
# ============================================================================

help:
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║          Lean 4 Project Management Makefile               ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Installation:$(NC)"
	@echo "  $(GREEN)make install-lean$(NC)  - Install Lean 4 and elan"
	@echo ""
	@echo "$(YELLOW)Project Setup:$(NC)"
	@echo "  $(GREEN)make$(NC)              - Build project (requires lakefile initialized)"
	@echo "  $(GREEN)make lake$(NC)         - Build project with 'lake build'"
	@echo "  $(GREEN)make standalone$(NC)   - Initialize or convert existing project to Standalone mode"
	@echo "  $(GREEN)make mathlib$(NC)      - Initialize or convert existing project to Mathlib mode"
	@echo ""
	@echo "$(YELLOW)Maintenance:$(NC)"
	@echo "  $(GREEN)make update-toolchain$(NC) - Update Lean toolchain"
	@echo "  $(GREEN)make clean$(NC)        - Remove build cache and Mathlib cache"
	@echo "  $(GREEN)make status$(NC)       - Show project status"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make install-lean            # First time: install Lean 4"
	@echo "  source ~/.profile            # Apply environment changes"
	@echo "  make standalone              # Create Standalone project"
	@echo "  make mathlib                 # Create Mathlib project"
	@echo "  make                         # Build project"
	@echo ""

# ============================================================================
# 工具鏈管理
# ============================================================================

update-toolchain: check-elan
	@echo "$(YELLOW)🔄 Updating Lean toolchain...$(NC)"
	@elan update
	@echo "$(GREEN)✅ Lean toolchain updated successfully!$(NC)"

.PHONY: ensure-toolchain-standalone
ensure-toolchain-standalone: check-lake
	@echo "$(YELLOW)📥 Ensuring Standalone toolchain ($(LEAN_TOOLCHAIN_STANDALONE))...$(NC)"
	@echo "$(LEAN_TOOLCHAIN_STANDALONE)" > "$(LEAN_TOOLCHAIN)"
	@echo "$(YELLOW)  - Downloading/updating toolchain via elan...$(NC)"
	@elan toolchain install stable || true
	@echo "$(GREEN)✅ Standalone toolchain ready!$(NC)"

.PHONY: ensure-toolchain-mathlib
ensure-toolchain-mathlib: check-lake
	@echo "$(YELLOW)📥 Ensuring Mathlib toolchain ($(LEAN_TOOLCHAIN_MATHLIB))...$(NC)"
	@echo "$(LEAN_TOOLCHAIN_MATHLIB)" > "$(LEAN_TOOLCHAIN)"
	@echo "$(YELLOW)  - Downloading/updating toolchain via elan...$(NC)"
	@elan toolchain install leanprover-community/mathlib4:lean-toolchain || true
	@echo "$(GREEN)✅ Mathlib toolchain ready!$(NC)"

# ============================================================================
# Lakefile 修改工具
# ============================================================================

.PHONY: lakefile-to-standalone
lakefile-to-standalone:
	@echo "$(YELLOW)🔧 Converting lakefile to Standalone project...$(NC)"
	@if [ ! -f "$(LAKEFILE)" ]; then \
		echo "$(RED)❌ Error: $(LAKEFILE) not found$(NC)"; \
		exit 1; \
	fi
	@if ! grep -q "^require.*[Mm]athlib" "$(LAKEFILE)"; then \
		echo "$(GREEN)✅ Lakefile already standalone (no mathlib requirement)."; \
	else \
		echo "$(YELLOW)  - Removing Mathlib dependencies$(NC)"; \
		sed -i '/^require.*[Mm]athlib/d' "$(LAKEFILE)"; \
		echo "$(GREEN)✅ Lakefile converted to Standalone project$(NC)"; \
	fi

.PHONY: lakefile-to-mathlib
lakefile-to-mathlib:
	@echo "$(YELLOW)🔧 Converting lakefile to Mathlib project...$(NC)"
	@if [ ! -f "$(LAKEFILE)" ]; then \
		echo "$(RED)❌ Error: $(LAKEFILE) not found$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)  - Checking for existing Mathlib dependency$(NC)"
	# avoid 'if !' which can interact poorly with shell -e
	@grep -q "^require.*[Mm]athlib" "$(LAKEFILE)" || { \
		echo "$(YELLOW)  - Adding Mathlib dependency$(NC)"; \
		# insert after the Lake imports using awk to simplify quoting
		awk '/^open Lake DSL/ { print; print "require mathlib from git \"https://github.com/leanprover-community/mathlib4.git\""; next }1' "$(LAKEFILE)" > "$(LAKEFILE).tmp" && mv "$(LAKEFILE).tmp" "$(LAKEFILE)"; \
		echo "$(GREEN)✅ Mathlib dependency added to lakefile$(NC)"; \
	}

# ============================================================================
# Lake 構建
# ============================================================================

lake: check-lake
	@echo "$(GREEN)🏗️  Building project...$(NC)"
	@lake build
	@echo "$(GREEN)✅ Build completed successfully!$(NC)"

# ============================================================================
# 專案初始化與轉換
# ============================================================================

# 預設目標：如果 lakefile 未初始化，報錯；否則執行 make lake
.PHONY: project
project: check-lake
	@if [ ! -f "$(LAKEFILE)" ]; then \
		echo "$(RED)❌ Error: lakefile.lean not found!$(NC)"; \
		echo "$(YELLOW)Please run one of the following:$(NC)"; \
		echo "  $(GREEN)make standalone$(NC)  - Initialize as Standalone project"; \
		echo "  $(GREEN)make mathlib$(NC)     - Initialize as Mathlib project"; \
		exit 1; \
	fi
	@$(MAKE) lake


standalone: ensure-toolchain-standalone reconfigure-standalone
	@echo "$(YELLOW)  - Updating dependencies with 'lake update'$(NC)"
	@lake update
	@echo "$(GREEN)✅ Standalone project configured successfully!$(NC)"
	@echo "$(YELLOW)  - Building project...$(NC)"
	@$(MAKE) lake

# helper used by standalone to keep shell logic simple
.PHONY: reconfigure-standalone
reconfigure-standalone:
	@if [ -f "$(LAKEFILE)" ]; then \
		if grep -q "^require.*[Mm]athlib" "$(LAKEFILE)"; then \
			echo "$(YELLOW)⚠️  Converting existing project to Standalone...$(NC)"; \
			$(MAKE) lakefile-to-standalone; \
			lake clean || true; \
			rm -rf .lake/build/lib/mathlib || true; \
		else \
			echo "$(GREEN)✅ Project already in Standalone mode ($(LAKEFILE) has no mathlib)."; \
		fi; \
	else \
		echo "$(YELLOW)📝 Initializing Standalone project...$(NC)"; \
		echo "$(YELLOW)  - Running 'lake init $(PROJECT_NAME)'$(NC)"; \
		lake init "$(PROJECT_NAME)"; \
	fi

mathlib: ensure-toolchain-mathlib reconfigure-mathlib
	@echo "$(YELLOW)  - Updating dependencies with 'lake update'$(NC)"
	@lake update
	@echo "$(YELLOW)  - Fetching Mathlib build cache with 'lake exe cache get'$(NC)"
	@lake exe cache get || echo "$(YELLOW)⚠️  Warning: Could not fetch Mathlib cache (non-critical)$(NC)"
	@echo "$(GREEN)✅ Mathlib project configured successfully!$(NC)"
	@echo "$(YELLOW)  - Building project...$(NC)"
	@$(MAKE) lake

.PHONY: reconfigure-mathlib
reconfigure-mathlib:
	@if [ -f "$(LAKEFILE)" ]; then \
		if grep -q "^require.*[Mm]athlib" "$(LAKEFILE)"; then \
			echo "$(GREEN)✅ Project already in Mathlib mode ($(LAKEFILE) contains mathlib)."; \
		else \
			echo "$(YELLOW)⚠️  Converting existing project to Mathlib...$(NC)"; \
			$(MAKE) lakefile-to-mathlib; \
			lake clean || true; \
		fi; \
	else \
		echo "$(YELLOW)📝 Initializing Mathlib project...$(NC)"; \
		echo "$(YELLOW)  - Running 'lake init $(PROJECT_NAME) math'$(NC)"; \
		lake init "$(PROJECT_NAME)" math; \
	fi

# ============================================================================
# 清理
# ============================================================================

clean: check-lake
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	@if [ -f "$(LAKEFILE)" ]; then \
		lake clean; \
		echo "$(GREEN)✅ Build cache cleaned$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  No lakefile found, skipping lake clean$(NC)"; \
	fi
	@echo "$(YELLOW)🧹 Removing Mathlib cache...$(NC)"
	@rm -rf .lake/build/lib/mathlib || true
	@echo "$(GREEN)✅ Mathlib cache removed$(NC)"
	@echo "$(GREEN)✅ Clean completed!$(NC)"

# ============================================================================
# 診斷
# ============================================================================

.PHONY: status
status:
	@echo "$(BLUE)Project Status:$(NC)"
	@if [ -f "$(LEAN_TOOLCHAIN)" ]; then \
		echo "  Toolchain: $$(cat $(LEAN_TOOLCHAIN))"; \
	else \
		echo "  Toolchain: $(RED)Not configured$(NC)"; \
	fi
	@if [ -f "$(LAKEFILE)" ]; then \
		echo "  Lakefile: $(GREEN)Found$(NC)"; \
		echo "    Dependencies:"; \
		@grep "^require" "$(LAKEFILE)" | sed 's/^/      /'; \
	else \
		echo "  Lakefile: $(RED)Not found$(NC)"; \
		grep "^require" "$(LAKEFILE)" | sed 's/^/      /'; \
	@if command -v elan > /dev/null 2>&1; then \
		echo "  Elan: $(GREEN)Installed at $$(which elan)$(NC)"; \
		echo "    Version: $$(elan --version)"; \
	else \
		echo "  Elan: $(RED)Not installed$(NC)"; \
	fi
	@if command -v lake > /dev/null 2>&1; then \
		echo "  Lake: $(GREEN)Installed at $$(which lake)$(NC)"; \
		echo "    Version: $$(lake --version)"; \
	else \
		echo "  Lake: $(RED)Not installed$(NC)"; \
	fi