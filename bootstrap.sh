
sudo yum -y upgrade

# libraries
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

sudo yum groupinstall -y "Development Tools"
sudo yum install -y kernel-devel kernel-headers
sudo yum install -y openssl openssl-devel
sudo yum install -y libcurl-devel
sudo yum install -y gcc gcc-c++ make
sudo yum install -y zlib-devel
sudo yum install -y readline-devel
sudo yum install -y ntp git vim emacs

# MySQL
echo 'Installing MySQL'
sudo yum remove -y mysql*

cd /usr/local/src
if [ ! -e MySQL-client-5.6.20-1.el6.x86_64.rpm ]; then
  sudo wget -q http://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-client-5.6.20-1.el6.x86_64.rpm
fi
if [ ! -e MySQL-shared-compat-5.6.20-1.el6.x86_64.rpm ]; then
  sudo wget -q http://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-shared-compat-5.6.20-1.el6.x86_64.rpm
fi
if [ ! -e MySQL-server-5.6.20-1.el6.x86_64.rpm ]; then
  sudo wget -q http://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-server-5.6.20-1.el6.x86_64.rpm
fi
if [ ! -e MySQL-devel-5.6.20-1.el6.x86_64.rpm ]; then
  sudo wget -q http://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-devel-5.6.20-1.el6.x86_64.rpm
fi
if [ ! -e MySQL-shared-5.6.20-1.el6.x86_64.rpm ]; then
  sudo wget -q http://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-shared-5.6.20-1.el6.x86_64.rpm
fi
sudo yum install -y MySQL-{client,devel,server,shared-compat}-5.6.20-1.el6.x86_64.rpm
sudo yum install -y MySQL-shared-5.6.20-1.el6.x86_64.rpm
cd ~
sudo chkconfig mysql on
sudo service mysql start

MYSQL_ROOT_PASSWORD=`sudo cat /root/.mysql_secret | sed -e "s/^.*: \(.*\).*$/\1/"`
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e 'show databases;'
if [ "$?" -eq 0 ]; then
  mysql -u root -p${MYSQL_ROOT_PASSWORD} --connect-expired-password -e "SET PASSWORD FOR root@localhost=PASSWORD('');"
  mysql -u root -e "SET PASSWORD FOR root@'127.0.0.1'=PASSWORD('');"
  mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
  mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');"
  mysql -u root -e "DROP DATABASE test;"
  mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
  mysql -u root -e "FLUSH PRIVILEGES;"
fi

# Redis
echo 'Installing Redis'
sudo yum --enablerepo=epel -y install redis

# memcached
echo 'Installing memcached'
sudo rpm -Uvh http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
sudo yum install memcached

# rbenv + ruby
RUBY_VERSION='2.2.0'

echo 'Installing rbenv'
if [ ! -e ~/.rbenv ]; then
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

  source ~/.bash_profile
  echo "rbenv(`rbenv --version`) installed"
fi

sudo yum -y install libffi-devel
rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}
rbenv rehash
gem install bundler
rbenv rehash

# nginx
cd /usr/local/src
if [ ! -e nginx-release-centos-6-0.el6.ngx.noarch.rpm ]; then
  sudo rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
fi
sudo yum -y install nginx
cd ~
sudo chkconfig nginx on
sudo service nginx start

# Ignore Host key verification
echo 'Ignore Host key verification'

if [ ! -e ~/.ssh ]; then
  mkdir -p ~/.ssh
  sudo chown -R vagrant:vagrant ~/.ssh
  chmod 700 ~/.ssh
fi

if [ ! -e ~/.ssh/config ]; then
  cat << EOF >> ~/.ssh/config
Host github.com
  StrictHostKeyChecking no
EOF
  chmod 600 ~/.ssh/config
fi

# node
sudo yum --enablerepo=epel install -y nodejs npm

# tmux
LIBEVENT_VERSION='2.0'
LIBEVENT_FULL_VERSION="${LIBEVENT_VERSION}.21"
TMUX_VERSION='1.9'

if [ ! type tmux >/dev/null 2>&1 ]; then
  sudo yum remove libevent libevent-devel libevent-headers
  cd /usr/local/src
  sudo wget -q https://github.com/downloads/libevent/libevent/libevent-${LIBEVENT_FULL_VERSION}-stable.tar.gz
  sudo tar -xvf libevent-${LIBEVENT_FULL_VERSION}-stable.tar.gz
  cd libevent-${LIBEVENT_FULL_VERSION}-stable

  sudo ./configure && sudo make
  sudo make install
  cd ~
  sudo ln -s /usr/local/lib/libevent-${LIBEVENT_VERSION}.so.5 /usr/lib64/libevent-${LIBEVENT_VERSION}.so.5

  cd /usr/local/src
  sudo wget http://downloads.sourceforge.net/tmux/tmux-${TMUX_VERSION}a.tar.gz
  sudo tar -xvf tmux-${TMUX_VERSION}a.tar.gz
  cd tmux-${TMUX_VERSION}a

  sudo ./configure && sudo make
  sudo make install
  cd ~
fi

# application directory
if [ ! -e /var/www ]; then
  sudo mkdir -p /var/www
  sudo chown -R vagrant:vagrant /var/www
fi

if [ ! -e /var/www/rails-sample ]; then
  echo 'Cloneing rails-sample'
  git clone git@github.com:tadyjp/rails-sample.git /var/www/rails-sample
fi

cd /var/www/rails-sample
bundle install
bundle exec rake db:create RAILS_ENV=development
cd ~

