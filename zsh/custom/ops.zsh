# devops

export DOCKER_BUILDKIT=1

alias tf='terraform'
alias k='kubectl'
alias h="helm"
alias kctx='kubectx'
alias kns='kubens'
alias kc='k9s'

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
