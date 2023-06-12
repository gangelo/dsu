# frozen_string_literal: true

module Dsu
  module Migration
    class Service
      class << self
        def [](version)
          require_relative "#{version}/migration_service"

          "Dsu::Migration::Version#{version.to_s.delete('.')}::MigrationService".constantize
        end
      end
    end
  end
end
