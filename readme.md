# dotfiles

Debian workbench copy-pasta

<details>
<summary><code>pkgs</code></summary>

<hr>

```sh
sudo apt install \
curl git hub gh ripgrep xclip rename tmux fzf lsd tree neovim neofetch \
ffmpeg cloc vlc feh shotwell light xbacklight redshift autorandr
```
```sh
gh auth login
```
<br>
</details>

<details>
<summary><code>dirs</code></summary>

<hr>

```sh
mkdir ~/m ~/f ~/r ~/s ~/w # mine, forks, repros, sandbox, work
```
```sh
gh repo clone gorango/dotfiles ~/m/dotfiles
```
<br>
</details>

<details>
<summary><code>apps</code></summary>

<hr>

- [brave](#brave)
- [code](#code)
- [gitkraken](#gitkraken)

<hr>

### [brave](https://brave.com/linux/)

```sh
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt install brave-browser
```

### [code](https://code.visualstudio.com/Download)

```sh
wget --no-verbose -O /tmp/code.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
sudo apt install /tmp/code.deb
rm /tmp/code.deb
```

### [gitkraken](https://help.gitkraken.com/gitkraken-client/how-to-install/#deb)

```sh
wget --no-verbose -O /tmp/gitkraken.deb https://release.gitkraken.com/linux/gitkraken-amd64.deb
sudo apt install /tmp/gitkraken.deb
rm /tmp/gitkraken.deb
```

### chrome.96

```sh
wget --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_96.0.4664.93-1_amd64.deb
apt install -y /tmp/chrome.deb
rm /tmp/chrome.deb
```
<br>
</details>

<details>
<summary><code>cli</code></summary>

<hr>

- [zsh](#zsh)
- [antibody](#antibody)
- [zsh plugins](#zsh-plugins)
- [zoxide](#zoxide)

<hr>

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
git clone https://github.com/lukechilds/zsh-nvm $ZSH_CUSTOM/plugins/zsh-nvm
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
```

### [zoxide](https://github.com/ajeetdsouza/zoxide)

```sh
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
rm ~/.zcompdump*; compinit
```
<br>
</details>

<details>
<summary><code>wm</code></summary>

<hr>

- [i3](#i3)
- [i3-gnome](#i3-gnome)
- [theme](#theme)

<hr>

### [i3](https://i3wm.org/docs/)

```sh
sudo apt install i3
```

### [i3-gnome](https://github.com/i3-gnome/i3-gnome)

```sh
git clone https://github.com/i3-gnome/i3-gnome.git ~/Downloads && cd $_
sudo make install
```

### theme

```sh
sudo update-alternatives --config gdm3-theme.gresource
# select gnome-shell-theme.gresource
```
```sh
sudo vim /etc/gdm3/greeter.dconf-defaults
# [org/gnome/login-screen]
# logo=''
```

```sh
set org.gnome.Terminal.Legacy.Settings headerbar false
set org.gnome.Terminal.Legacy.Settings confirm-close false
```
<br>
</details>

<details>
<summary><code>langs</code></summary>

<hr>

- [python](#python-pyenv)
- [node](#node-nvm)
- [ruby](#ruby-rbenv)
- [rust](#rust)
- [go](#go)

<hr>

### python (pyenv)

```sh
curl https://pyenv.run | bash
pyenv install -v 3.10
pyenv global 3.10
```

### node (nvm)

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
npm i -g yarn nodemon pm2 tldr typescript eslint @antfu/ni diff-so-fancy
```

### ruby (rbenv)

```sh
sudo apt install rbenv
rbenv install 2.6.10
rbenv global 2.6.10
```

### rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### go

```sh
rm -rf /usr/local/go
curl https://golang.org/dl/go1.20.4.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -
```
<br>
</details>

<details>
<summary><code>dbs</code></summary>

<hr>

- [redis](#redis)
- [postgres](#postgres)

<hr>

### redis

```sh
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis
```

### postgres

```sh
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt install -y postgresql
```

<br>
</details>

<details>
<summary><code>utils</code></summary>

<hr>

- [docker](#docker)
- [lazygit](#lazygit)
- [terraform](#terraform)
- [helm](#helm)
- [kubernetes](#kubernetes)

<hr>

### docker

```sh
sudo apt install \
build-essential ca-certificates software-properties-common gnupg lsb-release apt-transport-https \
docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### lazygit

```sh
go install github.com/jesseduffield/lazygit@latest
```

### [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

```sh
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```
```sh
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```
```sh
sudo apt-get install terraform
```

### [helm](https://helm.sh/docs/intro/install/)

```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```


##### TOC:
- [kubectl](#kubectl)
- [kubectx](#kubectxkubens)
- [k9s](#k9s)

#### [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux)

```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

#### [kubectx+kubens](https://github.com/ahmetb/kubectx#manual-installation-macos-and-linux)

```sh
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
```

#### [k9s](https://github.com/derailed/k9s#installation)

```sh
go install github.com/derailed/k9s@latest
```
<br>
</details>

<details>
<summary><code>links</code></summary>

<hr>

### `$HOME`

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

### `$HOME/.config`

```sh
ln -sf ~/m/dotfiles/.config/i3 ~/.config/i3
ln -sf ~/m/dotfiles/.config/i3status ~/.config/i3status
ln -sf ~/m/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/m/dotfiles/.config/redshift ~/.config/redshift
ln -sf ~/m/dotfiles/.config/autostart ~/.config/autostart
ln -sf ~/m/dotfiles/.config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sf ~/m/dotfiles/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json
```
<br>
</details>
