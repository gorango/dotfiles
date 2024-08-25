# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export TERM='xterm-256color'

# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# nvim
export PATH="$PATH:/opt/nvim-linux64/bin"

# kensington trackball config
eval "~/.device/trackball.sh"

# nix
if [ -e /home/go/.nix-profile/etc/profile.d/nix.sh ]; then . /home/go/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# rust
. "$HOME/.cargo/env"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:`go env GOPATH`/bin

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --multi 2> /dev/null)"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pg
export PATH="$PATH:/usr/lib/postgresql/15/bin"

# envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export SEER=~/m/seer/main

# flyctl
export FLYCTL_INSTALL="/home/go/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
