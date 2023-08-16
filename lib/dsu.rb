# frozen_string_literal: true

require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/blank'
require 'thor'
require 'time'

Dir.glob("#{__dir__}/core/**/*.rb").each do |file|
  require file
end

Array.include(WrapAndJoin)
DateAndTime::Calculations.include(NotToday)
Hash.include(ColorThemeColors)
Hash.include(ColorThemeMode)

require_relative 'dsu/env'
require 'pry-byebug' if Dsu.env.development?

Dir.glob("#{__dir__}/dsu/**/*.rb").each do |file|
  require file
end

if !(Dsu.env.test? || Dsu.env.development?) && Dsu::Migration::Service.run_migrations?
  begin
    Dsu::Migration::Service.new.call
  rescue StandardError => e
    puts "Error running migrations: #{e.message}"
    exit 1
  end
end
