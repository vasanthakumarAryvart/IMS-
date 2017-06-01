# Clarabyte Sell

## Dependencies
- [RVM][rvm]
- Ruby 2.1.10
- Foreman
- MailCatcher
- MySQL
- Redis
- ImageMagick

[rvm]: https://rvm.io/

## Quickstart
```sh
# install dependencies
apt install imagemagick libmysqlclient-dev redis-server mysql-server
rvm install 2.1.10
rvm use 2.1.10
gem install foreman
gem install bundle
gem install mailcatcher
bundle install

# setup DB (expects passwordless root login for MySQL)
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed

# run
foreman start
mailcatcher
```

## Creating a User
- Go to <http://localhost:5000> and sign up
    - If the server isn't running, run `foreman start`
- Grab the confirmation email from MailCatcher <http://localhost:1080>
    - MailCatcher needs to be running before signing up
    - You can run it via `mailcatcher`
- Make yourself an admin
    - Run `bundle exec rails console`
    - Find your user ID `User.all.map {|u| [u.id, u.email] }`
    - Set yourself to admin `User.find(<id>).update_attribute(:is_admin, true)`

## Deployment
Deployment is handled with [Flynn][flynn] (a self-hosted PaaS with Heroku-like
functionality).  Just `git push production` if you have access.

[flynn]: https://flynn.io
