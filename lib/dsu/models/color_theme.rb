# frozen_string_literal: true

require 'active_model'
require_relative '../support/descriptable'
require_relative '../validators/description_validator'

module Dsu
  module Models
    module ColorTheme
      DEFAULT_THEME = {
        description: 'Default theme',
        entry_group: :highlight,
        entry: :highlight,
        status_info: :cyan,
        status_success: :green,
        status_warning: :yellow,
        status_error: :red,
        state_highlight: :cyan
      }
      DEFAULT_THEME_NAME = 'default'

      # class << self
      #   def current
      #     load(theme: :current)
      #   end

      #   def load(theme:)
      #     Theme.load(theme: theme)
      #   end
      # end

      # This class represents a dsu color theme.
      class Theme
        include ActiveModel::Model
        include Support::Descriptable

        validates_with Validators::DescriptionValidator

        attr_reader :name,
          :description,
          :entry,
          :entry_group,
          :state_highlight,
          :status_error,
          :status_info,
          :status_success,
          :status_warning

        # class << self
        #   # Loads the theme from disk.
        #   def load(theme:)
        #   end
        # end

        def initialize(theme_name:, theme_hash: {})
          @name = theme_name
          theme_hash.each { |key, value| send("#{key}=", value) }
        end

        private

        attr_writer :name,
          :description,
          :entry,
          :entry_group,
          :state_highlight,
          :status_error,
          :status_info,
          :status_success,
          :status_warning
      end
    end
  end
end
