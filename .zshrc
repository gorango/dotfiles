ZSH_THEME="robbyrussell"

# eternal history
HISTSIZE='32768'
HISTFILESIZE="${HISTSIZE}"
HISTCONTROL='ignoreboth'
HISTFILE=~/.zsh_history

# faster terminal
NVM_LAZY_LOAD=true

# git clone https://github.com/zsh-users/zsh-autosuggestions ZSH_CUSTOM/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ZSH_CUSTOM/plugins/zsh-syntax-highlighting
# git clone https://github.com/lukechilds/zsh-nvm $ZSH_CUSTOM/plugins/zsh-nvm
# git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-nvm
  zsh-z
)

ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# fix sudo - can set root shell to `/bin/zsh` with `sudo chsh`
alias sudo='sudo '

# lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -la'
alias lt='ls --tree'

# misc terminal helpers

alias e='exit'
alias c='code . && e'
alias ca='code ~/a'
alias cs='code ~/s'

# ip + speed

alias myip='curl https://ipinfo.io/json'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# npm commands

alias s='nr start'
alias d='nr dev'
alias b='nr build'
alias bw='nr build --watch'
alias t='nr test'
alias tw='nr test --watch'
alias w='nr watch'
alias p='nr play'
alias lint='nr lint'
alias lintf='nr lint --fix'
alias release='nr release'
alias re='nr release'

# git commands

alias git=hub # Use github/hub
alias grt='cd "$(git rev-parse --show-toplevel)"' # Go to project root
alias gs='git status'
alias gp='git push'
alias gpf='git push --force'
alias gpft='git push --follow-tags'
alias gpl='git pull --rebase'
alias gcl='git clone'
alias gst='git stash'
alias grm='git rm'
alias gmv='git mv'
alias main='git checkout main'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gb='git branch'
alias gbd='git branch -d'
alias grb='git rebase'
alias grbom='git rebase origin/master'
alias grbc='git rebase --continue'
alias gl='git log'
alias glo='git log --oneline --graph'
alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'
alias ga='git add'
alias gA='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git add -A && git commit -m'
alias gcan='git add -A && git commit --amend --no-edit'
alias gfrb='git fetch origin && git rebase origin/master'
alias gxn='git clean -dn'
alias gx='git clean -df'
alias gsha='git rev-parse HEAD | pbcopy'
alias ghci='gh run list -L 1'

# git fns

function gd() {
  if [[ -z $1 ]] then
    git diff --color | diff-so-fancy
  else
    git diff --color $1 | diff-so-fancy
  fi
}

function pr() {
  if [ $1 = "ls" ]; then
    gh pr list
  else
    gh pr checkout $1
  fi
}

# directories

function m() {
  cd ~/m/$1
}

function repros() {
  cd ~/r/$1
}

function forks() {
  cd ~/f/$1
}

function dir() {
  mkdir $1 && cd $1
}

function clone() {
  if [[ -z $2 ]] then
    hub clone "$@" && cd "$(basename "$1" .git)"
  else
    hub clone "$@" && cd "$2"
  fi
}

function clonem() {
  m && clone "$@" && code . && cd ~2
}

function cloner() {
  repros && clone "$@" && code . && cd ~2
}

function clonef() {
  forks && clone "$@" && code . && cd ~2
}

# utilities

function serve() {
  if [[ -z $1 ]] then
    npx live-server dist
  else
    npx live-server $1
  fi
}

function compress() {
  tar -zcvf "${1}.tar.gz" $1
}

function extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)  tar -jxvf $1                        ;;
      *.tar.gz)   tar -zxvf $1                        ;;
      *.bz2)      bunzip2 $1                          ;;
      *.dmg)      hdiutil mount $1                    ;;
      *.gz)       gunzip $1                           ;;
      *.tar)      tar -xvf $1                         ;;
      *.tbz2)     tar -jxvf $1                        ;;
      *.tgz)      tar -zxvf $1                        ;;
      *.zip)      unzip $1                            ;;
      *.ZIP)      unzip $1                            ;;
      *.pax)      cat $1 | pax -r                     ;;
      *.pax.Z)    uncompress $1 --stdout | pax -r     ;;
      *.rar)      unrar x $1                          ;;
      *.Z)        uncompress $1                       ;;
      *)          echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

# devops

alias tf='terraform'
alias k='kubectl'
alias h="helm"

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

kn() {
    if [ "$1" != "" ]; then
	    kubectl config set-context --current --namespace=$1
    else
	    echo -e "\e[1;31m Error, please provide a valid Namespace\e[0m"
    fi
}

knd() {
    kubectl config set-context --current --namespace=default
}

ku() {
    kubectl config unset current-context
}

# kube-ps1
# source ~/.oh-my-zsh/custom/kube-ps1.zsh
PROMPT='$(kube_ps1)'$PROMPT
