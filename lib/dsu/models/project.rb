# frozen_string_literal: true

require 'active_model'
require 'fileutils'

require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../models/entry_group'
require_relative '../support/fileable'
require_relative '../support/presentable'
require_relative '../validators/version_validator'
require_relative 'entry'

module Dsu
  module Models
    # This class represents a project. A project is a collection of entry groups.
    class Project
      include ActiveModel::Model
      include Support::Fileable

      VERSION = Migration::VERSION

      attr_reader :project_name, :options

      # validates_with Validators::EntryGroupsValidator
      validates_with Validators::VersionValidator

      def initialize(project_name: nil, version: nil, options: {})
        unless project_name.is_a?(String) || project_name.nil?
          raise ArgumentError, 'project_name is the wrong object type'
        end
        raise ArgumentError, 'version is the wrong object type' unless version.is_a?(Integer) || version.nil?

        FileUtils.mkdir_p(build_project_path(project_name: project_name))

        super(build_project_path(project_name: project_name))

        @version = version || VERSION
        @options = options || {}
      end

      # Override == and hash so that we can compare Entry Group objects.
      def ==(other)
        false unless other.is_a?(Project) && version == other.version
      end
      alias eql? ==

      # def clone
      #   self.class.new(project_name: project_name, version: version)
      # end

      def create
        self.class.create(project_name: project_name)
      end

      def create!
        self.class.create!(project_name: project_name)
      end

      # def delete
      #   self.class.delete(project_name: project_name)
      # end

      # def delete!
      #   self.class.delete!(time: time)
      # end

      def exist?
        self.class.exist?(project_name: project_name)
      end

      def hash
        [project_name, version].map(&:hash).hash
      end

      def to_h
        {
          version: version,
          project_name: project_name
        }
      end

      class << self
        delegate :project_path_for, to: Support::Fileable
        def create(project_name:)
          FileUtils.mkdir_p(project_path_for(project_name: project_name)).any?
        end

        def create!(project_name:)
          if exist?(project_name: project_name)
            raise I18n.t('models.project.errors.already_exists', project_name: project_name)
          end
          unless create(project_name: project_name)
            raise I18n.t('models.project.errors.create_failed', project_name: project_name)
          end
        end

        def current_project
          project_path = Support::Fileable.project_path
          Crud::JsonFile.read!(file_path: project_path).fetch(:project).tap do |project_name|
            create!(project_name: project_name) unless exist?(project_name: project_name)
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
      end
    end
  end
end
