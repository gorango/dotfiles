# dotfiles

### Setup

<details>
<summary>dirs</summary>

```sh
mkdir ~/m ~/f ~/r ~/s ~/w
git clone https://github.com/gorango/dotfiles ~/m/dotfiles
```
</details>

---

### Install

<details>
<summary>init</summary>

```sh
sudo apt install \
	curl git hub ripgrep xclip rename tmux fzf lsd tree neovim neofetch \
	ffmpeg vlc feh shotwell light xbacklight redshift autorandr
```
</details>

<details>
<summary>terminal</summary>

zsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
```

zsh plugins

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/lukechilds/zsh-nvm $ZSH_CUSTOM/plugins/zsh-nvm
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
```

zoxide

```sh
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
rm ~/.zcompdump*; compinit
```
</details>

<details>
<summary>i3wm</summary>

```sh
sudo apt install i3
git clone https://github.com/i3-gnome/i3-gnome.git ~/Downloads
cd ~/Downloads/i3-gnome
sudo make install
```

```sh
sudo update-alternatives --config gdm3-theme.gresource
# select gnome-shell-theme.gresource
sudo vim /etc/gdm3/greeter.dconf-defaults
# [org/gnome/login-screen]
# logo=''
```

```sh
set org.gnome.Terminal.Legacy.Settings headerbar false
set org.gnome.Terminal.Legacy.Settings confirm-close false
```
</details>

<details>
<summary>languages</summary>

rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

go

```sh
cd ~/Downloads
curl -OL https://golang.org/dl/go1.20.4.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
```

python (pyenv)

```sh
curl https://pyenv.run | bash
pyenv install -v 3.10
pyenv global 3.10
```

node (nvm)

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
# node globals
npm i -g @antfu/ni diff-so-fancy eslint nodemon pm2 typescript yarn
```

ruby (rbenv)

```sh
sudo apt install rbenv
rbenv install 2.6.10
rbenv global 2.6.10
```
</details>

<details>
<summary>utilities</summary>

docker

```sh
sudo apt install \
	build-essential ca-certificates software-properties-common gnupg lsb-release apt-transport-https \
	docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

lazygit

```sh
go install github.com/jesseduffield/lazygit@latest
```
</details>

---

### Configs

<details>
<summary>symlinks</summary>

`~`

```sh
ln -sf ~/m/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/m/dotfiles/.hushlogin ~/.hushlogin
ln -sf ~/m/dotfiles/.profile ~/.profile
ln -s ~/m/dotfiles/.xprofile ~/.xprofile
ln -s ~/m/dotfiles/.device ~/.device
ln -sf ~/m/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -s ~/m/dotfiles/tmux/bin/tmux-sessionizer ~/.local/bin/tmux-sessionizer
ln -sf ~/m/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/m/dotfiles/zsh/custom/* ~/.oh-my-zsh/custom
```

`~/.config`

```sh
ln -sf ~/m/dotfiles/.config/i3 ~/.config/i3
ln -sf ~/m/dotfiles/.config/i3status ~/.config/i3status
ln -sf ~/m/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/m/dotfiles/.config/redshift ~/.config/redshift
ln -sf ~/m/dotfiles/.config/autostart ~/.config/autostart
ln -sf ~/m/dotfiles/.config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sf ~/m/dotfiles/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json
```
</details>
