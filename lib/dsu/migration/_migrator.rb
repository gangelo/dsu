# # frozen_string_literal: true

# require_relative '../models/color_theme'
# require_relative '../support/color_themable'

# module Dsu
#   module Migration
#     class Migrator
#       include Support::ColorThemable

#       attr_reader :options

#       def initialize(options: {})
#         @options = options
#       end

#       class << self
#         # module MigrationMethods
#         def migrate(migration_description)
#           define_method(migration_description) do
#             raise ArgumentError, 'Block is required.' unless block_given?

#             puts "Running migration '#{migration_description}'..."
#             yield if block_given?
#             puts 'Done.'
#           end
#         end

#         def default_color_theme
#           @default_color_theme ||= Models::ColorTheme.default
#         end
#       end

#       private

#       def force_update?
#         options[:force_update]
#       end

#       def migrate_folder
#         File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/migrate')
#       end

#       def migrate_path_exist?(migrate_file_name:)
#         File.exist?(migrate_path(migrate_file_name: migrate_file_name))
#       end

#       def migrate_path(migrate_file_name:)
#         File.join(migrate_folder, migrate_file_name)
#       end

#       def default_color_theme
#         self.class.default_color_theme
#       end
#     end
#   end
# end
