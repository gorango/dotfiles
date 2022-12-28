# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Eternal bash history
# export HISTFILESIZE=
# export HISTSIZE=
# export HISTTIMEFORMAT="[%F %T] "
# export HISTFILE=~/.bash_eternal_history
# PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code'
fi

# Node Version Manager
export NVM_LAZY_LOAD=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# npm@7 use npx default yes to download
export NPM_CONFIG_YES=true

# pnpm
export PNPM_HOME="/home/goga/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Yarn global location
export PATH="$(yarn global bin --offline):$PATH"

# Python Version Manager
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"-e

# Python Version Manager
eval "$(pyenv init --path)"

# kensington trackball config
eval "~/trackball.sh"

# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/goga/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/goga/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/goga/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/goga/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# Tmuxinator completion
source ~/gems/gems/tmuxinator-3.0.1/completion/tmuxinator.zsh

# Nix
if [ -e /home/goga/.nix-profile/etc/profile.d/nix.sh ]; then . /home/goga/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# deno
export DENO_INSTALL="/home/goga/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# rust
. "$HOME/.cargo/env"

# go
export PATH=$PATH:/usr/local/go/bin

# kubectl krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# surreal db
export PATH=/home/goga/.surrealdb:$PATH
