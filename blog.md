# I Lost All My AI Skills. So I Built an Agent to Make Sure It Never Happens Again.

Every custom skill I'd built for Copilot CLI lived in one folder on my laptop: `~/.copilot/skills/`. No version history. No sync. No restore path. Weeks of prompt iteration, custom workflows, custom skills... all sitting in a single directory on a single machine.

I didn't think about it until I almost lost them.

## The folder nobody talks about

If you use [GitHub Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli) and you've built custom skills, you probably have the same setup. A growing collection of `SKILL.md` files, each one representing hours of testing and refinement. And all of them stored locally with no safety net.

```
~/.copilot/skills/
├── dark-factory/SKILL.md
├── pitch-master/SKILL.md
├── dispatch/SKILL.md
├── havoc-hackathon/SKILL.md
└── ... (however many you've built)
```

One spilled coffee. One failed drive. One stolen laptop. Gone.

## What if an agent just... handled it?

The fix felt obvious once I framed it: a tiny background process that watches the skills folder in real time, commits every change to git, and pushes to GitHub automatically. Set it up once, never think about it again.

So I built **Groundhog Day** 🐿️.

It uses tools that already exist on every Mac: `bash`, `fswatch`, `rsync`, and `git`. No npm packages. No pip dependencies. No Docker containers. One bash script, two LaunchAgent plists, and a one-line installer.

```bash
curl -fsSL https://raw.githubusercontent.com/DUBSOpenHub/groundhog-day/main/install.sh | bash
```

That's the entire setup. The installer detects your skills, creates a backup repo on your GitHub account, seeds it with your existing work, installs the watcher, and starts it. From that point on, every create, edit, rename, and delete is captured automatically.

## How it works

The architecture is intentionally boring:

```
~/.copilot/skills/          ~/dev/copilot-skills           GitHub
┌──────────────┐   fswatch   ┌──────────────┐   git push   ┌──────────────┐
│  SKILL.md    │ ──────────▶ │  SKILL.md    │ ──────────▶  │  SKILL.md    │
│  (local)     │   rsync     │  (git repo)  │   auto       │  (backed up) │
└──────────────┘             └──────────────┘               └──────────────┘
     you edit                  groundhog                      safe forever
```

`fswatch` watches for file system events. When something changes, it debounces for 5 seconds (to batch rapid edits), rsyncs the skills into a git working tree, commits with a meaningful message, and pushes. A macOS LaunchAgent keeps it alive across reboots. It starts on login, restarts if it crashes, and runs silently in the background.

The commit messages aren't just timestamps. When Groundhog Day detects a new skill, it names it:

```
add skill: pitch-master, dark-factory
```

And on every sync, it regenerates the repo's README with a table of all your skills pulled from their `SKILL.md` frontmatter. Your backup repo is always a clean, browsable catalog of everything you've built.

## The part where AI agents audited AI agent code

Here's where it gets interesting. I didn't just write a bash script and ship it. I pointed two other AI agents at it before release:

**Agent X-Ray** did a full security, reliability, and performance audit. It found 12 issues across 5 severity levels, including a shell injection vector in the Python README generator, race conditions from overlapping syncs, and a data loss scenario where `rsync --delete` could wipe the entire backup repo if the skills directory was empty.

**Grid-Medic** independently diagnosed the same codebase, applied 8 fixes, validated each one, and verified the agent restarted cleanly after patching.

The result is a set of protections that I wouldn't have thought to add on my own:

- **Sync lock** (directory-based, atomic on all filesystems) prevents overlapping git operations
- **Empty source guard** blocks rsync from running if the skills folder is missing or empty
- **Push retry with exponential backoff** handles network blips
- **Log rotation** caps the log at 1MB so it doesn't silently eat disk over months
- **Graceful shutdown** cleans up child processes on SIGTERM
- **Input sanitization** passes file paths via `sys.argv` instead of shell interpolation

Agents auditing agent code. It's a useful pattern. The code that protects your work was itself protected by the same kind of tools it's designed to safeguard.

## Nightly health check

Groundhog Day also runs an automated checkup every morning at 6 AM. It verifies 9 things: Is the watcher alive? Is the LaunchAgent loaded? Are there skills to protect? Is the repo clean? Are all commits pushed? Any rebase conflicts? Push failures in the log? Log file growing too large? Is `fswatch` still installed?

If anything fails, you get a macOS notification telling you exactly what's wrong and how to fix it:

```
🚨 1 issue(s) found. Run grid-medic:
   → Open Copilot CLI and say:
     "grid-medic diagnose ~/bin/groundhog"
```

You can also run `groundhog checkup` manually anytime.

## Recovery is boring (that's the point)

Your laptop just died. Here's what recovery looks like:

```bash
git clone https://github.com/YOUR_USERNAME/copilot-skills.git /tmp/skills-restore
cp -R /tmp/skills-restore/*/ ~/.copilot/skills/
```

Every skill is back. Every version of every skill is in the git history. Like the crash never happened.

## What I actually learned

The interesting part of this project wasn't the bash script. It was the realization that the most valuable AI artifacts I'm creating aren't code in repositories. They're prompt files in a local directory that no existing tool is designed to protect.

Skills are the new dotfiles. They represent your personal workflow, your approach to problem-solving, the specific way you've trained your tools to work with you. And right now, for most people using Copilot CLI, they have no version history, no sync, and no restore path.

Groundhog Day is [open source](https://github.com/DUBSOpenHub/groundhog-day). It's one bash script with one job. Same thing. Every time. 🐿️

---

*Built with [GitHub Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli). Audited by [Agent X-Ray](https://github.com/DUBSOpenHub/agent-xray) and [Grid-Medic](https://github.com/DUBSOpenHub/grid-medic).*
