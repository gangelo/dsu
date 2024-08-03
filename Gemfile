# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in dsu.gemspec
gemspec

gem 'bundler', '>= 2.5', '< 3.0'
gem 'rake', '>= 13.0', '< 14.0'

group :development do
  gem 'reek', '>= 6.1', '< 7.0'
  gem 'rubocop', '>= 1.65', '< 2.0'
  gem 'rubocop-factory_bot', '~> 2.26', '>= 2.26.1'
  gem 'rubocop-performance', '>= 1.21.1', '< 2.0'
  gem 'rubocop-rake', '>= 0.6', '< 1.0'
  gem 'rubocop-rspec', '~> 3.0', '>= 3.0.3'
end

group :test do
  gem 'rspec', '>= 3.12', '< 4.0'
  gem 'simplecov', '>= 0.22.0', '< 1.0'
end

group :development, :test do
  gem 'dotenv', '~> 3.1', '>= 3.1.2'
  gem 'factory_bot', '~> 6.3'
  gem 'ffaker', '~> 2.21'
  gem 'pry-byebug', '>= 3.9', '< 4.0'
end
