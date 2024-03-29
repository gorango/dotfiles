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
alias gap='git add -p'
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
