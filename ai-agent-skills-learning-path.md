# AI Agent Skills — Learning Path

A structured progression from zero to production-agent builder. Each stage has a concept focus, a concrete build, and a checkpoint before moving on.

*Last updated: September 2026*

---

## How to Use This Path

- **One stage at a time.** Don't skip ahead — each stage builds on the previous.
- **Build something at every stage.** Reading isn't enough; agents only click when you wire one up and watch it make decisions.
- **Pick one platform and stick with it for the first three stages.** n8n (deepest agentic tooling, self-hostable, free) or Make (visual, broad integrations) are the best starting points. Relay.app is great for speed but thinner on multi-agent.
- **Checkpoint = you can explain it to someone else.** If you can't articulate what the agent does, why it chose a tool, and what would make it fail, you're not ready for the next stage.

---

## Stage 0: Prerequisites (1–3 days)

### What You Need Before Starting

**Platform setup:**
- **n8n path (primary):** A self-hosted n8n instance via Docker: `docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n`. Or use n8n Desktop (Windows/Mac/Linux). Cloud trial also available. **Critical for this repo:** n8n connects to your local Ollama model via its API at `http://localhost:11434` — you'll add this as a custom AI provider credential in n8n, not use OpenAI/Anthropic keys. See the "Connecting n8n to Ollama" box below.
- **Make path:** A Make account (free tier works). API keys for at least one LLM provider.
- **Relay.app path:** A Relay.app account (free tier works).

**Concepts to know:**
- What an API call is (request + response, JSON)
- What an LLM actually does (predicts tokens, doesn't "know" things, can hallucinate)
- The difference between structured data (a database row, a form field) and unstructured data (an email, a chat message, a PDF)
- Basic webhook concept — one system sends data to another when something happens

**Skill check:**
- [ ] You can get n8n running (Docker or Desktop) and open the canvas at `http://localhost:5678`
- [ ] You can add an Ollama credential in n8n (URL: `http://host.docker.internal:11434` if using Docker, or `http://localhost:11434` if using n8n Desktop)
- [ ] You can trigger a workflow manually and see the execution log
- [ ] You can connect one node to another (e.g. webhook → Slack message)

> **Connecting n8n to Ollama:**
> 1. In n8n, go to Credentials → Add credential → AI Agent (or "Ollama APIClient" / "Custom AI Provider" depending on version)
> 2. Set the URL to `http://host.docker.internal:11434` (Docker) or `http://localhost:11434` (Desktop)
> 3. Test the connection — it should list available models
> 4. In your AI Agent node, select this Ollama credential and choose `qwen2.5:7b` as the model
> 5. If n8n is in Docker and can't reach `localhost:11434`, use `host.docker.internal` (Docker Desktop for Windows supports this) or run n8n with `--add-host host.docker.internal:host-gateway`

---

## Stage 1: The Agentic Loop (2–4 days)

### Concept Focus

The agentic loop is the heartbeat of every AI agent: **Perceive → Reason → Act → Observe**, repeating until done.

- **Perceive** — the agent reads input (a message, an API response, a file)
- **Reason** — the LLM looks at the goal + current context and decides the next action
- **Act** — the agent calls a tool (web search, database query, API write, etc.)
- **Observe** — the agent sees the result and feeds it into the next reasoning cycle

The loop only works if you give it:
1. A clear goal (system prompt)
2. A set of tools it can call
3. A stopping condition (task complete OR max iterations)

Without a stopping condition, the loop runs forever.

### Build Project: Single-Step Classifier

Build an agent that reads an inbound message (email, Slack message, or webhook payload) and classifies it into one of 3–5 categories, then takes one action per category.

**Example — support ticket classifier:**
- Input: a support ticket (subject + body)
- Tools: none yet — just the LLM
- Output: a category (billing, technical, feature request, escalation) + a short summary
- Action: post the classified result to a Slack channel or write to a Google Sheet

**What you're learning:**
- Writing a system prompt that produces reliable, structured output
- Seeing the reasoning trace (Make's Reasoning Panel, n8n's execution log)
- Understanding that the agent "decides" — you didn't hardcode if/else branches
- Watching the loop run exactly once (perceive + reason + act, then stop)

**Checkpoint:**
- [ ] Your agent correctly classifies 8 out of 10 test messages you throw at it
- [ ] You can point to the exact place in the execution log where the LLM decided the category
- [ ] You can explain what would happen if you gave it a message that doesn't fit any category (hint: it'll still pick one — that's a prompt design problem you'll fix in Stage 2)

### Common Mistakes
- Vague system prompt ("handle support tickets") → agent guesses wildly. Fix: be specific ("classify into exactly one of: billing, technical, feature_request, escalation. If unsure, pick the closest and flag low confidence.")
- No max iterations set → if you later add tools that can loop, the agent runs forever. Set it now out of habit.
- Expecting perfection → agents are probabilistic. Design for "good enough plus a human review path," not "always right."

---

## Stage 2: Tools and Multi-Step Reasoning (3–6 days)

### Concept Focus

An agent with only an LLM can talk. An agent with tools can *do things*. This stage is about giving your agent capabilities and watching it decide which to use.

**Tool types:**
- **Retrieval** — web search, database query, vector store lookup, file read
- **Action** — send email, create ticket, update CRM record, post to Slack
- **Transformation** — extract structured data from text, summarize, translate, format

**Key principle: tool descriptions matter.** The agent decides which tool to call based on the name and description you give it. "CRM lookup" is ambiguous. "Fetch customer record by email from HubSpot" is actionable. Be precise.

**Stopping conditions (now mandatory):**
- Task complete — the agent returns a structured final output
- Max iterations — hard cap (10 is a reliable starting point)
- Human review trigger — when confidence is low, pause for a person
- Error fallback — when a tool fails, what happens next?

### Build Project: Research + Write Agent

Build an agent that takes a topic, researches it, and produces a structured output.

**Example — weekly market briefing:**
- Input: a list of topics or a single topic + a target audience
- Tools:
  - Web search (Perplexity, SerpAPI, or the platform's native search node)
  - Read a webpage (HTTP request)
  - Write to a doc/CRM/Slack (your choice)
- Flow:
  1. Agent receives the topic
  2. Agent searches for recent information
  3. Agent reads the most relevant result(s)
  4. Agent synthesizes a summary
  5. Agent writes the summary to the destination (Slack, email, doc)
- Stopping condition: after writing the output, the task is complete. Max 8 iterations.

**What you're learning:**
- Giving an agent multiple tools and watching it pick the right ones in sequence
- The agentic loop in action across multiple cycles (search → read → synthesize → write)
- Tool description quality — if the agent calls the wrong tool, the description is the problem, not the model
- Output structure — forcing the agent to return something you can use downstream (JSON, a formatted message, a written doc)

**Checkpoint:**
- [ ] Your agent completes the full flow without you intervening
- [ ] You can trace each tool call in the execution log and explain why the agent chose it
- [ ] If you give it a topic with no search results, it handles the failure gracefully (error fallback or "nothing found" output) rather than looping

### Common Mistakes
- Too many tools at once → agent gets confused. Start with 2–3, add more after it works.
- Tool descriptions that are too vague or too long → the agent either guesses wrong or gets lost in the prompt. Keep them to one precise sentence each.
- No error handling → when a tool fails (rate limit, bad API key, network issue), the agent either loops or crashes. Add a fallback path.
- Trusting the output blindly → agents can hallucinate search results. For production, add a human review step or a verification step.

---

## Stage 3: Memory and Context (3–5 days)

### Concept Focus

A stateless agent forgets everything between runs. A useful agent remembers. This stage is about giving your agent context that persists.

**Memory types:**
- **Window buffer** — last N messages. Simple, good for short conversations.
- **Summary memory** — rolling summary that compresses history. Good for long conversations where full context gets expensive.
- **External storage** — Redis, Postgres, or a vector store. Persists across restarts. Queryable.
- **Episodic memory** — stores specific facts about a user or conversation ("user prefers short answers," "always talk in Arabic"). Loaded on demand.

**When you need memory:**
- Multi-turn conversations (the agent needs to refer back to what the user said earlier)
- Personalization (the agent adapts to a specific user's preferences)
- State across runs (a workflow that spans multiple executions, like a multi-day process)

**When you don't:**
- Single-shot tasks (classify this ticket, write this summary — done)
- Stateless transformations (extract fields from this PDF — done)

### Build Project: Conversational Assistant with Memory

Build an agent that holds a conversation and remembers key facts about the user.

**Example — onboarding assistant:**
- Input: a user messages the agent (via chat trigger, Slack, or a web UI)
- Memory: Redis or Postgres-backed (n8n) or the platform's built-in memory (Make/Relay)
- Flow:
  1. First message: agent greets the user and asks 2–3 onboarding questions (role, goals, preferences)
  2. Agent stores the answers in memory
  3. Subsequent messages: agent uses the stored context to tailor responses
  4. Agent can be asked "what do you know about me?" and returns the stored facts
- Optional: add an episodic memory feature where the agent learns one preference from the conversation and applies it later.

**What you're learning:**
- Connecting a memory backend and seeing context persist across executions
- The difference between "the agent remembered" and "the agent hallucinated that it remembered" — verify by asking it what it knows
- Context cost — longer memory = more tokens = higher cost. Summary memory is cheaper than full history for long conversations.
- When memory helps vs. when it's just adding noise

**Checkpoint:**
- [ ] You can start a conversation, come back later, and the agent still knows your preferences
- [ ] You can ask the agent what it remembers and get accurate answers (not made-up ones)
- [ ] You can explain the tradeoff between window buffer, summary memory, and external storage

### Common Mistakes
- Storing sensitive data in memory without thinking about deletion → GDPR/privacy implications. Plan for data deletion from the start.
- Memory that grows without bound → context gets expensive and the agent's decisions degrade. Use summary memory or set a retention policy.
- Assuming the agent "understands" what it remembers → it doesn't. It has text in a buffer. Design prompts that use that text well.

---

## Stage 4: Multi-Agent Orchestration (4–7 days)

### Concept Focus

One agent trying to do everything gets expensive, unreliable, and hard to debug. The production pattern in 2026 is **orchestrator + specialist sub-agents**.

**Architecture:**
- **Orchestrator** — receives the request, classifies intent, delegates to the right specialist, returns a combined result. Doesn't do the actual work; it routes.
- **Specialist sub-agents** — each does one thing well. Own tools, own system prompt, own error handling, bounded scope.

**Why this works better:**
- Cheaper — simple tasks go to cheap models, complex tasks to frontier models. You route per task, not per agent.
- More reliable — a specialist that fails only affects its own domain. The orchestrator can fall back or escalate.
- Easier to debug — when something goes wrong, you know which specialist failed.
- Easier to maintain — update the refund specialist without touching the CRM specialist.

**Sub-agent design rules:**
- One job per sub-agent. If it does two things, split it.
- Clear tool boundaries. A CRM sub-agent shouldn't have access to the email tool.
- Own stopping conditions. Each sub-agent has its own max iterations.
- Test sub-agents independently before wiring them into the orchestrator.

### Build Project: Customer Support Triage System

Build an orchestrator + 2–3 specialist agents for a support workflow.

**Example architecture:**
- **Orchestrator** — receives an inbound support message, classifies intent, routes to the right specialist, returns a combined response
- **Lookup specialist** — fetches customer history from CRM, checks past tickets, returns context
- **Reply specialist** — drafts a response based on the customer history + knowledge base, returns draft
- **Escalation specialist** — detects high-priority or ambiguous cases and flags for human review

**Flow:**
1. Inbound message arrives (webhook, email trigger, Slack)
2. Orchestrator reads it, classifies: simple question → lookup + reply, complex/ambiguous → escalation
3. Lookup specialist runs, returns customer context
4. Reply specialist uses context + knowledge base to draft a response
5. If confidence is low or the issue is escalated: human review trigger fires before anything is sent
6. Orchestrator returns the final result (draft response + classification + confidence + any escalation flag)

**What you're learning:**
- Wiring sub-agents as tools inside an orchestrator (n8n: sub-workflows or AI Agent tools; Make: Sub-Agent tools; Relay.app: more limited at this stage)
- Cost optimization — routing simple lookups to cheap models, complex drafting to frontier models
- Failure isolation — when the lookup specialist fails, the orchestrator can still escalate rather than crashing
- Human-in-the-loop at the right boundary — the agent handles the routine, the human handles the exception

**Checkpoint:**
- [ ] You can trace a single inbound message through the orchestrator and all specialist calls in the execution log
- [ ] If you break one specialist (e.g. CRM API is down), the system degrades gracefully instead of failing entirely
- [ ] You can explain which agent uses which model and why

### Common Mistakes
- Orchestrator doing actual work → it should route, not execute. If the orchestrator is calling tools directly, you've collapsed the architecture.
- Sub-agents with overlapping scope → if two specialists could handle the same request, the orchestrator will guess. Make scopes unambiguous.
- No fallbacks → if the primary specialist fails and there's no fallback, the whole flow breaks. Always have an escalation path.
- Over-nesting → sub-agents calling sub-agents calling sub-agents. Currently, one level of nesting is the practical limit. Deeper than that and debugging becomes a nightmare.

---

## Stage 5: Production Readiness (5–8 days)

### Concept Focus

An agent that works in testing and breaks in production is a liability. This stage is about the things that make agents deployable: observability, guardrails, cost control, evaluation, and human oversight.

**Observability:**
- Execution logs that show every tool call, model output, and intermediate state
- Token usage tracking per step (know what each agent run costs)
- Latency tracking (how long does each step take? where are the bottlenecks?)
- Integration with external observability tools (Langfuse, Helicone) via HTTP Request nodes

**Guardrails:**
- Max iterations cap — mandatory, always set it
- Human approval gates — pause before high-stakes actions (send an email to a customer, process a payment, update a record that can't be easily undone)
- Confidence thresholds — if the agent's confidence is below X, escalate to a human instead of acting
- Output validation — schema-check the agent's output before using it downstream. If the agent returns malformed JSON, catch it before it breaks the next step.
- Data filtering — redact PII or sensitive fields before sending to external LLM APIs

**Cost control:**
- Tiered model routing — simple tasks to cheap models, complex reasoning to frontier models. 60%+ cost reduction reported in production.
- Context management — don't send the entire conversation history to every call. Summarize, window, or retrieve only what's relevant.
- Token budgets — set per-run limits. Know what a "normal" run costs and alert on outliers.

**Evaluation:**
- Regression tests — run a set of test inputs through the agent and check that outputs match expected patterns. Catches prompt drift when you make changes.
- Model comparison — test the same inputs against different models and compare outputs. Informs your routing decisions.
- Prompt versioning — track which prompt produced which results. When something breaks after a change, you can diff.

**Human-in-the-loop:**
- Approval gates at consequential actions (not everywhere — just where mistakes are expensive)
- Review queues — a place where humans see agent outputs that need approval before they go live
- Exception handling — when the agent can't handle something, it hands off to a human with full context, not just "I don't know"

### Build Project: Production-Hardened Version of an Earlier Agent

Take one of your earlier builds (classifier, research agent, conversational assistant, or support triage) and harden it for production.

**Additions:**
- [ ] Execution logging with token usage visible per step
- [ ] Max iterations cap set and tested (what happens when it hits the cap?)
- [ ] At least one human approval gate at a consequential action
- [ ] Output validation (schema check or format check before downstream use)
- [ ] Error fallback for at least one tool (what happens when the API is down?)
- [ ] A small regression test set — 5–10 test inputs with expected output patterns
- [ ] Cost estimate for a typical run (tokens × model price)
- [ ] A document describing what the agent does, what it doesn't do, and what to monitor

**What you're learning:**
- The gap between "it works" and "it's safe to run without me watching every execution"
- How much a real agent run actually costs (spoiler: it's usually less than you think for simple tasks, more than you think for complex ones)
- How to debug a failed run using only the execution log
- What breaks in production that never showed up in testing (edge case inputs, API rate limits, network issues, model behavior changes)

**Checkpoint:**
- [ ] You can run the agent 10 times in a row with test inputs and it produces sensible output every time (not necessarily perfect — sensible)
- [ ] You can point to the exact log entry that shows what the agent did on each run
- [ ] You know what a "normal" run costs and what would constitute an abnormal spike
- [ ] You have a written note of what to watch for in the first week of production

### Common Mistakes
- Adding guardrails everywhere → the agent becomes so constrained it's useless. Guardrails at consequential actions, not every step.
- No regression tests → you change a prompt, nothing breaks in testing, and production silently degrades a week later. Even 5 test cases catch the obvious stuff.
- Ignoring cost until the bill arrives → track tokens from day one. A runaway loop can burn through a month's budget in an hour.
- Assuming the agent will "get better" with more data → it won't. It gets better with better prompts, better tools, better routing, and better guardrails. More data without those just means more bad decisions at scale.

---

## Stage 6: Capstone — Pick One

Choose one project that combines everything from Stages 1–5. This is your portfolio piece.

### Option A: Personal Research Assistant

An agent that runs on a schedule (daily or weekly), researches a topic you care about, and delivers a structured briefing.

**Scope:**
- Scheduled trigger (cron-like, built into n8n Agents tab or a separate scheduled workflow)
- Tools: web search, webpage read, maybe a vector store if you want to reference your own notes
- Memory: optional — if you want it to remember what it covered last time and avoid duplicates
- Output: a formatted briefing in Slack, email, or a doc
- Guardrails: max iterations, human review before sending if confidence is low, token tracking
- Evaluation: a short list of topics with expected coverage patterns

**Why this one:** It's genuinely useful, it exercises scheduling + tools + memory + guardrails, and it's low-stakes enough that mistakes are annoying not catastrophic.

### Option B: Team Workflow Automator

An agent that handles a repetitive team process end-to-end.

**Scope:**
- Pick a real process: lead qualification, invoice processing, meeting scheduling, content publishing, onboarding
- Integrate with the actual tools your team uses (CRM, Slack, email, Sheets, Notion, etc.)
- Multi-agent if the process has distinct phases (intake → classification → action → notification)
- Human approval at the boundary between "agent decides" and "agent acts on the decision"
- Full observability and a regression test set

**Why this one:** It's the most directly valuable. You'll learn more from building something your team actually uses than from any tutorial.

### Option C: Multi-Source Data Pipeline

An agent that ingests data from multiple sources, processes it, and writes structured output to a destination.

**Scope:**
- Multiple input sources (webhooks, email, file uploads, API pulls)
- Processing per source (different extraction logic, different validation rules)
- Unified output schema (everything lands in the same format in the destination)
- Error handling per source (one source fails, the others still work)
- Scheduling + monitoring

**Why this one:** It exercises the hardest part of agentic systems — handling variation across inputs without breaking. This is where most production agent systems actually live.

---

## Platform Recommendations by Stage

| Stage | Best Platform | Why |
|-------|--------------|-----|
| 0–1 | **n8n** | You're using it for the whole path — start here. Single LLM call works fine, and you'll learn the canvas. |
| 2 | **n8n** | AI Agent node exposes the reasoning loop visibly in the execution log. Tools are just nodes on the canvas. |
| 3 | **n8n** | Four memory backend options (in-memory, Redis, Postgres, Motorhead). Redis and Postgres give you full control. |
| 4 | **n8n** | Multi-agent orchestration with coordinator + specialist sub-agents. Tiered LLM routing for cost control. |
| 5 | **n8n** | Execution logs with per-node visibility, evaluation tooling, self-hosting for data control, MCP support. |
| 6 | **n8n** | Whatever you built Stages 0–5 on. Don't switch platforms mid-capstone. |

---

## Resources

### n8n
- Official docs: n8n.io/docs
- AI Agent node docs: look for "AI Agent" in the n8n documentation
- Community: n8n community forum — active, practical, real workflows shared
- n8n AI Assistant (built-in): use it to generate workflow skeletons from descriptions
- YouTube: search "n8n AI agents 2026" for walkthroughs. Look for content dated 2026 — older tutorials reference deprecated agent types (Conversational Agent, Plan-and-Execute) that no longer exist

### Make
- Official docs: help.make.com
- AI Agents guide: help.make.com/introduction-to-make-ai-agent-new
- Make Academy: "Automation to AI Agents" course
- Make Blog: "Announcing the next generation of Make AI Agents" (Feb 11, 2026) — good overview of the feature set
- Make Community: community.make.com — feature spotlights and scenario sharing

### General
- Agentic loop concept: Make's "What is an agentic loop?" blog post is a clear explanation
- MCP (Model Context Protocol): anthropics.com/research or the MCP docs — understanding this helps with tool integration across platforms
- Evaluation: look into Langfuse or Helicone for token tracking and tracing if your platform's built-in observability isn't enough

---

## What "Good" Looks Like at Each Stage

| Stage | A learner at this stage can... |
|-------|-------------------------------|
| 0 | Set up the platform, connect an LLM, trigger a workflow, read the log |
| 1 | Build a single-step agent that classifies or transforms input, explain why it made its decision, and set a max iterations cap |
| 2 | Give an agent 2–4 tools, watch it pick the right ones across multiple loop cycles, and handle a tool failure without crashing |
| 3 | Connect memory and have the agent use stored context across runs, explain the memory type tradeoff, and avoid unbounded context growth |
| 4 | Build an orchestrator + specialist sub-agents, route tasks to the right specialist, and isolate failures to one domain |
| 5 | Add observability, guardrails, cost tracking, and a regression test set to an existing agent, and explain what to monitor in production |
| 6 | Ship a capstone that a real person or team would actually use, with documentation of what it does and what to watch |

---

## After This Path

- **Go deeper on one platform** — n8n's Canvas UI, Make's Grid and Sub-Agents, or Relay.app's prompt-to-workflow. The fundamentals transfer; the platform specifics are the next layer.
- **Explore frameworks** — LangGraph, CrewAI, AutoGen. These are code-based and more flexible than visual platforms, but also more complex. Worth it once you've outgrown what the visual platforms can express.
- **Build in public** — share your agents, write about what broke, document your prompts. The agentic space is new enough that practical experience is scarce and valuable.
- **Specialize** — pick a domain (customer support, sales, finance, content, internal tools) and build a dozen agents in it. Depth beats breadth once you have the fundamentals.

---

*Last updated: September 2026*
