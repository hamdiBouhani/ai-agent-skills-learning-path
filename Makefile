.PHONY: help setup model check clean update-readme n8n-up n8n-down n8n-status n8n-open

# ---------------------------------------------------------------------------
# Default: show help
# ---------------------------------------------------------------------------

help:
	@echo "AI Agent Skills Learning Path — Makefile targets"
	@echo ""
	@echo "  make setup         One-time repo setup (copy reference docs, create folders)"
	@echo "  make model         Pull qwen2.5:7b into Ollama (4.4 GB)"
	@echo "  make check         Verify Ollama is running and model is available"
	@echo "  make clean         Remove downloaded model (frees ~4.4 GB)"
	@echo "  make update-readme Refresh README links after editing docs"
	@echo ""
	@echo "  make n8n-up        Start n8n via Docker (port 5678)"
	@echo "  make n8n-down      Stop n8n Docker container"
	@echo "  make n8n-status    Check if n8n container is running"
	@echo "  make n8n-open      Open n8n in browser (http://localhost:5678)"
	@echo ""
	@echo "Prerequisites: Ollama installed, Docker running"
	@echo ""

# ---------------------------------------------------------------------------
# One-time repo setup
# ---------------------------------------------------------------------------

setup:
	@echo "==> Setting up repo structure..."
	@mkdir -p resources
	@echo "    created resources/ directory"
	@# Copy reference docs from tech-skills folder if they exist
	@if [ -f "C:/Users/bouha/OneDrive/Documents/tech-skills/trending-tech-2026.md" ]; then \
		cp "C:/Users/bouha/OneDrive/Documents/tech-skills/trending-tech-2026.md" resources/; \
		echo "    copied trending-tech-2026.md -> resources/"; \
	else \
		echo "    (trending-tech-2026.md not found — skipped)"; \
	fi
	@if [ -f "C:/Users/bouha/OneDrive/Documents/tech-skills/multi-agent-orchestration-deep-dive.md" ]; then \
		cp "C:/Users/bouha/OneDrive/Documents/tech-skills/multi-agent-orchestration-deep-dive.md" resources/; \
		echo "    copied multi-agent-orchestration-deep-dive.md -> resources/"; \
	else \
		echo "    (multi-agent-orchestration-deep-dive.md not found — skipped)"; \
	fi
	@echo "==> Setup complete. Run 'make model' to pull the local LLM, then 'make check' to verify."

# ---------------------------------------------------------------------------
# Pull the local model
# ---------------------------------------------------------------------------

MODEL_PATH ?= /c/Users/bouha/AppData/Local/Programs/Ollama/ollama.exe
MODEL_NAME ?= qwen2.5:7b

model:
	@echo "==> Pulling $(MODEL_NAME) from Ollama (approximately 4.4 GB, first run only)..."
	@$(MODEL_PATH) pull $(MODEL_NAME)
	@echo "==> Done. Run 'make check' to confirm."

# ---------------------------------------------------------------------------
# Verify Ollama + model
# ---------------------------------------------------------------------------

check:
	@echo "==> Checking Ollama..."
	@$(MODEL_PATH) list 2>/dev/null || { echo "ERROR: Ollama not reachable. Is it installed and running?"; exit 1; }
	@echo ""
	@echo "==> Installed models:"
	@$(MODEL_PATH) list
	@echo ""
	@if $(MODEL_PATH) list | grep -q "$(MODEL_NAME)"; then \
		echo "==> $(MODEL_NAME) is available. You are ready to build."; \
	else \
		echo "==> $(MODEL_NAME) not found. Run 'make model' to pull it."; \
	fi

# ---------------------------------------------------------------------------
# Remove model to free space
# ---------------------------------------------------------------------------

clean:
	@echo "==> Removing $(MODEL_NAME) from Ollama..."
	@$(MODEL_PATH) rm $(MODEL_NAME) 2>/dev/null || echo "    (model not installed or Ollama not reachable)"
	@echo "==> Done."

# ---------------------------------------------------------------------------
# Refresh README links (run after adding/editing docs)
# ---------------------------------------------------------------------------

update-readme:
	@echo "==> Updating README with current file list..."
	@echo "    (README update is manual for now — edit README.md directly)"
	@ls -1 *.md resources/*.md 2>/dev/null || true

# ---------------------------------------------------------------------------
# n8n via Docker
# ---------------------------------------------------------------------------

N8N_CONTAINER ?= n8n-ai-learning

n8n-up:
	@echo "==> Starting n8n via Docker in background (http://localhost:5678)..."
	@docker run -d --name $(N8N_CONTAINER) -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n
	@echo "==> n8n started. Waiting for it to be ready..."
	@docker logs -f $(N8N_CONTAINER) 2>/dev/null &
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do \
		if curl -s http://localhost:5678 >/dev/null 2>&1; then \
			echo "==> n8n is ready at http://localhost:5678"; \
			break; \
		fi; \
		echo "    waiting... ($$i/15)"; \
		sleep 2; \
	done
	@echo "==> Open http://localhost:5678 to start building."

n8n-down:
	@echo "==> Stopping n8n container..."
	@docker stop $(N8N_CONTAINER) 2>/dev/null || echo "    (container not running)"
	@echo "==> Done."

n8n-status:
	@echo "==> Checking n8n container status..."
	@docker ps --filter "name=$(N8N_CONTAINER)" --format "table {{.Names}}	{{.Status}}	{{.Ports}}" 2>/dev/null || echo "    (no container found)"
	@echo ""

n8n-open:
	@echo "==> Opening n8n in browser..."
	@start http://localhost:5678 2>/dev/null || echo "    (start command not available — open manually: http://localhost:5678)"
