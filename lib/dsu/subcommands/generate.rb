# frozen_string_literal: true

require 'thor'

require_relative '../migration/service'

module Dsu
  module Subcommands
    class Generate < ::Thor
      map %w[m] => :migration

      default_command :help

      class << self
        def exit_on_failure?
          false
        end

        def migrate_folder
          Dsu::Migration::Service.migrate_folder
        end
      end

      desc 'migration', 'Creates dsu migration file in the `migrate` folder.'
      long_desc <<-LONG_DESC
        NAME

        `dsu generate migration` -- will create dsu migration file in the dsu `migrate` folder ("#{migrate_folder}") given an option OPTION.

        SYNOPSIS

        dsu generate|-g migration
      LONG_DESC
      option :config, type: :boolean, aliases: '-c', default: false
      def migration(migration_name)
        # TODO: Perform validations.
        puts "Migration service version: #{Dsu::Migration::Service::MIGRATION_SERVICE_VERSION}"
        create_migration_file(migration_name)
      end

      private

      def create_migration_file(migration_name)
        migration_file, migration_class = migration_file_for(migration_name)

        migration_file_content = if options[:config]
          migration_file_content(migration_class, type: :config)
        else
          migration_file_content(migration_class)
        end
        File.write(migration_file, migration_file_content)
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

          require_relative '../dsu/migration/service'
          require_relative '../dsu/models/color_theme'
          require_relative '../dsu/models/configuration'
          require_relative '../dsu/models/entry'
          require_relative '../dsu/models/entry_group'

          module Dsu
            module Migrate
              class #{migration_class} < Migration::Service[#{Dsu::Migration::Service::MIGRATION_SERVICE_VERSION}]
                unless migration.migrate?
                  raise 'This migration should not be run' \\
                        "this migration file migration version (\#{migration_version}) " \\
                        "is > the current migration version (\#{current_migration_version})."
                end

                def call
                  # TODO: Apply Configuration changes here.
                  # TODO: Apply Entry changes here.
                  # TODO: If all Entries in an entry group are updated,
                  #       apply Entry Group changes here.
                  # TODO: Apply Color Theme changes here.

                  super
                rescue StandardError => e
                  puts "Error running migration \#{File.basename(__FILE__)}: \#{e.message}"
                  raise
                end

                private

                def migration_version
                  File.basename(__FILE__).match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
                end
              end
            end
          end
        MIGRATION_FILE_CONTENT
      end
    end
  end
end
