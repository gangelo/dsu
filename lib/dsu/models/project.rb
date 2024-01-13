# frozen_string_literal: true

require 'fileutils'

require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../models/entry_group'
require_relative '../support/fileable'
require_relative '../support/presentable'
require_relative '../validators/description_validator'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents a project. A project is a collection of entry groups.
    class Project
      include ActiveModel::Model
      include Support::Fileable

      VERSION = Migration::VERSION

      attr_reader :project_name, :project_path, :description, :version, :options

      validates_with Validators::DescriptionValidator
      validates_with Validators::VersionValidator

      def initialize(project_name:, description:, version: nil, options: {})
        raise ArgumentError, 'project_name is blank' if project_name.blank?
        raise ArgumentError, 'project_name is not a String' unless project_name.is_a?(String)
        raise ArgumentError, 'description is blank' if description.blank?
        raise ArgumentError, 'description is not a String' unless description.is_a?(String)
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

      def exist?
        self.class.exist?(project_name: project_name)
      end
      alias persisted? exist?

      def hash
        [project_name, description, version].map(&:hash).hash
      end

      def to_h
        {
          version: version,
          project_name: project_name,
          description: description,
          project_path: project_path
        }
      end

      class << self
        delegate :project_path_for, to: Support::Fileable

        def create(project_name:, description:)
          project_path_for(project_name: project_name).tap do |project_path|
            FileUtils.mkdir_p(project_path)
            file_data = { version: VERSION, project_name: project_name, description: description }
            Crud::JsonFile.write(file_data: file_data, file_path: project_file_path_for(project_path: project_path))
          end
        end

        def create!(project_name:, description:)
          if exist?(project_name: project_name)
            raise I18n.t('models.project.errors.already_exists', project_name: project_name)
          end

          create(project_name: project_name, description: description)
        end

        def current_project
          project_path = Support::Fileable.project_path
          Crud::JsonFile.read!(file_path: project_path).fetch(:project).tap do |project_name|
            description = "#{project_name.capitalize} project}"
            create!(project_name: project_name, description: description) unless exist?(project_name: project_name)
          end
        end

        # def all
        #   entry_groups.filter_map do |file_path|
        #     entry_group_file_name = File.basename(file_path)
        #     next unless entry_file_name.match?(ENTRIES_FILE_NAME_REGEX)

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
        #   # superclass.delete(file_path: project_path_for(project_name: project_name))
        # end

        # def delete!(project_name:)
        #   # TODO: read all entry groups and delete them
        #   # TODO: delete the project folder
        #   # superclass.delete!(file_path: project_path_for(project_name: project_name))
        # end

        def exist?(project_name:)
          File.exist?(project_path_for(project_name: project_name))
        end
        alias persisted? exist?

        # def entry_groups(between:)
        #   entry_group_times(between: between).filter_map do |time|
        #     Models::EntryGroup.find(time: Time.parse(time))
        #   end
        # end

        # def find(time:)
        #   file_path = entries_path_for(time: time)
        #   entry_group_hash = read!(file_path: file_path)
        #   Services::EntryGroup::HydratorService.new(entry_group_hash: entry_group_hash).call
        # end

        # def find_or_create(project_name:)
        #   find_or_initialize(project_name: project_name).tap do |project|
        #     project.write! unless project.exist?
        #   end
        # end

        # def find_or_initialize(project_name:)
        #   project_path = project_path_for(project_name: project_name)
        #   read(project_path: project_path) do |project_hash|
        #     Services::Project::HydratorService.new(project_hash: project_hash).call
        #   end || new(project_name: project_name)
        # end

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

        # def project_path_for(project_name:)
        #   Support::Fileable.project_path_for(project_name: project_name)
        # end

        # def entry_files
        #   project_path = File.join(project_path_for(project_name: project_name))
        #   Dir.glob("#{Support::Fileable.entries_folder}/*")
        # end

        private

        def project_file_path_for(project_path:)
          File.join(project_path, Support::Fileable.project_file_name)
        end
      end

      private

      attr_writer :description, :project_path, :options, :version

      def project_name=(value)
        @project_name = value
        @project_path = project_path_for(project_name: @project_name)
      end
    end
  end
end
