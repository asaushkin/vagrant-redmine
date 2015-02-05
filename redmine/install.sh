#!/bin/bash

VAGRANT_FILES=$( (cd $(dirname $0) && pwd) )

## RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -sSL https://get.rvm.io | bash

export PATH="$PATH:$HOME/.rvm/bin"
source "$HOME/.rvm/scripts/rvm"

rvm install 2.1
rvm use 2.1@redmine --create --default

cp $VAGRANT_FILES/database.yml config/

export RAILS_ENV=production
export REDMINE_LANG=ru

bundle install --without development test
rake generate_secret_token
rake db:migrate
rake redmine:load_default_data

mkdir -p tmp tmp/pdf public/plugin_assets

ruby script/rails server webrick -e production -d


