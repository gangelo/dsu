# frozen_string_literal: true

require 'dotenv/load'
require 'factory_bot'
require 'ffaker'
require 'fileutils'
require 'pry-byebug'
require 'securerandom'
require 'tempfile'
require 'time'

require_relative './support/configuration_helpers'
require_relative './support/entry_group_helpers'
require_relative './support/time_helpers'

require 'simplecov'

SimpleCov.start

SimpleCov.start do
  add_filter 'spec'
end

require 'dsu'

Dir[File.join(Dir.pwd, 'spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.include ConfigurationHelpers
  config.include EntryGroupHelpers
  config.include TimeHelpers
end
