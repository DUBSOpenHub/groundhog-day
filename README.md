# 🐿️ Groundhog Day

> Autonomous backup agent for Copilot CLI skills. Your laptop will crash. Your skills won't. Watches, syncs, pushes. Starts on boot, runs forever, zero interaction.

> ⚡ **Install in one line:**
> ```bash
> curl -fsSL https://raw.githubusercontent.com/DUBSOpenHub/groundhog-day/main/install.sh | bash
> ```
> Or with Homebrew:
> ```bash
> brew install DUBSOpenHub/tap/groundhog-day
> ```

![Groundhog Day](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExN2EzNW5wbnFjOHBiMWlrOWM2b21zMXU2eHYwM2p6cmU0Znl5ZWJyeiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o7WIQ4FARJdpmUni8/giphy.gif)

---

Did you know that every [Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli) skill you've ever built lives in one local folder?

```
~/.copilot/skills/
```

That's it. No version history. No sync. No restore path.

Your custom skills. Your workflow automations. The prompts you spent weeks iterating on to get just right. All sitting in a single directory on a single machine. One spilled coffee, one failed drive, one stolen laptop and it's all...

**...gone.** 💀

🐿️ Groundhog Day is a tiny background agent with one job: make sure that never happens. It watches your skills folder in real time, commits every change, and pushes it to GitHub automatically. You set it up once and never think about it again.

**🐿️ Zero effort. Zero maintenance. Zero risk of losing your work.**

The installer handles everything: detects your skills, creates a backup repo on your GitHub account, seeds it with your existing skills, and starts the watcher. One command, fully protected.

> 🐿️ *Same thing. Every time. It watches. It syncs. It pushes. It never stops. It never complains. It wakes up tomorrow and does it all again.*

---

## 🐿️ Quick Install

> ⚡ **Install in one line:**
> ```bash
> curl -fsSL https://raw.githubusercontent.com/DUBSOpenHub/groundhog-day/main/install.sh | bash
> ```

### 🐿️ See it in action

```
$ groundhog status
🐿️  Groundhog Day: ✅ Running

$ mkdir -p ~/.copilot/skills/my-new-skill
$ cat > ~/.copilot/skills/my-new-skill/SKILL.md << EOF
---
name: my-new-skill
description: A brand new skill I just created
---
EOF

  ... 5 seconds later ...

$ tail -1 ~/.groundhog.log
🐿️  synced — add skill: my-new-skill

$ groundhog checkup
🐿️  Groundhog Day — Nightly Checkup
✅ Watcher process: running
✅ Skills directory: 10 skills found
✅ Repo state: clean
✅ Remote: in sync
✅ Log: no errors
🐿️  All clear. Groundhog Day is healthy.
```

```bash
# 1. Clone
git clone https://github.com/DUBSOpenHub/groundhog-day.git ~/dev/groundhog-day

# 2. Set up your skills repo (or use an existing one)
gh repo create my-copilot-skills --public
git clone https://github.com/YOUR_USERNAME/my-copilot-skills.git ~/dev/copilot-skills

# 3. Install the agent
cp ~/dev/groundhog-day/groundhog ~/bin/groundhog
chmod +x ~/bin/groundhog

# 4. Configure (edit these two lines in ~/bin/groundhog)
#    REPO="$HOME/dev/copilot-skills"      ← your skills backup repo
#    SKILLS="$HOME/.copilot/skills"        ← default, probably don't change

# 5. Start watching (runs forever, survives reboots)
cp ~/dev/groundhog-day/com.dubsopenhub.groundhog.plist ~/Library/LaunchAgents/
# Edit the plist to match your home directory if not /Users/greggcochran
launchctl load ~/Library/LaunchAgents/com.dubsopenhub.groundhog.plist
```

That's it. Every skill you create, edit, or delete from this moment forward is automatically committed and pushed. Same thing, every time. 🐿️

---

## 🐿️ What It Does

![Reporting in](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExOG5tODIwcXBmZ2l3OWxnZ3pkbXQ1aThncXFyampuNm1nYmUwNzVveSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/sqmKjwp2T8iPkOtVcQ/giphy.gif)

Groundhog Day is a fully autonomous background agent that watches your `~/.copilot/skills/` directory in real time. Once installed, it requires zero interaction. It starts on boot, restarts if it crashes, and syncs every change without you ever touching it. The moment a file changes, it:

1. **Watches** — detects every create, edit, rename, and delete in real time
2. **Syncs** — rsyncs your skills to a version-controlled git repo
3. **Commits** — creates meaningful commits (detects new skills by name)
4. **Pushes** — sends it to GitHub with automatic retry on failure
5. **Catalogs** — auto-generates a README with a table of all your skills

No cron. No manual steps. No remembering. It just runs.

## 🐿️ What It Catches

| Scenario | Without Groundhog Day | With Groundhog Day |
|----------|----------------------|---------------------|
| Laptop dies | 💀 Skills gone forever | ✅ `git clone` on new machine |
| Accidentally delete a skill | 💀 Hope you remember what it said | ✅ `git revert` |
| Want to share a skill | 💀 Copy-paste from terminal | ✅ Send a repo link |
| New machine setup | 💀 Rebuild everything from scratch | ✅ One clone, done |
| "Wait, what did that skill look like last week?" | 💀 No idea | ✅ `git log -p` |

---

## 🐿️ Commands

```bash
groundhog              # One-shot sync right now
groundhog watch        # Start the real-time watcher
groundhog status       # Health check — is it running? Last sync?
```

## 🐿️ How It Works

```
~/.copilot/skills/          ~/dev/copilot-skills           GitHub
┌──────────────┐   fswatch   ┌──────────────┐   git push   ┌──────────────┐
│  SKILL.md    │ ──────────▶ │  SKILL.md    │ ──────────▶  │  SKILL.md    │
│  (local)     │   rsync     │  (git repo)  │   auto       │  (backed up) │
└──────────────┘             └──────────────┘               └──────────────┘
     you edit                  groundhog                      safe forever
```

- **fswatch** detects file changes in real time (5s debounce)
- **rsync** copies changes to the git working tree
- **git** commits and pushes with meaningful messages
- **macOS LaunchAgent** keeps it alive across reboots

## 🐿️ Built-In Safety

This isn't a quick script. Groundhog Day was stress-tested by two AI analysis agents before release:

🔬 **[Agent X-Ray](https://github.com/DUBSOpenHub/agent-xray)** performed a full security, reliability, and performance audit — identified 12 issues across 5 severity levels including a shell injection vector, race conditions, and data loss scenarios.

🚑 **[Grid-Medic](https://github.com/DUBSOpenHub/grid-medic)** independently diagnosed the same codebase, applied 8 fixes, validated each one, and verified the agent restarted cleanly after patching.

Every finding was fixed. Here's what's built in:

| Protection | What it prevents |
|-----------|-----------------|
| 🔒 Sync lock | Overlapping syncs corrupting git state |
| 🔄 Push retry (3x) | Network failures silently dropping commits |
| 🛡️ Empty source guard | `rsync --delete` wiping your repo if skills dir is empty |
| 🏥 Repo health check | Dirty state, rebase conflicts, or missing dirs breaking sync |
| 📋 Log rotation | Unbounded log growth eating your disk over months |
| 🧹 Graceful shutdown | Orphaned processes on SIGTERM |
| 🐍 Injection protection | Shell interpolation in Python calls |
| 🧲 Event drain | Redundant syncs from batched file events |

## 🐿️ Daily Checkup - 6 AM Automated Health Check

![6:00 AM](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdmRkdG16dW5mbnplc3RycmRzd256bDk4eGIxMHh5b21uNWoyN3BkeiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/U6vdotF6Hga2zdAtqf/giphy.gif)

Groundhog Day runs an automated health check every morning at 6:00 AM. It checks 9 things:

- Is the watcher process alive?
- Is the LaunchAgent loaded?
- Does the skills directory exist and have skills?
- Is the repo clean?
- Are all commits pushed?
- Is the repo stuck in a rebase?
- Any push failures or errors in the log?
- Is the log file a reasonable size?
- Is fswatch installed?

If anything is wrong, you get a macOS notification. The checkup tells you exactly what to run:

```
🚨 1 issue(s) found. Run grid-medic:
   → Open Copilot CLI and say:
     "grid-medic diagnose ~/bin/groundhog"
```

You can also run it manually anytime:

```bash
groundhog checkup
```

> **Re-run Agent X-Ray** after modifying the script to catch new security or reliability issues:
> Open Copilot CLI and say: *"X-ray ~/bin/groundhog for security, reliability, and performance"*

## 🐿️ Restore on a New Machine

Your laptop just died. Here's your 60-second recovery:

```bash
# On your new machine
git clone https://github.com/YOUR_USERNAME/my-copilot-skills.git /tmp/skills-restore
cp -R /tmp/skills-restore/*/ ~/.copilot/skills/
```

All your skills are back. Every single one. Like the crash never happened.

## 🐿️ FAQ

**Q: Does this work on Linux?**
A: The script works everywhere. The LaunchAgent plist is macOS-specific. On Linux, use a systemd unit or cron instead.

**Q: What if I'm offline?**
A: Changes are committed locally. The next time you're online, the push retry catches up.

**Q: Will it push secrets?**
A: Skills are prompt files (markdown). But `.env` and `.gitignore`'d files are excluded by default.

**Q: Can multiple people share a skills repo?**
A: Yes. Groundhog Day runs `git pull --rebase` before pushing, so it handles concurrent updates.

---

## Why "Groundhog Day"?

Same thing. Every time. It watches. It syncs. It pushes. It never stops. It never complains. It wakes up tomorrow and does it all again. 🐿️

---

## License

MIT

## 🐿️ Contributing

Found a bug or want to add a feature? PRs welcome. This is a tiny agent with one job — keep it simple.

---

🐙 Created with 💜 by [@DUBSOpenHub](https://github.com/DUBSOpenHub) with the [GitHub Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli).

Let's build! 🚀✨
