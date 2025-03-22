export TERMINAL=alacritty
export TERM=alacritty

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# kensington trackball config
eval "~/.device/trackball.sh"

# cursor controls
eval "xbindkeys"

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --multi 2>/dev/null)"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# flyctl
export FLYCTL_INSTALL="/home/g/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
. "/home/g/.deno/env"

# deno
if [[ ":$FPATH:" != *":/home/g/.zsh/completions:"* ]]; then export FPATH="/home/g/.zsh/completions:$FPATH"; fi
. "/home/g/.deno/env"

# go pkgs
export PATH=$PATH:$HOME/go/bin

