#!/usr/bin/env bash

# Do no thing if this is an interactive session
[[ -z "$PS1" ]] && return

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -f ~/.bash_functions ]] && source ~/.bash_functions
[[ -f ~/.bash_system ]] && source ~/.bash_system

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

# export HISTFILE=/dev/null
# export LESSHSTFILE=/dev/null
export HISTSIZE=1000
export HISTFILESIZE=1000

# Default colors for ls
export LSCOLORS="ExGxfxfxbxcxDxBxBxxexe"
export LS_COLORS="di=01;34:ln=01;36:so=35:pi=35:ex=31:bd=33:cd=01;33:or=01;31;40:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:rs=0:mh=00:do=01;35:";

export TERM="xterm-256color"
export LESS="-R"
export LESSOPEN="|~/.bin/less-pygments %s"

# Enable autocomplete in python
export PYTHONSTARTUP=~/.pythonrc

export WORKON_HOME=$HOME/.virtualenvs
#export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS="--no-site-packages"
#export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

# Load VirtualenvWrapper
[[ -r /usr/local/bin/virtualenvwrapper.sh ]] && source /usr/local/bin/virtualenvwrapper.sh

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
