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

  # Check for Ruby or Python environments
  rvm_gemset=`~/.rvm/bin/rvm-prompt g 2> /dev/null | sed s/@//`
  [[ -n $rvm_gemset ]] && rvm="$BLUE[rvm:$rvm_gemset]$RESET"
  [[ -n $VIRTUAL_ENV ]] && pve="$CYAN[env:${VIRTUAL_ENV##*/}]$RESET"

  export PS1="$RESET$GREEN\u$RESET@$CYAN\h$RESET(\w)$RESET$rvm$pve$git$svn$RESET\\$ "
}

if [[ -z $PROMPT_COMMAND ]]; then
  PROMPT_COMMAND=prompt_command
else
  PROMPT_COMMAND="$PROMPT_COMMAND; prompt_command"
fi

export PROMPT_COMMAND

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

export CLICOLOR="1"
# export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"
export TERM="xterm-256color"

export LESS="-R"
export LESSOPEN='|~/.bin/less-pygments %s'

# Enable autocomplete in python
export PYTHONSTARTUP=~/.pythonrc

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

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

create_ios_icons()
{
  local dir="./$1_images"

  mkdir -p $dir
  convert $1 -resize 120x120\!    "$dir/app_icon_120x120.png"
  convert $1 -resize 152x152\!    "$dir/app_icon_152x152.png"
  convert $1 -resize 76x76\!      "$dir/app_icon_76x76.png"
  convert $1 -resize 1024x1024\!  "$dir/app_icon_1024x1024.png"
  convert $1 -resize 80x80\!      "$dir/app_icon_80x80.png"
  convert $1 -resize 40x40\!      "$dir/app_icon_40x40.png"
  convert $1 -resize 58x58\!      "$dir/app_icon_58x58.png"
  convert $1 -resize 29x29\!      "$dir/app_icon_29x29.png"
  convert $1 -resize 44x44\!      "$dir/app_icon_44x44.png"
  convert $1 -resize 22x22\!      "$dir/app_icon_22x22.png"
}

new()
{
  if [[ -z $1 ]];  then
    echo "Error: Please specify a project name!"
    echo "Usage:"
    echo "  new <project_name>"
    return
  fi

  local project_name=$1
  local ruby_version=`rvm current | cut -d '@' -f 1`

  echo "=> Creating project directory..."
  mkdir -p $project_name

  echo "=> Creating '$project_name' gemset for the new project using $ruby_version..."
  rvm gemset create $project_name

  local RUBY_VERSION_FILENAME=".ruby-version"
  echo "=> Creating '$RUBY_VERSION_FILENAME' file..."
  echo $ruby_version > $project_name/$RUBY_VERSION_FILENAME

  local RUBY_GEMSET_FILENAME=".ruby-gemset"
  echo "=> Creating '$RUBY_GEMSET_FILENAME' file..."
  echo $project_name > $project_name/$RUBY_GEMSET_FILENAME

  echo "=> Switching to project directory..."
  cd $project_name

  echo "=> Installing Rails..."
  gem install rails

  echo "=> Creating '$project_name' app..."
  rails new . -d postgresql

  echo "=> Adding 'database.yml' to '.gitignore'"
  cp config/database.yml config/database.example.yml

  echo "=> Creating a git repo for the project..."
  git init .

  echo >> .gitignore
  echo "config/database.yml" >> .gitignore

  git add .
  git commit -m "Initial commit."

  echo "=> All done! You can start coding :)"
}

# if [[ $TERM != "dumb" ]];  then
#   eval "`gdircolors -b`"
# fi

command_not_found_handle ()
{
  RESET="\033[00;00m"
  RED="\033[00;31m"
  # command_not_found_handle only works on Bash 4, so we can safely use ${var^}
  echo -e "$RED$1$RESET: command not found." >&2
}

ip ()
{
  local addr=`curl http://icanhazip.com -s`
  echo -n $addr | pbcopy
  echo "$addr copied to clipboard."
}

open ()
{
  if [[ -z "$@" ]]; then
    command open "./"
  else
    command open "$@"
  fi
}

hrep ()
{
  history | grep --color=auto "$@" | cut -c 28- | grep -v hrep | sort | uniq
}

poke ()
{
  [[ -z $1 ]] && return

  local filename=$(basename $1)
  local ext=${filename##*.}
  declare -A interpreters
  interpreters=(
    ["rb"]="#!/usr/bin/env ruby"
    ["py"]="#!/usr/bin/env python"
    ["js"]="#!/usr/bin/env node"
  )

  touch $filename
  chmod +x $filename
  echo ${interpreters[$ext]} > $filename
}

rubify ()
{
  local RUBY_VERSION_FILENAME=".ruby-version"
  local RUBY_GEMSET_FILENAME=".ruby-gemset"
  local GEMFILE_FILENAME="Gemfile"

  if [[ -f "$GEMFILE_FILENAME" ]]; then
    echo "$GEMFILE_FILENAME already exists."
  fi

  if [[ -f "$RUBY_GEMSET_FILENAME" ]]; then
    echo "$RUBY_GEMSET_FILENAME already exists."
  fi

  if [[ -f "$RUBY_VERSION_FILENAME" ]]; then
    echo "$RUBY_VERSION_FILENAME already exists."
  fi

  if [[ -f "$GEMFILE_FILENAME" || -f "$RUBY_GEMSET_FILENAME" || -f "$RUBY_VERSION_FILENAME" ]]; then
    return
  fi

  local current_folder_name="${PWD##*/}"
  local gemset_name=

  if [[ -n "$1" ]]; then
    # if a paramater is passed, use it as a gemset name
    gemset_name="$1"
  else
    # otherwise use the current folder name
    gemset_name="$current_folder_name"
  fi

  gemset_name=`echo "$gemset_name" | perl -pe 's/([a-z])([A-Z])/\1_\l\2/g'`
  gemset_name=`echo "$gemset_name" | perl -pe 's/([A-Z])/\l\1/'`

  local ruby_version=`rvm current | cut -d '@' -f 1`

  touch "$GEMFILE_FILENAME"
  touch "$RUBY_VERSION_FILENAME"
  touch "$RUBY_GEMSET_FILENAME"

  echo "=> Creating '$RUBY_VERSION_FILENAME' file..."
  echo "$ruby_version" >> $RUBY_VERSION_FILENAME

  echo "=> Creating '$RUBY_GEMSET_FILENAME' file..."
  echo "$gemset_name" >> $RUBY_GEMSET_FILENAME

  echo "=> Creating '$GEMFILE_FILENAME' file..."
  echo "ruby '${ruby_version##*-}'" >> "$GEMFILE_FILENAME"
  echo "" >> "$GEMFILE_FILENAME"
  echo "source 'https://rubygems.org'" >> "$GEMFILE_FILENAME"
  echo >> "$GEMFILE_FILENAME"

  cd .

  echo "=> Installing 'Bundler' gem..."
  gem install bundler
}