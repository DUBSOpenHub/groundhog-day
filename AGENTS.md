# AGENTS.md: Working Guide for AI Agents

This file tells any AI agent how to work effectively on the Groundhog Day codebase.

---

## Architecture

Groundhog Day is a **standalone bash daemon** that watches `~/.copilot/skills/` and auto-syncs changes to a GitHub repository. It is NOT a Copilot CLI skill — it's infrastructure that protects skills.

```
~/bin/groundhog                          ← main script (bash)
├── watch mode (fswatch → rsync → git)   ← real-time file watcher
├── sync (rsync + git add/commit/push)   ← core sync logic
├── checkup (9-point diagnostic)         ← nightly health check
└── status (quick health check)          ← manual status

~/Library/LaunchAgents/
├── com.dubsopenhub.groundhog.plist           ← keeps watcher alive
└── com.dubsopenhub.groundhog.checkup.plist   ← nightly checkup at 6 AM
```

---

## File Ownership Map

| File | Purpose | Change Rules |
|------|---------|-------------|
| `groundhog` | Main script | All logic lives here. Test with `groundhog checkup` after changes. |
| `install.sh` | One-line installer | Must stay idempotent. Re-running should not break existing installs. |
| `com.dubsopenhub.groundhog.plist` | LaunchAgent (watcher) | KeepAlive=true. Update home dir paths if changing user support. |
| `com.dubsopenhub.groundhog.checkup.plist` | LaunchAgent (nightly) | Runs at 6 AM. No KeepAlive — runs once and exits. |
| `README.md` | Documentation | Keep GIFs, keep the tone. Don't remove the Bill Murray energy. |

---

## Key Design Decisions

### 1. No external dependencies beyond standard tools
Groundhog Day uses only: `bash`, `fswatch`, `rsync`, `git`, `python3` (stdlib only). No pip packages. No node modules. This is intentional — it must survive on a fresh machine with just Homebrew basics.

### 2. Single file architecture
Everything lives in one bash script. No splitting into modules. This keeps installation trivial (`cp` one file) and debugging simple (`cat` one file).

### 3. Lock file for concurrency
`/tmp/groundhog.lock` is a directory-based lock (atomic on all filesystems). `mkdir` succeeds or fails atomically. Always release with `trap ... RETURN`.

### 4. README auto-generation
The sync target repo's README is regenerated on every sync using a single `python3` call that reads all `SKILL.md` frontmatter. This means the skills repo is always self-documenting.

---

## Before You Change Anything

1. Read the full `groundhog` script — it's one file
2. Run `groundhog checkup` to establish baseline health
3. Make your change
4. Run `groundhog checkup` again to verify nothing broke
5. Test a live sync: touch a file in `~/.copilot/skills/` and confirm it commits

---

## Critical Invariants

🔴 **Never remove the empty-source guard.** If `~/.copilot/skills/` is empty or missing, `rsync --delete` would wipe the entire backup repo. The `validate_skills()` function prevents this.

🔴 **Never remove the sync lock.** Without it, rapid file changes trigger overlapping `git commit` / `git push` cycles that corrupt state.

🔴 **Never pass skill file paths via shell interpolation into Python.** Use `sys.argv` to avoid injection. This was a real vulnerability found during the initial X-ray audit.

---

## Hardening History

Groundhog Day was stress-tested by two AI analysis agents:

- **Agent X-Ray**: Full security, reliability, and performance audit. Found 12 issues across 5 severity levels (3 critical, 2 high, 4 medium, 3 low).
- **Grid-Medic**: Independent diagnostic pass. Applied 8 fixes, validated each, verified clean restart.

All findings were resolved before v1.0. Run these agents again after any significant changes.
