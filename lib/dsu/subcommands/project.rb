# frozen_string_literal: true

require_relative '../presenters/project/create_presenter'
require_relative '../presenters/project/delete_presenter'
require_relative '../presenters/project/list_presenter'
require_relative '../presenters/project/use_presenter'
require_relative '../views/project/create'
require_relative '../views/project/use'
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
        project_name = options[:project_name]
        description = options[:description]
        presenter = Presenters::Project::CreatePresenter.new(project_name: project_name,
          description: description, options: options)
        Views::Project::Create.new(presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.delete.desc'), I18n.t('subcommands.project.delete.usage')
      long_desc I18n.t('subcommands.project.delete.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def delete(project_name_or_number = nil)
        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = Presenters::Project::DeletePresenter.new(project_name_or_number: project_name_or_number,
          options: options)
        Views::Project::Delete.new(presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.list.desc'), I18n.t('subcommands.project.list.usage')
      long_desc I18n.t('subcommands.project.list.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def list
        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = Presenters::Project::ListPresenter.new(options: options)
        Views::Project::List.new(presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.show.desc'), I18n.t('subcommands.project.show.usage')
      long_desc I18n.t('subcommands.project.show.long_desc')
      option :project_name, type: :string, required: true, aliases: '-n', banner: 'PROJECT_NAME'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def show
        # Views::Import.new(presenter: all_presenter(import_file_path: options[:import_file],
        #  options: options)).render
      end

      desc I18n.t('subcommands.project.use.desc'), I18n.t('subcommands.project.use.usage')
      long_desc I18n.t('subcommands.project.use.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def use(project_name_or_number = nil)
        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = Presenters::Project::UsePresenter.new(project_name_or_number: project_name_or_number,
          options: options)
        Views::Project::Use.new(presenter: presenter, options: options).render
      end
    end
  end
end
