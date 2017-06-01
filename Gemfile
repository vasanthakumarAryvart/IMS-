source 'https://rubygems.org'

ruby '2.1.10'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use mysql as the database for Active Record
gem 'mysql2', '0.3.17'
gem 'mysql'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'

gem 'redis-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'parallel'
gem 'devise'
gem 'paperclip'
gem 'font-awesome-rails'
gem 'dentaku'

gem 'whenever'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

gem 'jquery-ui-themes'

gem 'mailgun_rails'

# marketplace
gem 'peddler'
gem 'etsy'
gem 'shopify_api'

gem 'htmlentities'

group :development do
  gem 'capistrano', '2.15.5'
  gem 'capistrano-ext'
  gem 'capistrano-confirm', require: false
  gem 'better_errors'
  gem 'meta_request'
  gem 'binding_of_caller'
  gem 'rb-readline', require: false
  gem 'reek'
  gem 'flay'
  gem 'capistrano-unicorn', require: false
end

group :test do
  gem 'webmock'
  %w(rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support).each do |lib|
    gem lib, git: "git://github.com/rspec/#{lib}.git", branch: 'master'
  end
end

gem 'highcharts-rails'
gem 'will_paginate'
gem 'rack-cors', :require => 'rack/cors' 
