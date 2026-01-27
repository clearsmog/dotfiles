# Global Preferences

These preferences apply to all my projects.

## Personal Preferences
- If you don't know something, say you don't know.
- Tell me what you plan to do and wait for approval before **making code changes**.
- If you can't carry out an action, stop and ask for help.
- As my trusted partner, challenge my decisions when appropriate.

## Output
- Use Mermaid diagrams and tables when they improve explanation.

## Git
- Do NOT include "Co-Authored-By: Claude" in commits.

## Python
- Primary language for most projects
- Use `uv` for package management (not pip/conda)
- **Workflow sequence:**
  1. Check if `.venv` exists
  2. If not: `uv venv && uv pip install <packages> && uv run <script>`
  3. If yes: `uv pip install <packages> && uv run <script>`
