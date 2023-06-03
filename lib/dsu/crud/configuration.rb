# frozen_string_literal: true

require 'psych'

module Dsu
  module Crud
    module Configuration
      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def delete!
        self.class.delete!
      end

      def exist?
        self.class.exist?
      end

      def save
        self.class.save(config: self)
      end

      def save!
        self.class.save!(config: self)
      end

      module ClassMethods
        def delete!
          raise "Config file does not exist: \"#{config_path}\"" unless exist?

          delete
        end

        def delete
          return false unless exist?

          File.delete(config_path)

          true
        end

        def exist?
          File.exist?(config_path)
        end

        def find
          config_hash = Psych.safe_load(File.read(config_path), [Symbol])
          new(config_hash: config_hash)
        end

        def find_or_create
          return find if exist?

          new(config_hash: self::DEFAULT_CONFIGURATION)
        end

        def save(config:)
          return false unless config.valid?

          File.write(config_path, Psych.dump(config.to_h))

          true
        end

        def save!(config:)
          config.validate!

          save(config: config)

          config
        end

        def config_file
          '.dsu'
        end

        def config_path
          File.join(config_folder, config_file)
        end

        def config_folder
          root_folder
        end
      end
    end
  end
end
