#!/usr/bin/env bash

# Do no thing if this is an interactive session
[[ -z "$PS1" ]] && return

prompt_command ()
{
  local RESET="\[\033[00;00m\]"
  local BLACK="\[\033[00;30m\]"
  local GREEN="\[\033[00;32m\]"
  local BLUE="\[\033[00;34m\]"
  local RED="\[\033[00;31m\]"
  local YELLOW="\[\033[00;33m\]"
  local PINK="\[\033[00;35m\]"
  local CYAN="\[\033[00;36m\]"

  local dir=""
  local svn=""
  local git=""
  local rvm=""
  local pve=""
  local branch=""
  local status=""
  local changes=""
  local rvm_gemset=""

  # Check for SVN repos
  dir="$PWD"
  while [[ ! -d "$dir/.svn" && -n "$dir" ]]; do
    dir="${dir%/*}"
  done

  if [[ -n "$dir" ]]; then
    status=`svn status 2> /dev/null`

    if [[ -n "$status" ]]; then
      changes=`echo "$status" | wc -l`
      svn="$RED[svn:${changes//[[:space:]]/}]$RESET"
    else
      svn="$GREEN[svn]$RESET"
    fi
  fi

  # Check for Git repos
  dir="$PWD"
  status=""
  changes=""
  while [[ ! -d "$dir/.git" && -n "$dir" ]]; do
    dir="${dir%/*}"
  done

  if [[ -n "$dir" ]]; then
    branch=`git symbolic-ref HEAD 2> /dev/null`
    branch="${branch#refs/heads/}"

    if [[ -n "$branch" ]]; then
      status=`git status --porcelain 2> /dev/null`

      if [[ -n "$status" ]]; then
        changes=`echo "$status" | wc -l`
        git="$RED[git:$branch:${changes//[[:space:]]/}]"
      else
        git="$GREEN[git:$branch]"
      fi
      git="$git$RESET"
    fi
  fi

  # Check for Ruby or Python envs
  rvm_gemset=`~/.rvm/bin/rvm-prompt g 2> /dev/null | sed s/@//`
  [[ -n $rvm_gemset ]] && rvm="$BLUE[rvm:$rvm_gemset]$RESET"
  [[ -n $VIRTUAL_ENV ]] && pve="$CYAN[env:${VIRTUAL_ENV##*/}]$RESET"

  # Only works if this .bashrc is copied in root's home and the default shell is bash
  local user="$GREEN\u"
  [[ $UID == 0 ]] && user="$RED\u"

  export PS1="$RESET$user$RESET@$CYAN\h$RESET(\w)$RESET$rvm$pve$git$svn$RESET\\$ "
}

if [[ -z $PROMPT_COMMAND ]]; then
  export PROMPT_COMMAND=prompt_command
else
  export PROMPT_COMMAND="$PROMPT_COMMAND; prompt_command"
fi

# Set umask :@
umask 0022

# Fix PATHs
PATH=${PATH/\/usr\/local\/bin:}
PATH=${PATH/:\/usr\/local\/bin}
PATH=${PATH/\/usr\/local\/sbin:}
PATH=${PATH/:\/usr\/local\/sbin}

[[ ! $PATH =~ "/usr/local/bin" ]]   && PATH="/usr/local/bin:$PATH"
[[ ! $PATH =~ "/usr/local/sbin" ]]  && PATH="/usr/local/sbin:$PATH"

[[ -d "$HOME/bin" ]]                && PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.bin" ]]               && PATH="$HOME/.bin:$PATH"
[[ -d "$HOME/local/bin" ]]          && PATH="$HOME/local/bin:$PATH"
[[ -d "$HOME/.local/bin" ]]         && PATH="$HOME/.local/bin:$PATH"

# Add RVM to PATH for scripting
PATH=$PATH:$HOME/.rvm/bin

# Add Homebrew's sbin to PATH
PATH="/usr/local/sbin:$PATH"

# Added by the Heroku Toolbelt
PATH="/usr/local/heroku/bin:$PATH"

export PATH

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export HISTORY_SIZE=1000
export HISTSIZE=$HISTORY_SIZE
export HISTFILESIZE=$(($HISTORY_SIZE * 2)) # Times 2 - so we can preserve command timestamps
export HISTTIMEFORMAT="%d.%m.%y %T - "
# export HISTFILE=/dev/null
# export LESSHSTFILE=/dev/null


# 1.   directory                                                ex     blue
# 2.   symbolic link                                            gx     cyan
# 3.   socket                                                   fx     magenta
# 4.   pipe                                                     fx     magenta
# 5.   executable                                               bx     red
# 6.   block special                                            dx     brown
# 7.   character special                                        cx     green
# 8.   executable with setuid                                   Bx
# 9.   executable with setgid                                   Bx
# 10.  dir writable to others, with sticky bit                  xe
# 11.  dir writable to others, without sticky bit               xe


# Default colors for ls
export LSCOLORS="ExGxfxfxbxcxDxBxBxxexe"
export LS_COLORS="di=01;34:ln=01;36:so=35:pi=35:ex=31:bd=33:cd=01;33:or=01;31;40:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:rs=0:mh=00:do=01;35:";

export LESS="-R"
export LESSOPEN='|~/.bin/less-pygments %s'

# Enable autocomplete in python
export PYTHONSTARTUP=~/.pythonrc

export WORKON_HOME=$HOME/.virtualenvs
#export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
#export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

if [[ -r /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
else
    echo "WARNING: Can't find virtualenvwrapper.sh"
fi

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -f ~/.bash_functions ]] && source ~/.bash_functions

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Load RVM Autocompletion
[[ -s "$HOME/.rvm/scripts/completion" ]] && source "$HOME/.rvm/scripts/completion"

# Show custom Message-Of-The-Day
[[ -f ~/.bin/motd ]] && ~/.bin/motd

if [[ -f /usr/local/bin/brew && -f $(/usr/local/bin/brew --prefix)/etc/bash_completion ]]; then
  source $(/usr/local/bin/brew --prefix)/etc/bash_completion
elif [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
  source /usr/local/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi
