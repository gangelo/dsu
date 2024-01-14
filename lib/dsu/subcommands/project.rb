# frozen_string_literal: true

require_relative '../views/import'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Project < BaseSubcommand
      # TODO: I18n.
      map %w[c] => :create
      map %w[d] => :delete
      map %w[l] => :list
      map %w[s] => :show
      map %w[u] => :use

      desc I18n.t('subcommands.project.create.desc'), I18n.t('subcommands.project.create.usage')
      long_desc I18n.t('subcommands.project.create.long_desc')
      option :project_name, type: :string, required: true, aliases: '-n', banner: 'PROJECT_NAME'
      option :description, type: :string, required: false, aliases: '-d', banner: 'DESCRIPTION'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def create
        # Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
        #  options: options)).render
      end

      desc I18n.t('subcommands.project.delete.desc'), I18n.t('subcommands.project.delete.usage')
      long_desc I18n.t('subcommands.liet.delete.long_desc')
      option :project_name, type: :string, required: true, aliases: '-n', banner: 'PROJECT_NAME'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def delete
        # Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
        #  options: options)).render
      end

      desc I18n.t('subcommands.project.list.desc'), I18n.t('subcommands.project.list.usage')
      long_desc I18n.t('subcommands.liet.list.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def list
        # Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
        #  options: options)).render
      end

      desc I18n.t('subcommands.project.show.desc'), I18n.t('subcommands.project.show.usage')
      long_desc I18n.t('subcommands.liet.show.long_desc')
      option :project_name, type: :string, required: true, aliases: '-n', banner: 'PROJECT_NAME'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def show
        # Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
        #  options: options)).render
      end

      desc I18n.t('subcommands.project.use.desc'), I18n.t('subcommands.project.use.usage')
      long_desc I18n.t('subcommands.liet.use.long_desc')
      option :project_name, type: :string, required: true, aliases: '-n', banner: 'PROJECT_NAME'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def use
        # Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
        #  options: options)).render
      end
    end
  end
end
