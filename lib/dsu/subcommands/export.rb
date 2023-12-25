# frozen_string_literal: true

require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mnemonic'
require_relative '../support/time_formatable'
require_relative '../views/export'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Export < BaseSubcommand
      include Support::CommandOptions::TimeMnemonic
      include Support::TimeFormatable

      # TODO: I18n.
      map %w[a] => :all
      map %w[dd] => :dates

      desc I18n.t('subcommands.export.all.desc'), I18n.t('subcommands.export.all.usage')
      long_desc I18n.t('subcommands.export.all.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def all
        Views::Export.new(presenter: all_presenter(options: options)).render
      end

      desc I18n.t('subcommands.export.dates.desc'), I18n.t('subcommands.export.dates.usage')
      long_desc I18n.t('subcommands.export.dates.long_desc',
        date_option_description: date_option_description,
        mnemonic_option_description: mnemonic_option_description)
      option :from, type: :string, required: true, aliases: '-f', banner: 'DATE|MNEMONIC'
      option :to, type: :string, required: true, aliases: '-t', banner: 'DATE|MNEMONIC'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def dates
        options = configuration.to_h.merge(self.options).with_indifferent_access
        times, errors = Support::CommandOptions::DsuTimes.dsu_times_for(from_option: options[:from], to_option: options[:to]) # rubocop:disable Layout/LineLength
        if errors.any?
          Views::Shared::Error.new(messages: errors).render
          return
        end

        times = times_sort(times: times, entries_display_order: options[:entries_display_order])
        Views::Export.new(presenter: dates_presenter_for(from: times.min, to: times.max, options: options)).render
      rescue ArgumentError => e
        Views::Shared::Error.new(messages: e.message).render
      end

      private

      def all_presenter(options:)
        Presenters::Export::AllPresenter.new(options: options)
      end

      def dates_presenter_for(from:, to:, options:)
        Presenters::Export::DatesPresenter.new(from: from, to: to, options: options)
      end
    end
  end
end
