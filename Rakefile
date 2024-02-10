# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc 'Generate a migration timestamp'
task :timestamp do
  puts 'The below migration timestamp should be placed in the "lib/dsu/migration/version.rb" file.'
  puts Time.now.strftime('%Y%m%d%H%M%S')
end
