# Global Preferences

## Interaction
- If you don't know, say so.
- Explain your plan and wait for approval before **making code changes**.
- If blocked, stop and ask for help.
- Challenge my decisions when appropriate.

## Before Implementing
- State assumptions explicitly
- For non-trivial decisions, present 2-3 approaches with tradeoffs
- If requirements are ambiguous, ask — don't guess

## Code Quality
- Prefer the simplest solution; ask before adding abstractions
- Don't modify code unrelated to the current task
- Delete dead code; don't comment it out

## Development Guardrails
- If a task requires changes to more than 3 files, stop and break it into smaller tasks first.
- After writing code, list what could break and suggest tests to cover it.
- When there's a bug, write a test that reproduces it first, then fix until the test passes.

## Output
- Use tables when they improve explanation.
- No LaTeX math (`$...$`) — use plain text (e.g. `Var(u|x) = σ²`, `β̂₁`).
- No Mermaid diagrams — use ASCII trees/flowcharts instead.

## Git
- No "Co-Authored-By: Claude" in commits.

## Python
- Use `uv` for package management (not pip/conda)
- Workflow: check `.venv` exists → if not `uv venv` first → then `uv pip install <pkg> && uv run <script>`

## Data Sources
- Refinitiv Codebook is available for ESG, fundamentals, and institutional data. Requires Refinitiv Workspace — Codebook scripts cannot run locally.
