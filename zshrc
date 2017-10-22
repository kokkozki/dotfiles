# Don't register duplicated path
typeset -U path cdpath fpath manpath

# set path for sudo
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))

# pyenv
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# Golang
export GOPATH=$HOME/.golang
export PATH=$PATH:$GOPATH/bin

# for zsh-completions
autoload -Uz compinit
compinit -u

# search history
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

export EDITOR=vim           # set editor to vim
export LANG=ja_JP.UTF-8     # set char code to utf-8
bindkey -e                  # set keybind to emacs-mode

HISTFILE=~/.zsh_history     # file saved history
HISTSIZE=10000              # number of history saved to memory
SAVEHIST=10000              # saved history amount
setopt hist_ignore_dups     # do not save duplicated history
setopt share_history
setopt auto_cd

alias ...='cd ../..'
alias ....='cd ../../..'
alias l='ls'
alias ll='ls -l'
alias la='ls -la'

alias sed='gsed'

alias ts='tmux ls'
alias ta='tmux attach -t'

alias wifirestart='networksetup -setairportpower en0 off;networksetup -setairportpower en0 on'
alias wifioff='networksetup -setairportpower en0 off'
alias wifion='networksetup -setairportpower en0 on'

autoload -U colors; colors  # coloring prompt
# user
tmp_prompt="%F{cyan}[%n@%D{%m/%d %T}]%f "
tmp_prompt2="%{${fg[cyan]}%}%_> %{${reset_color}%}"
tmp_rprompt="%{${fg[green]}%}[%~]%{${reset_color}%}"
tmp_sprompt="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"
# root (font-weight: bold, added under score)
if [ ${UID} -eq 0 ]; then
  tmp_prompt="%B%U${tmp_prompt}%u%b"
  tmp_prompt2="%B%U${tmp_prompt2}%u%b"
  tmp_rprompt="%B%U${tmp_rprompt}%u%b"
  tmp_sprompt="%B%U${tmp_sprompt}%u%b"
fi

PROMPT=$tmp_prompt    # 通常のプロンプト
PROMPT2=$tmp_prompt2  # セカンダリのプロンプト(コマンドが2行以上の時に表示される)
RPROMPT=$tmp_rprompt  # 右側のプロンプト
SPROMPT=$tmp_sprompt  # スペル訂正用プロンプト

# SSHログイン時のプロンプト
[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
  PROMPT="%{${fg[white]}%}${HOST%%.*} ${PROMPT}"
;

# added by travis gem
[ -f /Users/MasatoYamazaki/.travis/travis.sh ] && source /Users/MasatoYamazaki/.travis/travis.sh

############################################################
# fzf config

export FZF_DEFAULT_OPTS='--height 30% --border --reverse'

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  local out file key
  IFS=$'\n' out=($(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e))
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fda - including hidden directories
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# fbr - checkout git branch
fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
