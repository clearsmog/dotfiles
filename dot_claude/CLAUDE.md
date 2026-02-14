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
- **iCloud-synced directories** (`~/Documents`, `~/Desktop`): create venvs as `.venv.nosync` with a `.venv` symlink to avoid syncing thousands of package files. Use: `uv venv .venv.nosync && ln -s .venv.nosync .venv`

## PDF Handling
- Before reading any PDF, run `uv run --script ~/.claude/scripts/parse_pdf.py "<path>" --info-only` to check page count and empty pages.
- If pages > 10: extract to `.parsed.md` first via `uv run --script ~/.claude/scripts/parse_pdf.py "<path>"`, then Read the `.parsed.md` instead.
- If pages <= 10: Read the PDF directly.
- If a `.parsed.md` already exists next to the PDF, read that instead of the PDF.
- If `--info-only` shows `empty_pages / pages > 0.5`: the PDF is likely scanned. Use the OCR script instead: `uv run --script ~/.claude/scripts/parse_pdf_ocr.py "<path>"`.

## Browser Automation
- Playwright CLI is installed (`npx playwright`). Use it for screenshots, scraping, or verifying web pages when needed.
- Prefer Playwright over `WebFetch` for JS-rendered pages, SPAs, or visual verification.

## Data Sources
- Refinitiv Codebook is available for ESG, fundamentals, and institutional data. Requires Refinitiv Workspace — Codebook scripts cannot run locally.
