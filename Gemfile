# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5.3"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Authentication
gem "devise"

# View syntax
gem "haml-rails"

# Pagination
gem "will_paginate", "~> 4"

gem "airbrake"

# countries and states
gem "countries"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Create inline-styled emails from regular CSS file
gem "premailer-rails"

# Validations for uploads
gem "active_storage_validations", ">= 2.0.2"

# S3 Storage for Images
gem "aws-sdk-s3"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", ">= 1.2"
gem "mini_magick"

# Google Data
gem "google_drive"

# Geocoding
gem "geocoder", "~> 1.8"

# Charts
gem "chartkick"
gem "groupdate"

# Annotated source code for Models
gem "annotaterb", "~> 4.13"

# UI for ActiveJob
gem "mission_control-jobs"

# Gems being moved out of core ruby
gem "csv", "~> 3.3"
gem "drb", "~> 2.2"
gem "mutex_m", "~> 0.3.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv"

  # Make it easier to use ENV vars in development and testing
  # Shim to load environment variables from .env into ENV in development.
  # https://github.com/bkeepers/dotenv
  gem "dotenv-rails", "~> 3.1"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Create fake data
  gem "faker"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # Faster ruby conventions
  gem "fasterer", "~> 0.11.0"

  gem "bullet", "~> 8.0"
  gem "overcommit", "~> 0.64.0"
  gem "reek", "~> 6.4"

  gem "rubocop", "~> 1.69"
  gem "rubocop-capybara", "~> 2.22"
  gem "rubocop-minitest", "~> 0.36"
  gem "rubocop-performance", "~> 1.24"
  gem "rubocop-rails", "~> 2.29"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
end

gem "solid_queue", "~> 1.1"
