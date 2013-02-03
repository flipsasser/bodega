# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'active_record'
require 'database_cleaner'
require 'logger'
require 'money-rails'
require 'vcr'

require 'bodega'

Dir[File.expand_path(File.join('support', '**', '*.rb'), File.dirname(__FILE__))].each do |file|
  require file
end

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
