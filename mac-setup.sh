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
# ==================================================
# Brewfile (カテゴリ別)  ※ "# " で始まる行は未インストール候補
# ==================================================

# ---------- 0. 基盤 ----------
brew "mas"                          # Mac App Store CLI

# ---------- 1. AI: チャット / アシスタント ----------
cask "chatgpt"                      # ChatGPT
cask "claude"                       # Claude
cask "google-gemini"                # Gemini (Option+Space が Raycast と競合)

# ---------- 2. AI: ローカルLLM ----------
cask "ollama-app"                   # Ollama (旧 cask "ollama")
cask "lm-studio"                    # LM Studio
cask "lm-studio-bionic"             # LM Studio agent (エラーなら削除)

# ---------- 3. AI: コーディング ----------
cask "antigravity"                  # Google Antigravity
# cask "claude-code"                # Claude Code (CLI)
# brew "gemini-cli"                 # Gemini CLI

# ---------- 4. 開発ツール ----------
cask "visual-studio-code"           # エディタ
cask "iterm2"                       # ターミナル
cask "docker"                       # 仮想開発環境
cask "utm"                          # 仮想マシン
cask "wireshark"                    # ネットワーク解析
cask "raspberry-pi-imager"          # Raspberry Pi SDカード書き込み
mas "Xcode", id: 497799835          # Apple開発ツール

# ---------- 5. クリエイティブ: 3D / ジェネラティブ / ゲーム ----------
cask "touchdesigner"                # ビジュアルプログラミング / VJ
cask "openframeworks"               # C++ クリエイティブコーディング
cask "blender"                      # 3Dモデリング / アニメ
cask "epic-games"                   # Unreal Engine ランチャー
# DaVinci Resolve / Houdini は手動インストール

# ---------- 6. クリエイティブ: デザイン / 音楽 ----------
cask "affinity"                     # Affinity
mas "Logic Pro", id: 634148309      # 音楽制作

# ---------- 7. フォント / デザインリソース ----------
cask "sf-symbols"                   # Apple SFシンボル
cask "font-sf-pro"
cask "font-sf-mono"
cask "font-sf-compact"

# ---------- 8. 生産性 / コミュニケーション ----------
cask "google-chrome"
cask "raycast"                      # ランチャー + クリップボード履歴
cask "karabiner-elements"           # キーボードカスタマイズ
mas "Yoink", id: 457622435          # ドラッグ&ドロップの一時置き場
cask "slack"
cask "discord"

# ---------- 9. ビジュアル系ユーティリティ ----------
cask "ark0n/tap/logolight"          # 背面ロゴ発光

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
