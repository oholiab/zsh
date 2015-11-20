export OS=$(uname)

export PATH=$PATH:/usr/local/sbin
export EDITOR=vim
export KEYTIMEOUT=1
set -o vi
bindkey -v
bindkey "^?" describe-key-briefly
bindkey "^r" history-incremental-search-backward
bindkey -M vicmd "/" history-incremental-search-backward
autoload -U colors && colors

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history

setopt INC_APPEND_HISTORY

if which thefuck 2>&1 >/dev/null; then
  eval $(thefuck --alias)
fi

__gitprompt_prefix="["
__gitprompt_suffix="]"
function __gitprompt {
  if git show-ref --head > /dev/null 2>&1; then
    branch=$(git rev-parse --abbrev-ref HEAD)
    revision=$(git rev-parse --short HEAD)
    unstaged=$(git ls-files -om | wc -l)
    staged=$(git diff --name-only --cached | wc -l)
    echo -n "$__gitprompt_prefix"
    [ "$branch" = "HEAD" ] && echo -n $revision || echo -n $branch
    [ $unstaged -ne 0 ] && echo -ne " %F{red}%}${unstaged##* }%{$reset_color%}"
    [ $staged -ne 0 ] && echo -ne " %F{green}%}${staged##* }%{$reset_color%}"
    echo "$__gitprompt_suffix"
  elif [ -d .git ]; then
    echo -e "${__gitprompt_prefix}${_RED}new repo${_RST}${__gitprompt_suffix}"
  fi
}

__ins_prompt="%F{yellow}> %{$reset_color%}"
__cmd_prompt="%F{yellow}: %{$reset_color%}"

function zle-line-init zle-keymap-select {
  PROMPT="$THE_PROMPT${${KEYMAP/vicmd/$__cmd_prompt}/(main|viins)/$__ins_prompt}"
  zle reset-prompt
}

setopt PROMPT_SUBST
export THE_PROMPT="%n@%l:%~ \$(__gitprompt)"

zle -N zle-line-init
zle -N zle-keymap-select

function flippo {
  # Make it portable
  case $OS in 
    FreeBSD|Linux|Darwin)
      local delay=0.5
      ;;
    *)
      local delay=1
      ;;
  esac
  local reset="\r\e[K"
  local frames=( \
    '(ヽ°-°)ヽ┳━┳     ' \
    '(╯ °□°）╯︵ ┻━┻  ' \
    'ﾉ(°-°ﾉ)     ┻━┻  ' \
    '-°ﾉ)        ┻━┻  ' \
    '            ┻━┻  ')
  for i in ${frames[@]}; do
    echo -en $reset
    echo -n $i
    sleep $delay
  done
  echo
}
#if [ "$OS" = "Darwin" ] && which docker-machine > /dev/null 2>&1; then
#  __docker_machine_name=default
#  __docker_machine_status=$(docker-machine status ${__docker_machine_name} 2>&1)
#  if [ $? -ne 0 ]; then
#    docker-machine create ${__docker_machine_name} -d virtualbox
#  fi
#  if [ ${__docker_machine_status} = "Stopped" ]; then
#    docker-machine start ${__docker_machine_name}
#  fi
#  eval $(docker-machine env ${__docker_machine_name})
#fi
