# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'enumerize'
gem 'faker'
gem 'image_processing'
gem 'jbuilder', '~> 2.7'
gem 'pagy'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'pundit'
gem 'rails', '~> 6.1', '>= 6.0.3.2'
gem 'rails_admin', '~> 2.0'
gem 'redis'
gem 'sass-rails', '>= 6'
gem 'sentry-raven'
gem 'sidekiq'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubycritic', require: false
end

group :development do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'foreman'
  gem 'lefthook'
  gem 'letter_opener'
  gem 'listen', '~> 3.2'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end
