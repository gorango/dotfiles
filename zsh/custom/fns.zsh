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

function cpe() {
  root=$(pwd)
  cd $1
  cp -r `ls . -A | grep -v "$3"` $root/$2
  $root
}

function clone() {
  if [[ -z $2 ]] then
    hub clone "$@" && cd "$(basename "$1" .git)"
  else
    hub clone "$@" && cd "$2"
  fi
}

function clonem() {
  m && clone "$@" && code . && exit
}

function cloner() {
  repros && clone "$@" && code . && exit
}

function clonef() {
  forks && clone "$@" && code . && exit
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
