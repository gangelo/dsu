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
        self.class.save(config_hash: to_h)
      end

      def save!
        self.class.save!(config_hash: to_h)
      end

      module ClassMethods
        def delete!
          raise "Config file does not exist: \"#{config_path}\"" unless exist?

          delete
        end

        def delete
          return unless exist?

          File.delete(config_path)
        end

        def exist?
          File.exist?(config_path)
        end

        def find
          Psych.safe_load(File.read(config_path), [Symbol])
        end

        def save(config_hash:)
          new(config_hash: config_hash).validate!

          File.write(config_path, Psych.dump(config_hash))
        end

        def save!(config_hash:)
          save(config_hash: config_hash)
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
