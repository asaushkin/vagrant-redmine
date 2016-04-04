#!/usr/bin/env bash
# Script to create a vagrant image with redmine ready to use.

export REDMINE_VERSION=3.2.1
export PG_VERSION=9.5

# Set non-interactive instaler mode, update repos.
export DEBIAN_FRONTEND=noninteractive

# Install postgresql from pgdg
apt-get install wget ca-certificates apt-transport-https

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -cs) main" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get purge -y ruby
#apt-get autoremove -y
#apt-get upgrade

apt-get -y install postgresql-${PG_VERSION}

# Ruby (RVM) requirements
apt-get -y install g++ libreadline6-dev zlib1g-dev libssl-dev   \
  libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev       \
  libncurses5-dev automake libtool bison pkg-config libffi-dev  \
  postgresql-server-dev-${PG_VERSION} libxslt-dev libxml2-dev imagemagick  \
  libmagickwand-dev apg haveged

apt-get -y install linux-image-extra-$(uname -r) apparmor 
apt-get -y install docker-engine

service docker start
usermod -aG docker vagrant

docker run --restart=always -d -e RABBITMQ_NODENAME=rabbit-pg --name rabbitmq -p 15672:15672 -p 5672:5672 rabbitmq:3-management

# configure postgres to accept remote connections
cat > /etc/postgresql/${PG_VERSION}/main/pg_hba.conf <<EOF
local   all             postgres    peer
local   all             all         peer

# Accept all IPv4 connections - CHANGE THIS!!!
host    all         all         0.0.0.0/0             md5
EOF

CONF=/etc/postgresql/${PG_VERSION}/main/postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $CONF

git clone https://github.com/omniti-labs/pg_amqp.git
cd pg_amqp && make && make install && cd ..
echo "shared_preload_libraries = 'pg_amqp.so'" >> /etc/postgresql/${PG_VERSION}/main/postgresql.conf

/etc/init.d/postgresql restart

#export PG_PASS=$(/usr/bin/apg -M NCL -n 1 -m 9 -E 0O)
export PG_PASS=changeme
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$PG_PASS';"

cat <<EOF
################################################
# Now you should be able to see rabbitmq webpage
# http://localhost:15672/ (guest/guest)
#
# Use postgresql superuser account:
#
#   login: postgres
#   password: $PG_PASS
#
################################################
EOF
