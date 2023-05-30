# frozen_string_literal: true

require_relative 'folder_locations'

module Dsu
  module Support
    module ConfigurationFileable
      CONFIG_FILENAME = '.dsu'

      module_function

      def config_file
        File.join(FolderLocations.root_folder, CONFIG_FILENAME)
      end

      def config_file_exist?
        File.exist? config_file
      end
    end
  end
end
