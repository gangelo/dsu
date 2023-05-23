# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/blank'
require 'pry-byebug' if ENV['DEV_ENV']
require 'thor'
require 'time'

Dir.glob("#{__dir__}/lib/core/**/*.rb").each do |file|
  require file
end

Dir.glob("#{__dir__}/dsu/**/*.rb").each do |file|
  require file
end
