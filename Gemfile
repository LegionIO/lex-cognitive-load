# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :test do
  gem 'rake'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov'
end

if File.directory?(File.expand_path('../../legion-gaia', __dir__))
  gem 'legion-gaia', path: '../../legion-gaia'
else
  gem 'legion-gaia'
end
