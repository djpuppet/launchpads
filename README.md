# Project details

- Designs: https://www.figma.com/file/eLZHjwxBGPD7WMcpUPaNLD/Launchpads%3A-Website

# Technology stack

 - Ruby v2.7.1
 - Ruby on Rails v6.0.3
 - NodeJS v10.16.0

# Project setup instructions

 - `cp .env.template .env.development`
 - `cp .env.template .env.test`
 - Set up ENV variables in `.env.development` and `.env.test`
 - `gem install bundler`
 - `bundle install`
 - `lefthook install -f`
 - `yarn install`
 - `rails db:setup` (and `RAILS_ENV=test rails db:setup` for test env)
 - `rails db:migrate`
 - `rails server`
 - application is running on `http://lvh.me:3000`

# Working with frontend

 - run `bin/webpack-dev-server` - enables browsersync
 - or use `bundle exec foreman start -f Procfile.dev`

# Running tests, sidekiq and other services around the project.

 - `rspec spec` to run tests.
# launchpads
