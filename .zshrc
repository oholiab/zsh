fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
export OS=$(uname)

export PATH=$HOME/bin:$PATH:/usr/local/sbin:$HOME/bin/mail:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.gem/ruby/2.0.0/bin
export PAGER=less
export GPG_TTY=$(tty)
export GPG_AGENT_INFO=$HOME/.gnupg/S.gpg-agent
export GOPATH=$HOME/golang
export GOBIN=$GOPATH/bin
export RUSTBIN=~/.cargo/bin
export PATH=$PATH:$GOBIN:$RUSTBIN
export KEYTIMEOUT=1
export LPASS_CLIPBOARD_COMMAND=wl-copy
set -o vi
bindkey -v
#bindkey "^?" describe-key-briefly
bindkey "^r" history-incremental-search-backward
bindkey -M vicmd "/" history-incremental-search-backward
bindkey "^?" backward-delete-char
autoload -U colors && colors
alias emacs='emacs --no-window-system'
alias zource='source ~/.zshrc'
alias sa='eval `ssh-agent` && ssh-add'
alias be='bundle exec'
alias emasc='emacs'
# what the fuck ansible.
export ANSIBLE_NOCOWS=1

if [ -d "$HOME/.zsh/d" ]; then
  for i in $HOME/.zsh/d/*; do
    source "$i"
  done
fi

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ] && source /usr/local/opt/fzf/shell/key-bindings.zsh
[ -f /usr/local/opt/fzf/shell/completion.zsh ] && source /usr/local/opt/fzf/shell/completion.zsh

which rbenv >/dev/null && eval "$(rbenv init -)"

case $OS in
  FreeBSD)
    alias make='gmake'
    ;;
  Darwin)
    alias ls='ls -G'
    ;;
  Linux)
    alias ls='ls --color'
    ;;
esac

case $TERM in
  st-256color)
    export TERM=xterm-256color
    ;;
esac

man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

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
    unstaged=$(git ls-files -om --exclude-standard | wc -l)
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

if [ -z $SSH_CLIENT ]; then
  PCOL=yellow
else
  PCOL=red
fi

__ins_prompt="%F{$PCOL}> %{$reset_color%}"
__cmd_prompt="%F{$PCOL}: %{$reset_color%}"

function zle-line-init zle-keymap-select {
  PROMPT=\
"$THE_PROMPT
${${KEYMAP/vicmd/$__cmd_prompt}/(main|viins)/$__ins_prompt}%{$reset_color%}"
  zle reset-prompt
}

setopt PROMPT_SUBST
case $OS in
  Darwin)
    prompt_pref="%n@%l"
    ;;
  *)
    prompt_pref="%n@%m/%l"
    ;;
esac

function venvprompt {
  [ -z $VIRTUAL_ENV ] || echo "[$(basename "$VIRTUAL_ENV")]"
}

export THE_PROMPT="\$(venvprompt)${prompt_pref}:%~ \$(__gitprompt)%{$reset_color%}"

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

#FIXME: dry
function ohyeah {
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
    '( •_•)        ' \
    '( •_•)        ' \
    '( •_•)>⌐■-■   ' \
    '( •_•⌐■-■     ' \
    '(⌐■_■)        ' \
    '(⌐■_■) -ohyeah')
  for i in ${frames[@]}; do
    echo -en $reset
    echo -n $i
    sleep $delay
  done
  echo
}

function tl {
  cd $(git rev-parse --show-toplevel)
}

if which fzf 2>&1 >/dev/null; then
  function fh {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf-tmux +s --tac | sed 's/ *[0-9]* *//')
  }
  function fman {
    man -k $1 | fzf --preview 'man $(echo {} | cut -f2 -d "(" | cut -c1) $(echo {} | cut -f1 -d"(")'
  }
  function flpass {
    lpass ls >/dev/null && lpass show -c --password $(lpass ls | fzf | awk '{print $(NF)}' | sed 's/]//g')
  }
  function fcat {
    ls $1 | fzf --preview "[ -d $1/{} ] && tree $1 || cat $1/{}"
  }
fi

function subshell-current-line {
    BUFFER="\$($BUFFER)"
    zle beginning-of-line
    zle -K viins
}
zle -N subshell-current-line

bindkey -M vicmd 'S' subshell-current-line
