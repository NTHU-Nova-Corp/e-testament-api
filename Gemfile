# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5'
gem 'roda', '~>3'

# Configuration
gem 'figaro', '~>1'
gem 'rake', '~>13'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb', '~>0'
gem 'sequel', '~>5'

group :development, :production, :staging do
  gem 'pg'
end

# External Services
gem 'http'

# Testing
group :test, :development, :staging do
  gem 'minitest'
  gem 'minitest-rg'
end

# Debugging
gem 'pry' # necessary for rake console
gem 'rack-test'

# Development
group :test do
  gem 'rerun'

  # Quality
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

# OAuth
gem 'google-api-client'
