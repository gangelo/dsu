# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'colorize'
require 'pathname'

module Dsu
  module Support
    module Location
      module_function

      def home_folder
        Dir.home
      end
      alias global_folder home_folder
      singleton_class.alias_method :global_folder, :home_folder

      def entries_folder(options: {})
        return home_folder if options.blank?

        home_folder
      end

      def temp_folder
        Dir.tmpdir
      end
    end
  end
end
