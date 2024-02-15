# frozen_string_literal: true

require_relative 'service_20230613121411'
require_relative 'service_20240210161248'

module Dsu
  module Migration
    class Factory
      class << self
        def migrate_if!(options: {})
          Service20230613121411.new(options: options).migrate_if!
          Service20240210161248.new(options: options).migrate_if!
        rescue StandardError => e
          puts I18n.t('migrations.error.failed', message: e.message)
          exit 1
        end
      end
    end
  end
end
