# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# kensington trackball config
eval "~/.device/trackball.sh"

# nix
if [ -e /home/go/.nix-profile/etc/profile.d/nix.sh ]; then . /home/go/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# rust
. "$HOME/.cargo/env"

# go
export PATH=$PATH:/usr/local/go/bin

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# nvm
export NVM_LAZY_LOAD=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export NPM_CONFIG_YES=true # npx default yes to download

# pnpm
export PNPM_HOME="/home/go/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# yarn
export PATH="$(yarn global bin --offline):$PATH"

# pg
export PATH="$PATH:/usr/lib/postgresql/15/bin"

# envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
