ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX="true" 

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
	zsh-z                    # https://github.com/agkozak/zsh-z
)

# antibody
source <(antibody init)
antibody bundle < ~/.zsh_plugins.txt # https://github.com/ahmetb/kubectx

#source after plugins
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh
source $HOME/.profile

eval "$(z init zsh)" # zoxide
eval "$(fnm env --use-on-cd)"
eval "$(gh copilot alias -- zsh)" # github copilot

# fix sudo - can set root shell to `/bin/zsh` with `sudo chsh`
alias sudo='sudo '

# neovim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# secret private env
if [ -f ~/.secret ]; then
    source ~/.secret
fi

# lsd
alias ls='lsd'
alias l='ls -a'
alias la='ls -la'
alias lt='ls --tree -I .git -I node_modules -I dist -I coverage'

#tree
alias tree='tree -I ".git|node_modules|dist|coverage|fixtures"'

# terminal commands
alias e='exit'
alias x='tmux'
alias lg='lazygit'
alias d='pnpm dev'
alias supabase='node_modules/.bin/supabase'

# chrome
alias cs='google-chrome --simulate-outdated-no-au="2099/12/31" >/dev/null 2>&1 & disown && exit'

# tmux
if [ -n "$TMUX" ]; then
	bindkey -s ^f 'tmux neww tmux-sessionizer\n'
else
	bindkey -s ^f 'tmux-sessionizer\n'
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
