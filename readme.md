# Dotfiles

## Setup

<details>
<summary>init</summary>

```sh
sudo apt install \
	git curl ripgrep rename hub tmux neovim neofetch \
	ffmpeg vlc feh shotwell \
	light xbacklight xclip redshift autorandr
```
</details>

<details>
<summary>zsh</summary>

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
```

plugins

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/lukechilds/zsh-nvm $ZSH_CUSTOM/plugins/zsh-nvm
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
```
</details>

<details>
<summary>node</summary>

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
npm i -g @antfu/ni @jarred/git-peek eslint nodemon pm2 typescript yarn
```
</details>

<details>
<summary>rust</summary>

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install lsd
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
<summary>docker</summary>

```sh
sudo apt install \
	build-essential ca-certificates software-properties-common gnupg lsb-release apt-transport-https \
	docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
</details>

---

## Configs

```sh
mkdir m f r s w && cd m
git clone https://github.com/gorango/dotfiles
```

<details>
<summary>symlinks</summary>

`~`

```sh
ln -s ~/m/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/m/dotfiles/.hushlogin ~/.hushlogin
ln -s ~/m/dotfiles/.profile ~/.profile
ln -s ~/m/dotfiles/.xprofile ~/.xprofile
ln -s ~/m/dotfiles/.device ~/.device
ln -s ~/m/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -s ~/m/dotfiles/tmux/bin/tmux-sessionizer ~/.local/bin/tmux-sessionizer
ln -s ~/m/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/m/dotfiles/zsh/custom/* ~/.oh-my-zsh/custom
```

`~/.config`

```sh
ln -s ~/m/dotfiles/.config/i3 ~/.config/i3
ln -s ~/m/dotfiles/.config/i3status ~/.config/i3status
ln -s ~/m/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/m/dotfiles/.config/redshift ~/.config/redshift
ln -s ~/m/dotfiles/.config/autostart ~/.config/autostart
ln -sf ~/m/dotfiles/.config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sf ~/m/dotfiles/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json
```
</details>
