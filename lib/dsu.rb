# frozen_string_literal: true

# Require relative all files under dsu/support folder (recursively)
Dir.glob("#{__dir__}/dsu/support/**/*.rb").each do |file|
  require file
end

require_relative 'dsu/cli'
require_relative 'dsu/version'

# The main namespace for this dsu gem.
module Dsu
  # Your code goes here...
end
