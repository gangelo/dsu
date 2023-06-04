# frozen_string_literal: true

require 'thor'

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
          @migrate_folder ||= File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/migrate')
        end
      end

      desc 'migration', 'Creates dsu migration file in the `migrate` folder.'
      long_desc <<-LONG_DESC
        NAME

        `dsu generate migration [OPTION]` -- will create dsu migration file in the dsu `migrate` folder ("#{migrate_folder}") given an option OPTION.

        SYNOPSIS

        dsu generate|-g migration [OPTION]

        OPTIONS

        -c|--config: Creates dsu config file migration in the dsu `migrate` folder ("#{migrate_folder}").
      LONG_DESC
      option :config, type: :boolean, aliases: '-c', default: false
      def migration(migration_name)
        # TODO: Perform validations.
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

      def migration_file_for(migration_name)
        [
          File.join(migrate_folder, time.strftime("%Y%m%d%H%M%S_#{migration_name.underscore}.rb")),
          migration_name.camelize
        ]
      end

      def migration_file_content(migration_class, type: nil)
        return config_migration_file_content(migration_class) if type == :config

        <<~MIGRATION_FILE_CONTENT
          # frozen_string_literal: true

          require_relative '../dsu/migrations/migrator_service'

          module Dsu
            module Migrate
              class #{migration_class} < Migration::MigratorService
              end
            end
          end
        MIGRATION_FILE_CONTENT
      end

      def config_migration_file_content(migration_class)
        <<~MIGRATION_FILE_CONTENT
          # frozen_string_literal: true

          require_relative '../dsu/migration/configuration_migrator_service'
          require_relative '../dsu/models/configuration'

          module Dsu
            module Migrate
              class #{migration_class} < Migration::ConfigurationMigratorService
                def call
                  # No sense in updating anything if we're not saving anything to disk.
                  if Models::Configuration.exist?
                    # TODO: Make your configuration changes here; for example:
                    # config_hash[:my_change] = 'my change'
                    # config_hash.delete(:delete_me)
                  end

                  super
                end

                private

                def migration_version
                  File.basename(__FILE__).match(MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
                end
              end
            end
          end

          # Run it
          migration = Dsu::Migrate::#{migration_class}.new
          migration.call if migration.migrate?
        MIGRATION_FILE_CONTENT
      end
    end
  end
end
