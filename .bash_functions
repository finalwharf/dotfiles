#!/usr/bin/env bash

export GIT_PROMPT_ENABLED=true
export SVN_PROMPT_ENABLED=true

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

  local dir=
  local svn=
  local git=
  local rvm=
  local pve=
  local branch=
  local status=
  local changes=
  local rvm_gemset=

  # This is more readable than `if $GIT_PROMPT_ENABLED; then`
  if [[ $GIT_PROMPT_ENABLED == true ]] ; then
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
  fi

  if [[ $SVN_PROMPT_ENABLED == true ]]; then
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
  echo "$ruby_version" > "$project_name/$RUBY_VERSION_FILENAME"

  local RUBY_GEMSET_FILENAME=".ruby-gemset"
  echo "=> Creating '$RUBY_GEMSET_FILENAME' file..."
  echo "$project_name" > "$project_name/$RUBY_GEMSET_FILENAME"

  echo "=> Switching to project directory..."
  cd "$project_name"

  echo "=> Installing Rails. This might take a while..."
  gem install rails

  echo "=> Creating '$project_name' app..."
  rails new . -d postgresql

  echo "=> Locking Ruby version ($ruby_version) in Gemfile ..."
  local ruby_version_digits=$(echo $ruby_version | cut -d "-" -f 2)
  local source_line=$(head -n 1 Gemfile)
  local gem_list=$(tail -n +2 Gemfile)

  echo -n ""                             > Gemfile # Zero out the Gemfile
  echo "$source_line"                   >> Gemfile
  echo "ruby \"$ruby_version_digits\""  >> Gemfile
  echo "$gem_list"                      >> Gemfile

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

command_not_found_handle ()
{
  RESET="\033[00;00m"
  RED="\033[00;31m"
  echo -e "Fuck! $RED$1$RESET not found." >&2
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
  history | grep -i "$*" | sed -E s/^[[:space:]]*[[:digit:]]+[[:space:]]+//g | grep -v hrep | sort | uniq
}

poke ()
{
  if [[ -z "$1" ]]; then
    echo "Usage:"
    echo "  $FUNCNAME filename1[.ext] filename2.[ext]"
    return
  fi

  for filename in "$@"; do

    if [[ -f "$filename" ]]; then
      YELLOW="\033[00;33m"
      RESET="\033[00;30m"
      echo -e "$YELLOW$filename already exists!$RESET" >&2
      return
    fi

    local ext=""
    local interpreter=""

    # If we have a dot in the filename, use the extension to
    # determine the interpreter. Otherwise, assume it's a shell
    # script. Use `touch` to create a refular file.
    if [[ $filename =~ ^.+\..+$ ]]; then
      ext=${filename##*.}
    else
      ext="sh"
    fi

    case "$ext" in
      "sh")
        interpreter="#!/usr/bin/env bash"
        ;;
      "rb")
        interpreter="#!/usr/bin/env ruby"
        ;;
      "py")
        interpreter="#!/usr/bin/env python"
        ;;
      "js")
        interpreter="#!/usr/bin/env node"
        ;;
      "php")
        interpreter="#!/usr/bin/env php"
        ;;
    esac

    touch $filename

    # If we match an extension with an interpreter, make the file execitable.
    # Otherwise, leave the file untouched (pun intended).
    if [[ -n $interpreter ]]; then
      chmod +x $filename
      echo "$interpreter" > $filename
    fi
  done
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

disable ()
{
  case "$1" in
  "git" )
    echo "Disabling Git prompt."
    GIT_PROMPT_ENABLED=false
  ;;
  "svn" )
    echo "Disabling Svn prompt."
    SVN_PROMPT_ENABLED=false
  ;;
  "all" )
    echo "Disabling both Git and Svn prompt."
    GIT_PROMPT_ENABLED=false
    SVN_PROMPT_ENABLED=false
  ;;
  * )
    echo "Usage:"
    echo "  $0 [git|svn|all]"
  esac
}
