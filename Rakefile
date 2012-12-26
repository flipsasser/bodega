#!/usr/bin/env rake
# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bodega"
  gem.homepage = "http://github.com/flipsasser/bodega"
  gem.license = "MIT"
  gem.summary = %Q{Bodega adds checkout logic to any model in your app!}
  gem.description = %Q{Bodega adds checkout logic to any model in your app!}
  gem.email = "flip@x451.com"
  gem.authors = ["Flip Sasser"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

