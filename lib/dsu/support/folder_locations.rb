# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'colorize'
require 'pathname'

module Dsu
  module Support
    module FolderLocations
      module_function

      def root_folder
        Dir.home
      end

      def temp_folder
        Dir.tmpdir
      end
    end
  end
end
