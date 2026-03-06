class GroundhogDay < Formula
  desc "🐿️ Autonomous backup agent for Copilot CLI skills"
  homepage "https://github.com/DUBSOpenHub/groundhog-day"
  url "https://github.com/DUBSOpenHub/groundhog-day/archive/refs/tags/v1.0.0.tar.gz"
  version "1.0.0"
  license "MIT"

  depends_on "fswatch"
  depends_on "git"
  depends_on "python@3"

  def install
    bin.install "groundhog"
  end

  def post_install
    ohai "🐿️ Groundhog Day installed!"
    ohai "Run 'groundhog watch' to start watching, or set up the LaunchAgent:"
    ohai "  cp #{prefix}/com.dubsopenhub.groundhog.plist ~/Library/LaunchAgents/"
    ohai "  launchctl load ~/Library/LaunchAgents/com.dubsopenhub.groundhog.plist"
  end

  def caveats
    <<~EOS
      🐿️ Groundhog Day needs a backup repo. Run the installer to set everything up:

        curl -fsSL https://raw.githubusercontent.com/DUBSOpenHub/groundhog-day/main/install.sh | bash

      Or configure manually:
        1. Create a repo: gh repo create my-copilot-skills --public
        2. Clone it: git clone https://github.com/YOU/my-copilot-skills.git ~/dev/copilot-skills
        3. Edit REPO= in #{bin}/groundhog
        4. Start: groundhog watch
    EOS
  end

  test do
    assert_match "Groundhog Day", shell_output("#{bin}/groundhog status 2>&1", 0)
  end
end
