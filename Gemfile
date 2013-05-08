source 'https://rubygems.org'
gem 'rails', '3.2.12'
gem 'pg'
gem 'jquery-rails','1.0.19'
gem 'sass'
gem 'haml'
gem 'execjs'
gem 'fog'
gem 'rmagick'
gem 'carrierwave'
gem 'cloudfiles_asset_sync', :git => 'git@github.com:simplecircle/cloudfiles_asset_sync.git'
gem 'capistrano'
gem 'capistrano-ext','~> 1.2.1'
gem 'lograge'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'babosa'
gem 'acts-as-taggable-on'

if RUBY_PLATFORM =~ /mingw32/
  gem 'therubyracer','0.11.0beta1' #0.11.0beta5
  gem 'libv8', '~> 3.3.8' #3.3.10.4
else
  gem 'therubyracer','~> 0.9.8'
  gem 'unicorn'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem "less-rails"
  gem 'twitter-bootstrap-rails'
end

group :test, :development do
  gem 'haml-rails'
end