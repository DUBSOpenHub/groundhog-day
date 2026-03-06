# 🐿️ Groundhog Day

**Your laptop will crash. Your skills won't.**

![Groundhog Day](https://media.giphy.com/media/jpQm5h8UAW7gPAB5Wp/giphy.gif)

---

> *"I built 12 custom skills over three months. Terminal prompts, workflow automations, things that took real iteration to get right. Then my laptop died. All of it — gone."*
>
> That's a real story. From this week.
>
> Copilot CLI skills live in `~/.copilot/skills/`. That's a local directory. No cloud sync. No version history. No backup. One bad day and months of work vanishes.
>
> **Groundhog Day exists so that never happens to you.**

---

## ⚡ Quick Install

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

## What It Does

Groundhog Day is a background agent that watches your `~/.copilot/skills/` directory in real time. The moment a file changes, it:

1. **Syncs** — rsyncs your skills to a local git repo
2. **Commits** — creates a meaningful commit (detects new skills by name)
3. **Pushes** — sends it to GitHub with retry logic
4. **Regenerates** — auto-updates the README with a skill catalog table

No cron. No manual steps. No remembering. It just runs.

## What It Catches

| Scenario | Without Groundhog Day | With Groundhog Day |
|----------|----------------------|---------------------|
| Laptop dies | 💀 Skills gone forever | ✅ `git clone` on new machine |
| Accidentally delete a skill | 💀 Hope you remember what it said | ✅ `git revert` |
| Want to share a skill | 💀 Copy-paste from terminal | ✅ Send a repo link |
| New machine setup | 💀 Rebuild everything from scratch | ✅ One clone, done |
| "Wait, what did that skill look like last week?" | 💀 No idea | ✅ `git log -p` |

---

## Commands

```bash
groundhog              # One-shot sync right now
groundhog watch        # Start the real-time watcher
groundhog status       # Health check — is it running? Last sync?
```

## How It Works

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

## Built-In Safety

Groundhog Day was hardened by running it through a full agent X-ray and grid-medic analysis. It's not a quick script — it's production infrastructure:

- 🔒 **Sync lock** — prevents overlapping syncs from corrupting git state
- 🔄 **Push retry** — 3 attempts with exponential backoff; macOS notification on failure
- 🛡️ **Empty source protection** — won't wipe your repo if the skills dir is empty
- 🏥 **Repo health checks** — detects dirty state, rebase conflicts, missing dirs
- 📋 **Log rotation** — auto-rotates at 1MB so logs don't eat your disk
- 🧹 **Clean shutdown** — traps SIGTERM for graceful exit
- 🐍 **No injection risk** — Python calls use argv, not shell interpolation

## Restore on a New Machine

Your laptop just died. Here's your 60-second recovery:

```bash
# On your new machine
git clone https://github.com/YOUR_USERNAME/my-copilot-skills.git /tmp/skills-restore
cp -R /tmp/skills-restore/*/ ~/.copilot/skills/
```

All your skills are back. Every single one. Like the crash never happened.

## FAQ

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

## Contributing

Found a bug or want to add a feature? PRs welcome. This is a tiny agent with one job — keep it simple.
