# Workbench copy-pasta

Restore Linux Arch with EndeavourOS i3wm desktop environment.

## Init

---

```sh
sudo pacman -Sy \
  base-devel \
  python \
  cmake \
  protobuf \
  gcc \
  distutils \
  python-setuptools \
  curl \
  flatpak \
  alacritty \
  zsh \
  tmux \
  neovim \
  blueman \
  ripgrep \
  fzf \
  fd \
  lsd \
  bc \
  bat \
  xclip \
  xdotool \
  maim \
  tree \
  rename \
  neofetch \
  baobab \
  ffmpeg \
  vlc \
  playerctl \
  feh \
  shotwell \
  imagemagick \
  poppler-utils \
  xbacklight \
  brightnessctl \
  redshift \
  imagemagick \
  pandoc \
  fonts-powerline \
  xbindkeys \
  jq \
  git \
  github-cli \
  hub \
  lazygit \
  cloc \
  gource \
  xvfb \
  sqlite3 \
  picom \
  speedtest-cli
```

## Window Manager

### tmux

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

To install plugins in tmux: `C-b I` or `~/.tmux/plugins/tpm/scripts/install_plugins.sh`.
To update all plugins: `C-b U` or `~/.tmux/plugins/tpm/scripts/update_plugin.sh`.

## CLI

### [zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### [antibody](https://getantibody.github.io/install/)

```sh
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
```

### zsh plugins

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
```

### [zoxide](https://github.com/ajeetdsouza/zoxide)

```sh
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
rm ~/.zcompdump*; compinit
```

### [nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

JetBrainsMono

```sh
cd ~/Downloads
nf_redirect=$(curl -s -L -w "%{url_effective}" -o /dev/null "https://github.com/ryanoasis/nerd-fonts/releases/latest")
nf_version=$(echo "$nf_redirect" | grep -oP 'tag/v\K[^/]+')
nf_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${nf_version}/JetBrainsMono.zip"
wget $nf_url
unzip JetBrainsMono.zip -d nerd-fonts
mkdir -p ~/.local/share/fonts
cp nerd-fonts/JetBrainsMonoNerdFont-Medium.ttf ~/.local/share/fonts
fc-cache -f -v
```

### [paru](https://github.com/Morganamilo/paru)

```sh
sudo pacman -S --needed base-devel
cloner https://aur.archlinux.org/paru.git
makepkg -si
```

## Languages

### python (pyenv)

```sh
curl https://pyenv.run | bash
pyenv install -v 3.10
pyenv global 3.10
```

#### [pipx](https://pipx.pypa.io/stable/)

```sh
sudo pacman -Sy python-pipx
pipx ensurepath
sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
```

##### packages

```sh
pipx install httpstat httpie
```

#### [poetry](https://python-poetry.org/docs/)

```sh
curl -sSL https://install.python-poetry.org | python3 -
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry
```

### node (fnm)

```sh
curl -fsSL https://fnm.vercel.app/install | bash
fnm install --lts
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm add -g \
  nodemon pm2 turbo typescript eslint @antfu/ni diff-so-fancy \
  tldr gtop live-server
```

### deno

```sh
curl -fsSL https://deno.land/install.sh | sh
```

### go

```sh
sudo pacman -Sy go
```

### rust

```sh
sudo pacman -Sy rust
```

#### packages

```sh
cargo install htmlq # jq for html https://github.com/mgdm/htmlq
cargo install nu # nushell https://github.com/nushell/nushell
curl -fsSL https://bodo.run/yek.sh | bash # yek https://github.com/bodo-run/yek
```

### ruby (rbenv)

```sh
sudo pacman -Sy ruby
sudo gem install jekyll bundler
```

## Database

### redis

```sh
sudo pacman -Sy redis
```

```sh
# (Optional) Start at boot
sudo systemctl enable redis-server.service
```

```sh
pnpm i -g redis-commander
```

### postgres

```sh
sudo pacman -Sy postgresql
```

```sh
# Run elevated as user
sudo -u postgres -i
createuser --interactive g
psql -U postgres -d postgres -c "create database g"
```

#### [dbeaver](https://dbeaver.io/)

```sh
sudo pacman -Sy dbeaver
```

## Utilities

### aws

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### [zsa](https://configure.zsa.io/udev)

```sh
sudo touch /etc/udev/rules.d/50-zsa.rules
```

```sh
# Rules for Oryx web flashing and live training
KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

# Legacy rules for live training over webusb (Not needed for firmware v21+)
  # Rule for all ZSA keyboards
  SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
  # Rule for the Moonlander
  SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
  # Rule for the Ergodox EZ
  SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
  # Rule for the Planck EZ
  SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

# Wally Flashing rules for the Ergodox EZ
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

# Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
# Keymapp Flashing rules for the Voyager
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
```

```sh
sudo groupadd plugdev
sudo usermod -aG plugdev $USER
```

#### [stripe](https://stripe.com/docs/stripe-cli)

```sh
curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor | sudo tee /usr/share/keyrings/stripe.gpg
echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | sudo tee -a /etc/apt/sources.list.d/stripe.list
sudo apt update
sudo apt install stripe
```

#### [pup](https://github.com/ericchiang/pup#pup)

```sh
go install github.com/ericchiang/pup@latest
```

#### [yq](https://github.com/mikefarah/yq/#install)

```sh
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
```

#### [yt-dlp](https://github.com/yt-dlp/yt-dlp)

```sh
sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux
sudo mv yt-dlp_linux /usr/local/bin/yt-dlp
sudo chmod +x /usr/local/bin/yt-dlp
```

#### [btop](https://github.com/aristocratos/btop)

```sh
sudo wget https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz
tar -xvf btop-x86_64-linux-musl.tbz
cd btop-x86_64-linux-musl
sudo make install
cd ..
rm -rf btop*
ln -sf ~/m/dotfiles/.config/btop/btop.conf ~/.config/btop/btop.conf
```

#### [opencode](https://github.com/sst/opencode)

```sh
curl -fsSL https://opencode.ai/install | bash
```

## Applications

### [brave](https://brave.com/linux/)

```sh
curl -fsS https://dl.brave.com/install.sh | sh
```

### discord

```sh
sudo pacman -Sy discord
```

### vlc [?](https://askubuntu.com/a/263308)

```
Tools > Preferences

Display > Output = X11 video output (XCB)
```

### obsidian

```sh
flatpak install flathub md.obsidian.Obsidian
```

## Battery Health

```sh
ln -sf ~/m/dotfiles/bin/battery ~/.local/bin/battery
mkdir -p ~/.config/systemd/user/
ln -sf ~/m/dotfiles/.config/systemd/user/battery-threshold.service ~/.config/systemd/user/battery-threshold.service
```

```sh
# enable service
systemctl --user daemon-reload
systemctl --user enable --now battery-threshold.service
# check status
systemctl --user status battery-threshold.service
```

## Directories

```sh
# archives, forks, mine, repros, sandbox, work
mkdir ~/m ~/f ~/r 
mv ~/Desktop ~/a
mv ~/Downloads ~/d
mv ~/Documents ~/o
mv ~/Pictures ~/p
mv ~/Videos ~/v

ln -sf ~/m/dotfiles/user-dirs.dirs ~/.config/user-dirs.dirs
```

```sh
gh repo clone gorango/dotfiles ~/m/dotfiles
```

GitHub Auth

```sh
gh auth login
```

```sh
~/.ssh
ssh-keygen -t ed25519 -C "gospaso@gmail.com" -f gh
ssh-add gh
cat gh.pub
```

GitHub CLI Copilot

```sh
gh extension install github/gh-copilot
```

DNS Masq

```sh
v /etc/dnsmasq.conf
address=/example.com/127.0.0.1#3333
```

[Add new SSH key](https://github.com/settings/ssh/new)

## Links

### `$HOME`

```sh
touch ~/.secret # for secret env vars sourced by zsh
ln -sf ~/m/dotfiles/.profile ~/.profile
ln -sf ~/m/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/m/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/m/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/m/dotfiles/zsh/custom/fns.zsh ~/.oh-my-zsh/custom/fns.zsh
ln -s ~/m/dotfiles/zsh/custom/git.zsh ~/.oh-my-zsh/custom/git.zsh
ln -s ~/m/dotfiles/.hushlogin ~/.hushlogin
ln -s ~/m/dotfiles/.xprofile ~/.xprofile
ln -s ~/m/dotfiles/.xbindkeysrc ~/.xbindkeysrc
ln -s ~/m/dotfiles/.device ~/.device
ln -s ~/m/dotfiles/bin/tmux-sessionizer ~/.local/bin/tmux-sessionizer
ln -s ~/m/dotfiles/bin/.tmux-sessionizer-targets ~/.tmux-sessionizer-targets
ln -s ~/m/dotfiles/bin/cht.sh ~/.local/bin/cht.sh
ln -s ~/m/dotfiles/bin/.cht-command ~/.cht-command
ln -s ~/m/dotfiles/bin/.cht-languages ~/.cht-languages
ln -s ~/m/dotfiles/bin/find-and-replace ~/.local/bin/fr
ln -s ~/m/dotfiles/bin/calc ~/.local/bin/calc
ln -s ~/m/dotfiles/bin/mouse ~/.local/bin/mouse
ln -s ~/m/dotfiles/bin/mousegrid ~/.local/bin/mousegrid
ln -s ~/m/dotfiles/bin/videos ~/.local/bin/videos
ln -s ~/m/dotfiles/bin/slides ~/.local/bin/slides
ln -s ~/m/dotfiles/.xbindkeysrc ~/.xbindkeysrc
```

### `$HOME/.config`

```sh
ln -sf ~/m/dotfiles/.config/i3 ~/.config/i3
ln -sf ~/m/dotfiles/p/1x1#000000.jpg ~/p/1x1#000000.jpg
ln -sf ~/m/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/m/dotfiles/.config/redshift ~/.config/redshift
ln -sf ~/m/dotfiles/.config/lazygit/config.yml ~/.config/lazygit/config.yml
ln -sf ~/m/dotfiles/.config/picom/config.conf ~/.config/picom/picom.conf
ln -sf ~/m/dotfiles/.config/btop/btop.conf ~/.config/btop/btop.conf
```
