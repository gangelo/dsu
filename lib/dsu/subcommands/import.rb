# frozen_string_literal: true

require_relative '../presenters/import/all_presenter'
require_relative '../presenters/import/dates_presenter'
require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mnemonic'
require_relative '../support/time_formatable'
require_relative '../views/import'
require_relative '../views/import_dates'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Import < BaseSubcommand
      include Support::CommandOptions::TimeMnemonic
      include Support::TimeFormatable

      # TODO: I18n.
      map %w[a] => :all
      map %w[dd] => :dates

      desc I18n.t('subcommands.import.all.desc'), I18n.t('subcommands.import.all.usage')
      long_desc I18n.t('subcommands.import.all.long_desc')
      option :import_file, type: :string, required: true, aliases: '-i', banner: 'IMPORT_CVS_FILE'
      option :merge, type: :boolean, default: true, aliases: '-m'
      option :override, type: :boolean, default: false, aliases: '-o'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def all
        options = configuration.to_h.merge(self.options).with_indifferent_access
        Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
          options: options), options: options).render
      end

      desc I18n.t('subcommands.import.dates.desc'), I18n.t('subcommands.import.dates.usage')
      long_desc I18n.t('subcommands.import.dates.long_desc',
        date_option_description: date_option_description,
        mnemonic_option_description: mnemonic_option_description)
      option :from, type: :string, required: true, aliases: '-f', banner: 'DATE|MNEMONIC'
      option :to, type: :string, required: true, aliases: '-t', banner: 'DATE|MNEMONIC'
      option :import_file, type: :string, required: true, aliases: '-i', banner: 'IMPORT_CVS_FILE'
      option :merge, type: :boolean, default: true, aliases: '-m'
      option :override, type: :boolean, default: false, aliases: '-o'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def dates
        options = configuration.to_h.merge(self.options).with_indifferent_access
        times, errors = Support::CommandOptions::DsuTimes.dsu_times_for(from_option: options[:from], to_option: options[:to]) # rubocop:disable Layout/LineLength
        if errors.any?
          Views::Shared::Error.new(messages: errors).render
          return
        end

        Views::ImportDates.new(presenter: dates_presenter_for(from: times.min,
          to: times.max,
          import_file_path: options[:import_file],
          options: options), options: options).render
      rescue ArgumentError => e
        Views::Shared::Error.new(messages: e.message).render
      end

      private

      def all_presenter(import_file_path:, options:)
        Presenters::Import::AllPresenter.new(import_file_path: import_file_path, options: options)
      end

      def dates_presenter_for(from:, to:, import_file_path:, options:)
        Presenters::Import::DatesPresenter.new(from: from, to: to, import_file_path: import_file_path, options: options)
      end
    end
  end
end
