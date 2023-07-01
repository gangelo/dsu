# frozen_string_literal: true

require 'thor'

require_relative '../migration/service'
require_relative '../models/color_theme'
require_relative '../support/color_themable'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Generate < BaseSubcommand
      include Support::ColorThemable

      map %w[m] => :migration

      default_command :help

      class << self
        def exit_on_failure?
          false
        end

        def migrate_folder
          Support::Fileable.migrate_folder
        end
      end

      desc 'migration', 'Creates dsu migration file in the `migrate` folder.'
      long_desc <<-LONG_DESC
        NAME

        `dsu generate migration MIGRATION` -- will create dsu migration file named MIGRATION in the dsu `migrate` folder ("#{migrate_folder}").

        SYNOPSIS

        dsu generate|-g migration MIGRATION

        EXAMPLES

        `dsu generate migration AddThemeNameToConfiguration` will generate a migration file named "<%Y%m%d%H%M%S>_add_theme_name_to_configuration.rb" in the dsu `migrate` folder ("#{migrate_folder}").
      LONG_DESC
      def migration(migration_name)
        # TODO: Perform validations.
        puts apply_color_theme("Migration service version: #{Dsu::Migration::Service::MIGRATION_SERVICE_VERSION}",
          color_theme_color: color_theme.info)
        migration_file = create_migration_file(migration_name)
        puts apply_color_theme("Migration file \"#{File.basename(migration_file)}\" created.",
          color_theme_color: color_theme.info)
      end

      private

      def color_theme
        @color_theme ||= Models::ColorTheme.current_or_default
      end

      def create_migration_file(migration_name)
        migration_file, migration_class = migration_file_for(migration_name)

        migration_file_content = if options[:config]
          migration_file_content(migration_class, type: :config)
        else
          migration_file_content(migration_class)
        end
        File.write(migration_file, migration_file_content)

        migration_file
      end

      def time
        @time ||= Time.now.utc
      end

      def migrate_folder
        self.class.migrate_folder
      end

      def migration_service_version
        self.class.migration_service_version
      end

      def migration_file_for(migration_name)
        [
          File.join(migrate_folder, time.strftime("%Y%m%d%H%M%S_#{migration_name.underscore}.rb")),
          migration_name.camelize
        ]
      end

      def migration_file_content(migration_class)
        <<~MIGRATION_FILE_CONTENT
          # frozen_string_literal: true

          require_relative '../dsu/crud/json_file'
          require_relative '../dsu/migration/service'
          require_relative '../dsu/models/color_theme'
          require_relative '../dsu/models/configuration'
          require_relative '../dsu/models/entry'
          require_relative '../dsu/models/entry_group'

          module Dsu
            module Migrate
              class #{migration_class} < Migration::Service[#{Dsu::Migration::Service::MIGRATION_SERVICE_VERSION}]
                def call
                  unless migrate?
                    raise "This migration file migration version (\#{migration_version}) " \\
                          "is not < the current migration version (\#{current_migration_version})."
                  end

                  update_configuration!
                  update_color_themes!
                  update_entry_groups!

                  super
                rescue StandardError => e
                  puts "Error running migration \#{File.basename(__FILE__)}: \#{e.message}"
                  raise
                end

                private

                def migration_version
                  @migration_version ||= File.basename(__FILE__).match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
                end

                def update_color_themes!
                  # TODO: Apply Color Theme changes here.
                end

                def update_configuration!
                  # TODO: Apply Configuration changes here.
                end

                def update_entry_groups!
                  # TODO: Apply Entry changes here.
                  # TODO: If all Entries in an entry group are updated, apply Entry Group changes here.
                end

                def migrate_color_themes?
                  themes_path = Support::Fileable.themes_path
                end
              end
            end
          end
        MIGRATION_FILE_CONTENT
      end
    end
  end
end
