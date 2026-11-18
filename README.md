#1 command line tool<br>
`xcode-select --install`<br>

#2 homebrew install<br>
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`<br>
`echo >> /Users/mew/.zprofile`<br>
`echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> /Users/mew/.zprofile`<br>
`eval "$(/opt/homebrew/bin/brew shellenv zsh)"`<br>

#3 brew反映<br>
`brew bundle dump`<br>
Brewfile をUser/Spidey/brewfileにコピペ<br>
`brew bundle`<br>

#4 Setting<br>
Network→Firewall→on<br>
Battery→Charging→optimize Charging up to 80%<br>
Appearance→Dark<br>
Desktop→Dock Left→remove all app from Dock<br>
Desktop→Dock & Stage Manger→Show items→on Desktop→off<br>
Desktop→Hot Corners→Bottom Left→Lock Screen<br>
Display→Preset→Apple XDR Display(P3 + Adobe RGB)<br>
Internet Account→add old account<br>
Keyboard→Key repeat rate/Delay until repeat→Fastest<br>
Keyboard→Text Input→Edit→Correct spelling automatically→off<br>
Trackpad→Tracking Speed→Fast<br>


#5 screenshot save<br>
`mkdir -p ~/Documents/screenshot`<br>
`defaults write com.apple.screencapture location ~/Documents/screenshot`<br>
`killall SystemUIServer`<br>
