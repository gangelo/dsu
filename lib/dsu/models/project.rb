# frozen_string_literal: true

require 'fileutils'

require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../models/configuration'
require_relative '../services/project/hydrator_service'
require_relative '../support/descriptable'
require_relative '../support/fileable'
require_relative '../support/project_file_system'
require_relative '../validators/description_validator'
require_relative '../validators/project_name_validator'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents a project. A project is a collection of entry groups.
    class Project
      include ActiveModel::Model
      include Support::Descriptable
      include Support::Fileable
      include Support::ProjectFileSystem

      VERSION = Migration::VERSION
      MIN_PROJECT_NAME_LENGTH = 2
      MAX_PROJECT_NAME_LENGTH = 12
      MIN_DESCRIPTION_LENGTH = 2
      MAX_DESCRIPTION_LENGTH = 256

      attr_reader :project_name, :current_project_file, :description, :version, :options

      validates_with Validators::DescriptionValidator
      validates_with Validators::ProjectNameValidator
      validates_with Validators::VersionValidator

      def initialize(project_name:, description: nil, version: nil, options: {})
        raise ArgumentError, 'project_name is blank' if project_name.blank?
        raise ArgumentError, 'version is the wrong object type' unless version.is_a?(Integer) || version.nil?

        self.project_name = project_name
        self.description = description
        self.version = version || VERSION
        self.options = options || {}
      end

      # Override == and hash so that we can compare Entry Group objects.
      def ==(other)
        other.is_a?(Project) &&
          project_name == other.project_name &&
          description == other.description &&
          version == other.version
      end
      alias eql? ==

      def create
        self.class.create(project_name: project_name, description: description)
      end
      alias save create

      def create!
        self.class.create!(project_name: project_name, description: description)
      end
      alias save! create!

      def current_project?
        project_name == self.class.current_project_name
      end

      def default!
        return if default_project?

        self.class.default!(project: self)
      end

      def default_project?
        project_name == self.class.default_project_name
      end

      # def delete
      #   self.class.delete(project_name: project_name)
      # end

      # def delete!
      #   self.class.delete!(time: time)
      # end

      def hash
        [project_name, description, version].map(&:hash).hash
      end

      def project_file
        self.class.project_file(project_name: project_name)
      end

      def project_folder
        self.class.project_folder(project_name: project_name)
      end

      def to_h
        {
          version: version,
          project_name: project_name,
          description: description
        }
      end

      # def update
      #   self.class.update(project_name: project_name, description: description, version: version, options: options)
      # end

      # def update!
      #   self.class.update!(project_name: project_name, description: description, version: version, options: options)
      # end

      def use!
        return if current_project?

        self.class.use!(project: self)
      end

      class << self
        delegate :project_folder_for, to: Support::Fileable

        def all
          project_metadata.map do |metadata|
            find(project_name: metadata[:project_name])
          end
        end

        # def any?
        #   project_metadata.any?
        # end

        def create(project_name:, description: nil, options: {})
          Models::Project.new(project_name: project_name, description: description, options: options).tap do |project|
            project.validate!
            initialize_project(project_name: project_name)
            Crud::JsonFile.write!(file_data: project.to_h,
              file_path: project_file_for(project_name: project_name))
          end
        end

        def create!(project_name:, description: nil, options: {})
          if exist?(project_name: project_name)
            raise I18n.t('models.project.errors.already_exists', project_name: project_name)
          end

          create(project_name: project_name, description: description, options: options)
        end

        def current_project
          find(project_name: current_project_name)
        end

        def default!(project:)
          project.validate!

          Models::Configuration.new.tap do |configuration|
            configuration.default_project = project.project_name
            configuration.save!
          end
        end

        def default_project
          find(project_name: default_project_name)
        end

        # def delete(project_name:)
        #   # TODO: read all entry groups and delete them
        #   # TODO: delete the project folder
        #   # superclass.delete(file_path: project_folder_for(project_name: project_name))
        # end

        # def delete!(project_name:)
        #   # TODO: read all entry groups and delete them
        #   # TODO: delete the project folder
        #   # superclass.delete!(file_path: project_folder_for(project_name: project_name))
        # end

        def find(project_name:)
          unless project_folder_exist?(project_name: project_name)
            raise I18n.t('models.project.errors.does_not_exist', project_name: project_name)
          end

          project_file_path = project_file_for(project_name: project_name)

          unless project_file_exist?(project_name: project_name)
            raise I18n.t('models.project.errors.project_file_not_exist', project_file: project_file_path)
          end

          project_hash = Crud::JsonFile.read!(file_path: project_file_path)
          Services::Project::HydratorService.new(project_hash: project_hash).call
        end

        # project_number is 1 based.
        def find_by_number(project_number:)
          project = project_metadata.find do |metadata|
            metadata[:project_number] == project_number
          end
          return unless project

          find(project_name: project[:project_name])
        end

        # def find_or_create(project_name:)
        #   find_or_initialize(project_name: project_name).tap do |project|
        #     project.write! unless project.persisted?
        #   end
        # end

        # def find_or_initialize(project_name:)
        #   project_path = project_folder_for(project_name: project_name)
        #   # Dif.exist?(project_path) do |project_hash|
        #   #   Services::Project::HydratorService.new(project_hash: project_hash).call
        #   # end || new(project_name: project_name)
        #   if Dir.exist?(project_path)
        #     Crud::JsonFile.read!(file_path: project_path).fetch(:project).tap do |project_name|
        #       # description = "#{project_name.capitalize} project}"
        #       # unless project_exist?(project_name: project_name)
        #       #   create!(project_name: project_name, description: description)
        #       # end
        #     end
        #   else
        #     # TODO: Create
        #   end
        # end

        # def update(project_name:, description:, version:, options:)
        #   # TODO: Update the project
        # end

        # def update!(project_name:, description:, version:, options:)
        #   # TODO: Update the project
        # end

        def use!(project:)
          project.validate!

          current_project_hash = { version: project.version, project_name: project.project_name }
          Crud::JsonFile.write!(file_data: current_project_hash, file_path: current_project_file)
        end
      end

      private

      attr_writer :current_project_file, :options, :version

      def description=(value)
        description = if value.blank?
          "#{project_name.capitalize} project"
        else
          value
        end
        @description = description
      end

      def project_name=(value)
        @project_name = begin
          @current_project_file = project_folder_for(project_name: value)
          value
        end
      end
    end
  end
end
