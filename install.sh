#!/bin/bash
# 🐿️ Groundhog Day — one-line installer
# curl -fsSL https://raw.githubusercontent.com/DUBSOpenHub/groundhog-day/main/install.sh | bash

set -euo pipefail

echo "🐿️  Installing Groundhog Day..."
echo ""

# 1. Clone
INSTALL_DIR="$HOME/dev/groundhog-day"
if [[ -d "$INSTALL_DIR" ]]; then
  echo "Updating existing install..."
  cd "$INSTALL_DIR" && git pull --quiet
else
  git clone --quiet https://github.com/DUBSOpenHub/groundhog-day.git "$INSTALL_DIR"
fi

# 2. Install the script
mkdir -p "$HOME/bin"
cp "$INSTALL_DIR/groundhog" "$HOME/bin/groundhog"
chmod +x "$HOME/bin/groundhog"

# 3. Create skills backup repo if it doesn't exist
SKILLS_REPO="$HOME/dev/copilot-skills"
if [[ ! -d "$SKILLS_REPO" ]]; then
  echo ""
  echo "No skills backup repo found at $SKILLS_REPO."
  echo "Create one on GitHub first, then clone it:"
  echo ""
  echo "  gh repo create my-copilot-skills --public"
  echo "  git clone https://github.com/\$(gh api user -q .login)/my-copilot-skills.git $SKILLS_REPO"
  echo ""
  echo "Then re-run this installer."
  exit 0
fi

# 4. Install LaunchAgent (macOS only)
if [[ "$(uname)" == "Darwin" ]]; then
  PLIST="$HOME/Library/LaunchAgents/com.dubsopenhub.groundhog.plist"
  launchctl unload "$PLIST" 2>/dev/null || true

  # Generate plist with correct home dir
  cat > "$PLIST" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.dubsopenhub.groundhog</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/bin/groundhog</string>
        <string>watch</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/.groundhog.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/.groundhog.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
</dict>
</plist>
PLIST

  launchctl load "$PLIST"
  echo ""
  echo "🐿️  Groundhog Day is installed and watching!"
  echo ""
  echo "   Status:  groundhog status"
  echo "   Log:     tail -f ~/.groundhog.log"
  echo ""
  echo "   Same thing. Every time. 🐿️"
else
  echo ""
  echo "🐿️  Groundhog Day is installed at ~/bin/groundhog"
  echo ""
  echo "   Start it:  groundhog watch &"
  echo "   Status:    groundhog status"
  echo ""
  echo "   For auto-start on Linux, add a systemd unit or cron entry."
fi
