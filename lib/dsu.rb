# frozen_string_literal: true

require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/blank'
require 'pry-byebug' if ENV['DEV_ENV']
require 'thor'
require 'time'

Dir.glob("#{__dir__}/dsu/core/ruby/**/*.rb").each do |file|
  require file
end

Array.include(WrapAndJoin)
DateAndTime::Calculations.include(NotToday)
Hash.include(ColorThemeColors)
Hash.include(ColorThemeMode)

Dir.glob("#{__dir__}/dsu/**/*.rb").each do |file|
  require file
end

Dsu::Models::ColorTheme.safe_create_unless_exists!
Dsu::Models::Configuration.safe_create_unless_exists!
