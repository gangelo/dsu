# frozen_string_literal: true

require_relative 'time'
require_relative 'time_mnemonic'

module Dsu
  module Support
    module CommandOptions
      module DsuTimes
        module_function

        # Returns an array of Time objects. The first element is the "from" time.
        # The second element is the "to" time. Both arguments are expected to be
        # command options that are time strings, time or relative time mnemonics.
        def dsu_times_for(from_option:, to_option:)
          from_time = dsu_from_time_for(from_option: from_option)
          to_time = dsu_to_time_for(to_option: to_option, from_time: from_time)

          errors = []
          errors << I18n.t('errors.from_option_invalid', from_option: from_option) if from_time.nil?
          errors << I18n.t('errors.to_option_invalid', to_option: to_option) if to_time.nil?
          return [[], errors] if errors.any?

          min_time, max_time = [from_time, to_time].minmax
          [(min_time.to_date..max_time.to_date).map(&:to_time), []]
        end

        def dsu_from_time_for(from_option:)
          return if from_option.nil?

          from_time = if TimeMnemonic.time_mnemonic?(from_option)
            TimeMnemonic.time_from_mnemonic(command_option: from_option)
          end
          from_time || Time.time_from_date_string(command_option: from_option)
        end

        def dsu_to_time_for(to_option:, from_time:)
          to_time = if TimeMnemonic.relative_time_mnemonic?(to_option)
            TimeMnemonic.time_from_mnemonic(command_option: to_option, relative_time: from_time)
          elsif TimeMnemonic.time_mnemonic?(to_option)
            TimeMnemonic.time_from_mnemonic(command_option: to_option)
          end
          to_time || Time.time_from_date_string(command_option: to_option)
        end
      end
    end
  end
end
