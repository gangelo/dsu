# frozen_string_literal: true

require_relative '../presenters/project/create_presenter'
require_relative '../presenters/project/delete_presenter'
require_relative '../presenters/project/list_presenter'
require_relative '../presenters/project/use_by_number_presenter'
require_relative '../presenters/project/use_presenter'
require_relative '../views/project/create'
require_relative '../views/project/use'
require_relative '../views/project/use_by_number'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Project < BaseSubcommand
      # TODO: I18n.
      map %w[c] => :create
      map %w[d] => :delete
      map %w[l] => :list
      map %w[r] => :rename
      map %w[u] => :use

      desc I18n.t('subcommands.project.create.desc'), I18n.t('subcommands.project.create.usage')
      long_desc I18n.t('subcommands.project.create.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def create(project_name = nil, description = nil)
        project_name = project_name.to_s.strip
        description = description.to_s.strip
        if project_name.blank?
          return Views::Shared::Error.new(
            messages: I18n.t('subcommands.project.messages.project_name_blank')
          ).render
        end

        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = Presenters::Project::CreatePresenter.new(project_name: project_name,
          description: description, options: options)
        Views::Project::Create.new(presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.delete.desc'), I18n.t('subcommands.project.delete.usage')
      long_desc I18n.t('subcommands.project.delete.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def delete(project_name_or_number = nil)
        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = delete_presenter_for(project_name_or_number, options: options)
        delete_view_for(project_name_or_number, presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.list.desc'), I18n.t('subcommands.project.list.usage')
      long_desc I18n.t('subcommands.project.list.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def list
        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = Presenters::Project::ListPresenter.new(options: options)
        Views::Project::List.new(presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.rename.desc'), I18n.t('subcommands.project.rename.usage')
      long_desc I18n.t('subcommands.project.rename.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def rename(project_name_or_number = nil, new_project_name = nil, new_project_description = nil)
        project_name_or_number = project_name_or_number.to_s.strip
        new_project_name = new_project_name&.to_s&.strip
        new_project_description = new_project_description&.to_s&.strip

        if new_project_name.blank?
          return Views::Shared::Error.new(
            messages: I18n.t('subcommands.project.messages.new_project_name_blank')
          ).render
        end

        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = rename_presenter_for(project_name_or_number, new_project_name: new_project_name,
          new_project_description: new_project_description, options: options)
        rename_view_for(project_name_or_number, presenter: presenter, options: options).render
      end

      desc I18n.t('subcommands.project.use.desc'), I18n.t('subcommands.project.use.usage')
      long_desc I18n.t('subcommands.project.use.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def use(project_name_or_number = nil)
        options = configuration.to_h.merge(self.options).with_indifferent_access
        presenter = use_presenter_for(project_name_or_number, options: options)
        use_view_for(project_name_or_number, presenter: presenter, options: options).render
      end

      private

      def delete_view_for(project_name, presenter:, options:)
        if project_number?(project_name)
          Views::Project::DeleteByNumber.new(presenter: presenter, options: options)
        else
          Views::Project::Delete.new(presenter: presenter, options: options)
        end
      end

      def delete_presenter_for(project_name, options:)
        if project_number?(project_name)
          Presenters::Project::DeleteByNumberPresenter.new(project_number: project_name.to_i, options: options)
        else
          project_name = Models::Project.default_project_name if project_name.blank?
          Presenters::Project::DeletePresenter.new(project_name: project_name, options: options)
        end
      end

      def rename_view_for(project_name, presenter:, options:)
        if project_number?(project_name)
          Views::Project::RenameByNumber.new(presenter: presenter, options: options)
        else
          Views::Project::Rename.new(presenter: presenter, options: options)
        end
      end

      def rename_presenter_for(project_name, new_project_name:, new_project_description:, options:)
        if project_number?(project_name)
          Presenters::Project::RenameByNumberPresenter.new(project_number: project_name.to_i,
            new_project_name: new_project_name, new_project_description: new_project_description, options: options)
        else
          project_name = Models::Project.default_project_name if project_name.blank?
          Presenters::Project::RenamePresenter.new(project_name: project_name,
            new_project_name: new_project_name, new_project_description: new_project_description, options: options)
        end
      end

      def use_view_for(project_name, presenter:, options:)
        if project_number?(project_name)
          Views::Project::UseByNumber.new(presenter: presenter, options: options)
        else
          Views::Project::Use.new(presenter: presenter, options: options)
        end
      end

      def use_presenter_for(project_name, options:)
        if project_number?(project_name)
          Presenters::Project::UseByNumberPresenter.new(project_number: project_name.to_i, options: options)
        else
          project_name = Models::Project.default_project_name if project_name.blank?
          Presenters::Project::UsePresenter.new(project_name: project_name, options: options)
        end
      end

      def project_number?(project_name)
        /^[+-]?\d+(\.\d+)?$/.match?(project_name.to_s)
      end
    end
  end
end
