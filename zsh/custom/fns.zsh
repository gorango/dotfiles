# directories

function m() {
  cd ~/m/$1
}

function mine() {
  cd ~/m/$1
}

function forks() {
  cd ~/f/$1
}

function repros() {
  cd ~/r/$1
}

function sand() {
  cd ~/s/$1
}

function work() {
  cd ~/w/$1
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
  m && clone "$@" && cd $_
}

function cloner() {
  repros && clone "$@" && cd $_
}

function clonef() {
  forks && clone "$@" && cd $_
}

function clonew() {
  work && clone "$@" && cd $_
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

unalias md
function md() {
    pandoc "$1" -f markdown -t html | lynx -stdin
}

