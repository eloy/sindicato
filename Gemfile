source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'mysql2'
gem 'jquery-rails'
gem 'capistrano'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'figaro'                                      # Manage configurations
gem 'turbo-sprockets-rails3'                      # Fast assets precompilation in production
gem 'roo', git: 'git://github.com/Empact/roo.git' # spreadsheet support

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem 'rspec-rails'
end

group :development do
  gem 'letter_opener'
  gem 'foreman'
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'simplecov', require: false
  gem 'rspec'
  gem 'capybara'
  gem 'poltergeist'
  gem 'shoulda-matchers'
  gem 'factory_girl'
  gem 'database_cleaner'
end
