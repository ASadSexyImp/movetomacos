#!/bin/bash
# mac-setup.sh : 新しいMacを一括セットアップ
# 使い方: bash mac-setup.sh   (最初にパスワードを1回聞かれます)

BREWFILE="$HOME/Brewfile"

echo "=== 0. sudo を最初に認証(以降は聞かれない) ==="
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "=== 1. Command Line Tools ==="
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  echo "ダイアログで「インストール」を押してください。完了まで待機します..."
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

echo "=== 2. Homebrew ==="
if ! command -v brew &>/dev/null && [ ! -x /opt/homebrew/bin/brew ]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
touch "$HOME/.zprofile"
grep -q 'brew shellenv' "$HOME/.zprofile" || \
  echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

echo "=== 3. Brewfile 作成 & 一括インストール ==="
cat > "$BREWFILE" <<'EOF'
# Mac App Store CLI
brew "mas"

# Utility apps
cask "google-chrome"
cask "karabiner-elements"           # Keyboard customizer
cask "raycast"                      # launcher and clipboard
cask "chatgpt"
cask "slack"
cask "discord"
cask "sf-symbols"                   # Apple design resource
cask "ark0n/tap/logolight"          # Back logo glow

# Fonts (Apple SF系)
cask "font-sf-pro"
cask "font-sf-mono"
cask "font-sf-compact"

# Apps for code
cask "docker"
cask "iterm2"
cask "visual-studio-code"
cask "utm"
cask "wireshark"
cask "raspberry-pi-imager"
cask "ollama"
cask "antigravity"
cask "claude"
cask "lm-studio"
cask "lm-studio-bionic"

# Creative apps
cask "touchdesigner"
cask "blender"
cask "epic-games"
cask "openframeworks"
cask "affinity"

# Mac App Store (App Storeにサインイン済みであること)
mas "Xcode", id: 497799835
mas "Yoink", id: 457622435
mas "Logic Pro", id: 634148309

# DaVinci Resolve と Houdini は手動インストール
EOF
# 一部失敗しても残りを続行する
brew bundle --file="$BREWFILE" || echo "!! 一部のインストールに失敗しました。上のログを確認してください"

echo "=== 4. システム設定 ==="
# Firewall on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Dark mode
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' \
  || defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Dock: 左配置 & アプリ全削除
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock persistent-apps -array

# デスクトップのアイテム表示 off
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true

# Hot Corner 左下 = Lock Screen
defaults write com.apple.dock wvous-bl-corner -int 13
defaults write com.apple.dock wvous-bl-modifier -int 0

# キーリピート最速(GUI最速と同じ値)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# スペル自動修正 off
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# トラックパッド速度 Fast
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3

echo "=== 5. スクリーンショット保存先 ==="
mkdir -p "$HOME/Documents/screenshot"
defaults write com.apple.screencapture location "$HOME/Documents/screenshot"

echo "=== 6. 反映 ==="
killall Dock Finder SystemUIServer 2>/dev/null || true

echo
echo "=== 完了。以下は手動で設定してください(設定画面を開きます) ==="
echo " - Battery → Charging → 80%に最適化"
echo " - Displays → Preset → Apple XDR Display (P3 + Adobe RGB)"
echo " - Internet Accounts → 旧アカウントを追加"
echo " - DaVinci Resolve / Houdini を手動インストール"
echo " - キーボード/トラックパッド設定は再ログイン後に反映"
open "x-apple.systempreferences:com.apple.Battery-Settings.extension"
open "x-apple.systempreferences:com.apple.Displays-Settings.extension"
open "x-apple.systempreferences:com.apple.Internet-Accounts-Settings.extension"
