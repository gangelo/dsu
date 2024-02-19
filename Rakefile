# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Generate a migration timestamp'
task :timestamp do
  puts 'The below migration timestamp should be placed in the "lib/dsu/migration/version.rb" file.'
  puts Time.now.strftime('%Y%m%d%H%M%S')
end

task default: %i[spec rubocop]
