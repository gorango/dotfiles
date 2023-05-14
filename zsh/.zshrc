ZSH_THEME="robbyrussell"

HISTSIZE='32768'
HISTFILESIZE="${HISTSIZE}"
HISTCONTROL='ignoreboth'
HISTFILE=~/.zsh_history

GIT_TERMINAL_PROMPT=1 # gh auth
GDK_SCALE=1 # 4k display in i3

plugins=(
	git
	zsh-autosuggestions      # https://github.com/zsh-users/zsh-autosuggestions
	zsh-syntax-highlighting  # https://github.com/zsh-users/zsh-syntax-highlighting.git
	zsh-nvm                  # https://github.com/lukechilds/zsh-nvm
	zsh-z                    # https://github.com/agkozak/zsh-z
)

# antibody
source <(antibody init)
antibody bundle < ~/.zsh_plugins.txt # https://github.com/ahmetb/kubectx

#source after plugins
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# kensington trackball config
eval "~/.device/trackball.sh"

# fix sudo - can set root shell to `/bin/zsh` with `sudo chsh`
alias sudo='sudo '

# nvm
alias vim='nvim'
alias vi='nvim'
alias v='nvim .'

# lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -la'
alias lt='ls --tree'

# terminal commands
alias e='exit'
alias c='code . && e'
alias ca='code ~/a'
alias cs='code ~/s'

# npm commands
alias s='nr start'
alias d='nr dev'
alias b='nr build'
alias bw='nr build --watch'
alias t='nr test'
alias tw='nr test --watch'
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
alias ac='auto-commit'

# supabase
alias supabase='node_modules/.bin/supabase'
alias sb='supabase'
