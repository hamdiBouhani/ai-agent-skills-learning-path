# AI Agent Skills — Learning Path

A structured progression from zero to production-agent builder, designed to be followed with a small local LLM.

## What's in this repo

```
.
├── Makefile                          # Setup, model pull, verify, clean
├── ai-agent-skills-learning-path.md  # The main learning path (6 stages + capstone)
├── README.md                         # This file
└── resources/
    ├── trending-tech-2026.md         # Reference: what's trending in AI/tech
    └── multi-agent-orchestration-deep-dive.md  # Reference: n8n, Make, Relay.app deep dive
```

## Prerequisites

- **Ollama** installed (https://ollama.com). Confirm with `ollama --version`.
- **Docker** running (Desktop or Engine). Confirm with `docker --version`.
- **Git** for version control.
- Internet connection for the first model download.

## Quick Start

```bash
# 1. One-time repo setup (copies reference docs into resources/)
make setup

# 2. Pull the local model (qwen2.5:7b, ~4.4 GB — first run only)
make model

# 3. Verify the model is ready
make check

# 4. Start n8n (Docker, background, auto-waits for ready)
make n8n-up

# 5. Open n8n in your browser
make n8n-open

# 6. Follow the learning path
#    Open ai-agent-skills-learning-path.md and start at Stage 0.
```

## Stopping n8n

```bash
make n8n-down   # Stop the n8n container when you're done
```

Your n8n data persists in `~/.n8n` between restarts — credentials, workflows, and settings are saved.

## Local Model

| Setting | Value |
|---------|-------|
| Model | `qwen2.5:7b` |
| Size | ~4.4 GB |
| Why | Small enough to be fast on most hardware, capable enough for tool calling and basic reasoning |
| Pull command | `make model` (or `ollama pull qwen2.5:7b`) |
| Check | `make check` |
| Remove | `make clean` (frees ~4.4 GB) |

> **Already have a model?** If you prefer a different one, edit `MODEL_NAME` in the Makefile or pass it inline: `make model MODEL_NAME=llama3.1:8b`. The learning path works with any model that can follow tool-calling instructions.

### Connecting n8n to Ollama

Once n8n is running:

1. In n8n, go to **Credentials** → **Add credential** → look for **Ollama** or **AI Agent** (depends on version — n8n added native Ollama support in 2026)
2. Set the URL to `http://host.docker.internal:11434` (Docker) — this lets the n8n container reach your host's Ollama
3. Test the connection — it should list available models including `qwen2.5:7b`
4. In your **AI Agent** node, select this Ollama credential and choose `qwen2.5:7b`
5. If n8n can't reach `host.docker.internal`, run n8n with `--add-host host.docker.internal:host-gateway` or use n8n Desktop which uses `localhost:11434` directly

## Local Model

| Setting | Value |
|---------|-------|
| Model | `qwen2.5:7b` |
| Size | ~4.4 GB |
| Why | Small enough to be fast on most hardware, capable enough for tool calling and basic reasoning |
| Pull command | `make model` (or `ollama pull qwen2.5:7b`) |
| Check | `make check` |
| Remove | `make clean` (frees ~4.4 GB) |

> **Already have a model?** If you prefer a different one, edit `MODEL_NAME` in the Makefile or pass it inline: `make model MODEL_NAME=llama3.1:8b`. The learning path works with any model that can follow tool-calling instructions.

## Learning Path Stages

| Stage | Focus | Est. Time |
|-------|-------|-----------|
| 0 — Prerequisites | Platform setup, API keys, basic concepts | 1–3 days |
| 1 — The Agentic Loop | Perceive → Reason → Act → Observe, stopping conditions | 2–4 days |
| 2 — Tools & Multi-Step | Tool descriptions, multi-cycle loops, error handling | 3–6 days |
| 3 — Memory & Context | Window buffer, summary, external storage, episodic memory | 3–5 days |
| 4 — Multi-Agent | Orchestrator + specialist sub-agents, cost routing, failure isolation | 4–7 days |
| 5 — Production Readiness | Observability, guardrails, human approval gates, eval, cost control | 5–8 days |
| 6 — Capstone | Pick one: research assistant, team workflow automator, or data pipeline | 1–2 weeks |

Each stage has a concept focus, a concrete build project, a checkpoint, and a "common mistakes" section.

## Reference Docs

- **trending-tech-2026.md** — what's hot in AI and tech right now (agentic AI, GenAI, edge AI, quantum, AR/VR, Cloud 3.0, etc.)
- **multi-agent-orchestration-deep-dive.md** — deep dive on n8n, Make, and Relay.app: capabilities, architecture, comparison table, production patterns

## Updating This Repo

After editing the learning path or adding new docs:

```bash
make update-readme   # Shows current file list (README edits are manual)
git add -A
git commit -m "Update: <what changed>"
git push
```

## License

This learning path is shared freely. Use it, adapt it, share it.