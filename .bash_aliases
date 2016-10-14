#!/usr/bin/env bash

if [[ $OSTYPE =~ darwin* || $OSTYPE =~ freebsd* ]]; then
  alias ls="ls -ACFG"
  alias ll="ls -AFGhl"

  if [[ -f /usr/local/bin/gls ]]; then
    alias ls="gls -ACF --color=auto"
    alias ll="gls -AFhl --color=auto"
  fi
else
  alias ls="ls -ACF --color=auto"
  alias ll="ls -AFhl --color=auto"
fi

alias l="ll"
alias lll="ll"
alias kk="ll"
alias li="ll"

alias coffee="caffeinate -sim"

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

alias df="df -h"
alias du="du -h"
alias ds="du -csh"

alias xs="cd"
alias CD="cd"
alias cd..="cd .."

alias mysql="mysql -u root"
alias mysqldump="mysqldump -u root"
alias mysqladmin="mysqladmin -u root"

alias redis="redis-server"

alias tailf="tail -f"

# Git
alias g="git"
alias gst="git status"
alias gco="git checkout"
alias grm="git rm"
alias glog="git log"
alias giff="git diff"

# SVN
alias sup="svn update"
alias sst="svn status"
alias sco="svn checkout"
alias srm="svn rm"
alias slog="svn log | less -r"
alias srv="svn revert"
siff ()
{
  svn diff $@ | less -r
}

# Vim
alias nano="vim"

# Emacs
alias e="emacs"
alias e.="emacs ."

# SublimeText
alias s="subl"
alias s.="subl ."

# TextMate
alias m="mate"
alias m.="mate ."

alias install_rvm="curl -L https://get.rvm.io | bash"
alias install_rvm_stable="curl -L https://get.rvm.io | bash -s stable"
alias install_homebrew="curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby"

# Ruby and Rails
alias rb="ruby"
alias r="rails"

alias console="rails console"
alias c="rails console"

alias controller="rails generate controller"
alias model="rails generate model"
alias migration="rails generate migration"
alias scaffold="rails generate scaffold"

alias drop="rake db:drop"
alias create="rake db:create"
alias migrate="rake db:migrate"
alias rollback="rake db:rollback"
alias seed="rake db:seed"

alias u="unicorn -c config/unicorn.rb"
alias t="rails server thin"
alias start="foreman start"

alias i_screwed_up="drop && create && migrate && seed"
alias todo="rake todo"

alias p="ping"
alias pp="p abv.bg"

# Python stuff
alias py="python"
alias pipi="pip"

# virtualenv aliases
# http://blog.doughellmann.com/2010/01/virtualenvwrapper-tips-and-tricks.html
alias v="workon"
alias v.deactivate="deactivate"
alias v.mk="mkvirtualenv --no-site-packages"
alias v.mk_with_site_packages="mkvirtualenv"
alias v.cp="cpvirtualenv"
alias v.rm="rmvirtualenv"
alias v.switch="workon"
alias v.add2virtualenv="add2virtualenv"
alias v.cdsitepackages="cdsitepackages"
alias v.cd="cdvirtualenv"
alias v.lssitepackages="lssitepackages"
