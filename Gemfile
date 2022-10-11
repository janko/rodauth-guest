# frozen_string_literal: true

source "https://rubygems.org"

gemspec

if RUBY_ENGINE == "jruby"
  gem "jdbc-sqlite3"
else
  gem "sqlite3"
end

gem "rake", "~> 13.0"
