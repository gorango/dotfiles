export TERMINAL=alacritty
export TERM=alacritty

export BROWSER=brave
export EDITOR=nvim

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
eval "$HOME/.device/trackball.sh"

# cursor controls
eval "xbindkeys"

# nvim
export PATH=$HOME/.local/share/nvim/mason/bin:$PATH

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
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
. "$HOME/.deno/env"

# deno
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi
. "$HOME/.deno/env"

# go pkgs
export PATH=$HOME/go/bin:$PATH

# rust
export PATH=$PATH:$HOME/.cargo/bin

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# gcloud
if [ -f "$HOME/d/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/d/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/d/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/d/google-cloud-sdk/completion.zsh.inc"; fi

# bun bin
export PATH="$HOME/.bun/bin:$PATH"

# memo
export PATH="$HOME/.optmem:$PATH"

# pi
export PATH="$HOME/.local/share/fnm/node-versions/v24.3.0/installation/bin:$PATH"
