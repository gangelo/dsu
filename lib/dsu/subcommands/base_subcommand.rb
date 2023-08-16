# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../support/ask'
require_relative '../support/subcommand_help_colorizeable'

module Dsu
  module Subcommands
    class BaseSubcommand < Dsu::BaseCLI
      include Support::Ask
      include Support::SubcommandHelpColorizable
    end
  end
end
