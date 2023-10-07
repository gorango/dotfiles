# dotfiles

Debian workbench copy-pasta

<details>
<summary><code>init</code></summary>

<hr>

```sh
sudo apt install -y \
	build-essential ca-certificates software-properties-common gnupg lsb-release apt-transport-https \
	curl ripgrep neovim fzf fd-find lsd xclip xdotool maim tree rename neofetch \
	ffmpeg vlc feh shotwell light xbacklight redshift autorandr \
	pandoc lynx fonts-powerline xbindkeys jq \
	git hub gh cloc gource xvfb
```

<br>
</details>

<details>
<summary><code>wm</code></summary>

<hr>

- [i3](#i3)
- [i3-gnome](#i3-gnome)
- [theme](#theme)
- [tmux](#tmux)

<hr>

### [i3](https://i3wm.org/docs/)

```sh
sudo apt install -y i3
```

### [i3-gnome](https://github.com/i3-gnome/i3-gnome)

```sh
git clone https://github.com/i3-gnome/i3-gnome.git /tmp/i3-gnome && cd $_
sudo make install
rm /tmp/i3-gnome -rf
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

### tmux

```sh
sudo apt install libevent-dev libncurses-dev
VERSION=3.3a
wget https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
tar xf tmux-${VERSION}.tar.gz
rm -f tmux-${VERSION}.tar.gz
cd tmux-${VERSION}
./configure
make
sudo make install
cd -
sudo rm -rf /usr/local/src/tmux-\*
sudo mv tmux-${VERSION} /usr/local/src
```

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

To install plugins in tmux: `C-b I` or `~/.tmux/plugins/tpm/scripts/install_plugins.sh`.
To update all plugins: `C-b U` or `~/.tmux/plugins/tpm/scripts/update_plugin.sh`.


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
npm i -g \
	yarn nodemon pm2 turbo typescript eslint @antfu/ni diff-so-fancy \
	tldr gtop live-server
```

### ruby (rbenv)

```sh
sudo apt install -y rbenv
rbenv install 2.6.10
rbenv global 2.6.10
```

### rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### go

```sh
curl https://golang.org/dl/go1.20.4.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -
```

<br>
</details>

<details>
<summary><code>dbs</code></summary>

<hr>

- [redis](#redis)
- [mongo](#mongo)
- [postgres](#postgres)

<hr>

### redis

```sh
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt update
sudo apt install -y redis
```
```sh
# (Optional) Start at boot
sudo systemctl enable redis-server.service
```
```sh
npm i -g redis-commander
```

### mongo

```sh
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
	sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
	--dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```
```sh
# (Optional) Start at boot
sudo systemctl enable mongod
```

### postgres

```sh
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql
```

```sh
# Remove local password requirements
sudo vim /etc/postgresql/15/main/pg_hba.conf # update IPv4/6 METHOD to trust
pg_ctl reload
```

```sh
# Run elevated as user
sudo -u postgres -i
createuser --interactive go
psql -c "create database go"
```

#### pgadmin

```sh
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt install -y pgadmin4
sudo /usr/pgadmin4/bin/setup-web.sh
```

#### extensions

```sh
sudo apt install libpq-dev postgresql-server-dev-15
```

#### [`pg_hashids`](https://github.com/iCyberon/pg_hashids)

```sh
git clone https://github.com/iCyberon/pg_hashids /tmp/pg_hashids && cd $_
USE_PGXS=1 sudo make
USE_PGXS=1 sudo make install
rm /tmp/pg_hashids -rf
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
- [misc](#misc)

<hr>

### docker

```sh
sudo apt install -y \
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
sudo apt update
sudo apt install -y terraform
```

### [helm](https://helm.sh/docs/intro/install/)

```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```


### kubernetes

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
curl -sS https://webinstall.dev/k9s | bash
```

### misc

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

<br>
</details>

<details>
<summary><code>apps</code></summary>

<hr>

- [brave](#brave)
- [discord](#discord)
- [vlc](#vlc)
- [chrome.90](#chrome90)
- [obsidian](#obsidian)

<hr>

### [brave](https://brave.com/linux/)

```sh
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt install -y brave-browser
```

### discord

```sh
wget --no-verbose -O /tmp/discord.deb https://discord.com/api/download?platform=linux&format=deb
sudo apt install -y /tmp/discord.deb
rm /tmp/discord.deb
```

### vlc [?](https://askubuntu.com/a/263308)

```
Tools > Preferences

Display > Output = X11 video output (XCB)
```

### chrome.90

```sh
wget --no-verbose -O /tmp/chrome.deb https://www.slimjet.com/chrome/download-chrome.php?file=files%2F90.0.4430.72%2Fgoogle-chrome-stable_current_amd64.deb
sudo apt install -y --allow-downgrades /tmp/chrome.deb
rm /tmp/chrome.deb
```

```sh
sudo apt-mark hold google-chrome-stable # prevent auto-updates
```

```sh
google-chrome --simulate-outdated-no-au='2099/12/31' >/dev/null 2>&1 & # open without update prompts
```

### obsidian

```sh
curl -s https://obsidian.md/download \
	| pup 'a:contains("Deb") attr{href}' \
	| xargs wget --no-verbose -O /tmp/obsidian.deb
sudo apt install -y /tmp/obsidian.deb
rm /tmp/obsidian.deb
```

<br>
</details>

<details>
<summary><code>dirs</code></summary>

<hr>

```sh
# archives, forks, mine, repros, sandbox, work
mkdir ~/a ~/f ~/m ~/r ~/s ~/w
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

[Add new SSH key](https://github.com/settings/ssh/new)

<br>
</details>

<details>
<summary><code>links</code></summary>

<hr>

### `$HOME`

```sh
ln -sf ~/m/dotfiles/.profile ~/.profile
ln -sf ~/m/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/m/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/m/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/m/dotfiles/zsh/custom/* ~/.oh-my-zsh/custom
ln -s ~/m/dotfiles/.hushlogin ~/.hushlogin
ln -s ~/m/dotfiles/.xprofile ~/.xprofile
ln -s ~/m/dotfiles/.device ~/.device
ln -s ~/m/dotfiles/bin/tmux-sessionizer ~/.local/bin/tmux-sessionizer
ln -sf ~/m/dotfiles/bin/cht.sh ~/.local/bin/cht.sh
ln -sf ~/m/dotfiles/bin/.cht-command ~/.cht-command
ln -sf ~/m/dotfiles/bin/.cht-languages ~/.cht-languages
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

### `$HOME/Downloads`

```sh
ln -s ~/Downloads ~/d
```

### `fd`

```sh
ln -s $(which fdfind) ~/.local/bin/fd
```

<br>
</details>
