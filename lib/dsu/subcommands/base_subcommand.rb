# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../support/ask'

module Dsu
  module Subcommands
    class BaseSubcommand < Dsu::BaseCLI
      include Support::Ask
    end
  end
end
