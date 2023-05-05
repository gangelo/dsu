# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'

# Require relative all files under dsu/services folder (recursively)
Dir.glob("#{__dir__}/dsu/services/**/*.rb").each do |file|
  require file
end

# Require relative all files under dsu/support folder (recursively)
Dir.glob("#{__dir__}/dsu/support/**/*.rb").each do |file|
  require file
end

Dir.glob("#{__dir__}/dsu/validators/**/*.rb").each do |file|
  require file
end

require_relative 'dsu/cli'
require_relative 'dsu/version'

# The main namespace for this dsu gem.
module Dsu
  # Your code goes here...
end
