# vagrant-rails-bootstrap

# Environment

## Host machine

- window
- mac

## Guest machine

- CentOS-6.6
- MySQL-5.6.20
- Redis
- memcached
- nodejs
- ruby-2.2.0
- rails-4.2.0
- nginx

# Preparation

## Vagrant

* Install [Vagrant](https://www.vagrantup.com/downloads.html).
* Install vagrant-vbguest plugin.

```
vagrant plugin install vagrant-vbguest
```

## Pageant (only for windows)

* Install [pageant](http://ice.hotmint.com/putty/).
* Create SSH key with PuTTYgen and set Pageant.

see also: http://qiita.com/isaoshimizu/items/84ac5a0b1d42b9d355cf

## SSH agent (only for mac)

```
[host]$ ssh-add ~/.ssh/id_rsa
```

## Run!

* Initialize vagrant and login.

```
[host]$ vagrant up
# It would take some time...

[host]$ vagrant ssh
```

* Start Ruby on Rails in vagrant.

```
[vagrant]$ cd /var/www/rails-sample
[vagrant]$ bundle exec rails s -b 0.0.0.0
```

* Access your rails!

http://127.0.0.1:13000/




