# frozen_string_literal: true

require 'fileutils'

# require_relative '../support/presentable'
require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../models/entry_group'
require_relative '../services/project/hydrator_service'
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
      include Support::ProjectFileSystem
      include Support::Fileable

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
        raise ArgumentError, 'project_name is not a String' unless project_name.is_a?(String)
        raise ArgumentError, 'description is blank' if description.blank?
        raise ArgumentError, 'description is not a String' unless description.is_a?(String)
        raise ArgumentError, 'version is the wrong object type' unless version.is_a?(Integer) || version.nil?

        self.project_name = project_name
        self.description = description || "#{project_name.capitalize} project"
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

      # def clone
      #   self.class.new(project_name: project_name, description: description, version: version, options: options)
      # end

      def create
        self.class.create(project_name: project_name, description: description)
      end
      alias save create

      def create!
        self.class.create!(project_name: project_name, description: description)
      end
      alias save! create!

      # def delete
      #   self.class.delete(project_name: project_name)
      # end

      # def delete!
      #   self.class.delete!(time: time)
      # end

      # def exist?
      #   project_exist?
      # end
      # alias persisted? exist?

      # # Returns true if the project folder exists
      # def project_exist?
      #   self.class.project_exist?(project_name: project_name)
      # end
      # alias project_persisted? project_exist?

      # # Returns true if the project file exists
      # def file_exist?
      #   self.class.file_exist?(project_name: project_name)
      # end
      # alias file_persisted? file_exist?

      def hash
        [project_name, description, version].map(&:hash).hash
      end

      def to_h
        {
          version: version,
          project_name: project_name,
          description: description
        }
      end

      def update
        self.class.update(project_name: project_name, description: description, version: version, options: options)
      end

      def update!
        self.class.update!(project_name: project_name, description: description, version: version, options: options)
      end

      class << self
        delegate :project_folder_for, to: Support::Fileable

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
          current_project_file = Support::Fileable.current_project_file
          Crud::JsonFile.read!(file_path: current_project_file).fetch(:project).tap do |project_name|
            # description = "#{project_name.capitalize} project}"
            # unless project_exist?(project_name: project_name)
            #   create!(project_name: project_name, description: description)
            # end
          end
        end

        # def all
        #   entry_groups.filter_map do |file_path|
        #     entry_group_file_name = File.basename(file_path)
        #     next unless entry_file_name.match?(ENTRIES_FILE_NAME_REGEX)
        #
        #     entry_date = File.basename(entry_file_name, '.*')
        #     find time: Time.parse(entry_date)
        #   end
        # end

        # def any?
        #   entry_files.any? do |file_path|
        #     entry_date = File.basename(file_path, '.*')
        #     entry_date.match?(ENTRIES_FILE_NAME_TIME_REGEX)
        #   end
        # end

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

        def project_exist?(project_name:)
          Dir.exist?(project_folder_for(project_name: project_name))
        end
        alias project_persisted? project_exist?

        def file_exist?(project_name:)
          return false unless project_exist?(project_name: project_name)

          File.exist?(current_project_file_path_for(current_project_file: project_folder_for(project_name: project_name)))
        end
        alias file_persisted? file_exist?

        # def entry_groups(between:)
        #   entry_group_times(between: between).filter_map do |time|
        #     Models::EntryGroup.find(time: Time.parse(time))
        #   end
        # end

        def find(project_name:)
          unless project_exist?(project_name: project_name)
            raise I18n.t('models.project.errors.does_not_exist', project_name: project_name)
          end

          project_file_path = current_project_file_path_for(current_project_file: current_project_file)

          unless file_exist?(project_name: project_name)
            raise I18n.t('models.project.errors.project_file_not_exist', project_file: project_file_path)
          end

          project_hash = Crud::JsonFile.read!(file_path: project_file_path)
          Services::Project::HydratorService.new(project_hash: project_hash).call
        end

        def find_or_create(project_name:)
          find_or_initialize(project_name: project_name).tap do |project|
            project.write! unless project.persisted?
          end
        end

        def find_or_initialize(project_name:)
          project_path = project_folder_for(project_name: project_name)
          # Dif.exist?(project_path) do |project_hash|
          #   Services::Project::HydratorService.new(project_hash: project_hash).call
          # end || new(project_name: project_name)
          if Dir.exist?(project_path)
            Crud::JsonFile.read!(file_path: project_path).fetch(:project).tap do |project_name|
              # description = "#{project_name.capitalize} project}"
              # unless project_exist?(project_name: project_name)
              #   create!(project_name: project_name, description: description)
              # end
            end
          else
            # TODO: Create
          end
        end

        # def write(file_data:, file_path:)
        #   if file_data[:entry_groups].empty?
        #     superclass.delete(file_path: file_path)
        #     return true
        #   end

        #   super
        # end

        # def write!(file_data:, file_path:)
        #   if file_data[:entries].empty?
        #     superclass.delete!(file_path: file_path)
        #     return
        #   end

        #   super
        # end

        # def project_folder_for(project_name:)
        #   Support::Fileable.project_folder_for(project_name: project_name)
        # end

        # def entry_files
        #   current_project_file = File.join(project_folder_for(project_name: project_name))
        #   Dir.glob("#{Support::Fileable.entries_folder}/*")
        # end

        def update(project_name:, description:, version:, options:)
        end

        def update!(project_name:, description:, version:, options:)
        end

        private

        def current_project_file_path_for(current_project_file:)
          File.join(current_project_file, Support::Fileable.current_project_file_name)
        end
      end

      private

      attr_writer :description, :current_project_file, :options, :version

      def project_name=(value)
        @project_name = begin
          @current_project_file = project_folder_for(project_name: value)
          value
        end
      end
    end
  end
end
