#!/usr/bin/env bash
# Script to create a vagrant image with redmine ready to use.

export REDMINE_VERSION=2.6.1

# Set non-interactive instaler mode, update repos.
export DEBIAN_FRONTEND=noninteractive

# Install postgresql from pgdg
apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

apt-get update
apt-get purge -y ruby
apt-get autoremove -y
apt-get upgrade

apt-get -y install postgresql-9.4

# Ruby (RVM) requirements
apt-get -y install g++ libreadline6-dev zlib1g-dev libssl-dev   \
  libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev       \
  libncurses5-dev automake libtool bison pkg-config libffi-dev  \
  postgresql-server-dev-9.4 libxslt-dev libxml2-dev imagemagick  \
  libmagickwand-dev

su -c 'createuser redmine && createdb redmine -O redmine' postgres

echo "local redmine redmine peer" >> /etc/postgresql/9.4/main/pg_hba.conf

adduser --system --shell=/bin/bash --home=/opt/redmine redmine

wget -O - http://www.redmine.org/releases/redmine-${REDMINE_VERSION}.tar.gz 2>/dev/null | tar -C /opt/ -xvzf -
rm -fr /opt/redmine
ln -s /opt/redmine-${REDMINE_VERSION} /opt/redmine
chown -R redmine:nogroup /opt/redmine-${REDMINE_VERSION}

### Install redmine
su -c '/vagrant/redmine/install.sh' redmine

cat <<EOF
################################################
# Now you should be able to see redmine webpage
# http://localhost:8888
#
# Use default administrator account to log in:
#
#   login: admin
#   password: admin
#
################################################
EOF
