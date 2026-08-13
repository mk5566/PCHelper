# Cross-tool collaboration protocol

This repository is the shared source of truth for Codex, Google Antigravity,
Grok Build, and human contributors. Do not rely on another tool's chat history
or local session state.

## Start of every task

1. Read `AGENTS.md`, `PROJECT_STATUS.md`, and `CONTINUE_HERE.md`.
2. Run `git status --short --branch` and preserve unrelated work.
3. Read only the files relevant to the requested task. Refresh the PC inventory
   when required by `AGENTS.md`; it remains local and ignored.
4. Confirm the intended remote and branch before any network write.

## Credential boundary

- Never place actual tokens, passwords, cookies, SSH private keys, API keys,
  recovery material, or browser profiles in tracked files, commits, issues, or
  assistant chat.
- Keep local values in ignored `.env` files, Windows Credential Manager, an
  SSH agent/key file outside the repository, or the active tool's secret store.
- Commit only safe placeholders such as `.env.example`, with no live values.
- Before staging, inspect environment-variable names only when relevant; never
  print their values. Before committing, scan staged text for common token and
  private-key markers and stop if any are found.
- If a secret is ever committed or pushed, revoke/rotate it immediately using
  its provider, then remove it in a new commit. Do not assume history rewriting
  alone makes the secret safe.

## Change and verification loop

1. Make the smallest scoped change.
2. Run task-relevant checks plus `git diff --check`.
3. Run `& '.\scripts\Test-RepositorySafety.ps1'`, then review
   `git diff --staged` for unintended files and sensitive data.
4. Commit a focused, descriptive change.
5. Push only to the explicitly approved remote.
6. Update `CONTINUE_HERE.md` in the same change with evidence and the next
   action.

## Handoff format

Every completed work session updates `CONTINUE_HERE.md` with:

- **Completed:** what changed and the commit hash when available.
- **Verified:** exact checks and outcomes.
- **Constraints:** safety boundaries and intentional configurations that must
  not be undone.
- **Next action:** one concrete, safe continuation step.
- **Open decisions:** choices that require the user.

Do not overwrite another contributor's in-progress work. If the working tree
is unexpectedly dirty or a decision is missing, stop and record the blocker.
