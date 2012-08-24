#!/usr/bin/env rake
require "bundler/gem_tasks"
require "gem_publisher"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
end

desc "Publish gem to RubyGems.org"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("google_auth_bridge.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end