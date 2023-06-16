# frozen_string_literal: true
# # frozen_string_literal: true

# require_relative '../models/color_theme'
# require_relative 'migrator'

# module Dsu
#   module Migration
#     class ColorThemeMigrator < Migrator
#       def initialize(theme_name:, theme_hash:, options: {})
#         super(options: options)

#         @theme_name = theme_name
#         @theme_hash = theme_hash
#       end

#       class << self
#         def run(options: {})
#           Dir.glob("#{Models::ColorTheme.themes_folder}/*").each do |color_theme_path|
#             theme_name = File.basename(color_theme_path)
#             theme_hash = Models::ColorTheme.hash_for(theme_name: theme_name)
#             new(theme_name: theme_name, theme_hash: theme_hash, options: options).run
#           end
#           # TODO: Update color theme migration version.
#         rescue StandardError => e
#           puts apply_color_theme("Error: #{e.message}", color_theme_color: default_color_theme.error)
#         end

#         def current_version
#           @current_version ||= Models::ColorTheme::VERSION
#         end
#       end

#       migrate '1.0.0 to 2.0.0' do
#         # TODO: Your code here.
#         puts 'TODO: Migration code here.'
#       end

#       def run
#         return update_model! if current_version?

#         migrate_model!
#       end

#       private

#       attr_reader :theme_name, :theme_hash

#       def migrate_model!
#         return theme_hash if current_version?

#         migrate_function = "#{theme_hash[:version]} to #{current_version}"
#       end

#       def update_model!
#         raise '#update_model! called when the model version is not the current version.' unless current_version?

#         Models::ColorTheme::DEFAULT_THEME.each_pair do |key, value|
#           update_or_create_key_value(key: key, value: value) and next if force_update?
#           next if theme_hash.key?(key) && theme_hash[key].is_a?(value.class)

#           update_or_create_key_value(key: key, value: value)
#         end

#         (theme_hash.keys - Models::ColorTheme::DEFAULT_THEME.keys).each do |key|
#           puts apply_color_theme("Deleting key :#{key}", color_theme_color: default_color_theme.error)
#           theme_hash.delete(key)
#         end

#         theme_hash
#       end

#       def update_or_create_key_value(key:, value:)
#         message = "Updating :#{key} from #{theme_hash[key].inspect} to #{value.inspect}" if theme_hash.key?(key)
#         message = "Create :#{key} with value #{theme_hash[key].inspect}" unless theme_hash.key?(key)
#         puts apply_color_theme(message, color_theme_color: default_color_theme.info.swap!)

#         theme_hash[key] = value
#       end

#       def current_version?
#         theme_hash[:version] == current_version
#       end

#       def current_version
#         self.class.current_version
#       end

#       def migrate_folder
#         File.join(super, 'color_theme')
#       end
#     end
#   end
# end
