#!/usr/bin/env bash

# alias ls="gls -CFa --color=auto"
# alias ll="gls -hlFGa --color=auto"
alias ls="ls -CFa"
alias ll="ls -hlFGa"
alias l="ll"
alias lll="ll"
alias kk="ll"
alias li="ll"

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

# Emacs
alias e="emacs"
alias e.="emacs ."

# SublimeText
alias s="subl"
alias s.="subl ."

# TextMate
alias m="mate"
alias m.="mate ."

alias install_rvm="curl -L https://get.rvm.io | bash -s stable"
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
alias start='foreman start'

alias i_screwed_up="drop && create && migrate && seed"
alias todo="rake todo"

alias p="ping"
alias pp="p abv.bg"
