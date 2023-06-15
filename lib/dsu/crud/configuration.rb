# frozen_string_literal: true

require 'json'
require_relative '../services/configuration/hydrator_service'
require_relative '../support/fileable'

module Dsu
  module Crud
    module Configuration
      include Support::Fileable

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
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
        def exist?
          File.exist?(config_path)
        end

        def save(config:)
          return false unless config.valid?

          FileUtils.mkdir_p config_folder
          File.write(config_path, JSON.pretty_generate(config.to_h))

          true
        end

        def save!(config:)
          config.validate!

          save(config: config)

          config
        end
      end
    end
  end
end
