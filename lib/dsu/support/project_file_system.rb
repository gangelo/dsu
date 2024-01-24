# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../models/configuration'
require_relative 'fileable'

module Dsu
  module Support
    module ProjectFileSystem
      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def exist?
        self.class.project_file_exist?(project_name: project_name)
      end
      alias persisted? exist?

      def project_initialized?
        self.class.project_initialized?(project_name: project_name)
      end

      def project_number
        self.class.project_number_for(project_name: project_name)
      end

      module ClassMethods
        include Fileable

        # Returns the currently selected (used) project name
        # from dsu/current_project.json
        def current_project_name
          Crud::JsonFile.read!(file_path: current_project_file).fetch(:project_name)
        end

        def default_project_name
          Models::Configuration.new.default_project
        end

        def initialize_project(project_name:)
          return if project_initialized?(project_name: project_name)

          # TODO: Don't know if I like this here.
          unless current_project_file_exist?
            file_data = {
              version: Dsu::Migration::VERSION,
              project_name: default_project_name
            }
            Crud::JsonFile.write!(file_data: file_data, file_path: current_project_file)
          end

          # Creates dsu/projects/<project_name>
          FileUtils.mkdir_p(project_folder_for(project_name: project_name))
        end

        def project_initialized?(project_name:)
          # Checking these files, checks all the containing folders also
          current_project_file_exist? &&
            project_folder_exist?(project_name: project_name)
        end

        # Does dsu/projects/<project_name>/project.json file exist?
        def project_file_exist?(project_name:)
          project_file_path = project_file_for(project_name: project_name)
          File.exist?(project_file_path)
        end
        alias exist? project_file_exist?
        alias persisted? project_file_exist?

        # Does dsu/current_project.json file exist?
        def current_project_file_exist?
          File.exist?(current_project_file)
        end
        alias current_project_file_persisted? current_project_file_exist?

        # Does dsu/projects folder exist?
        def projects_folder_exist?
          Dir.exist?(projects_folder)
        end

        # Does dsu/projects/<project_name> folder exist?
        def project_folder_exist?(project_name:)
          Dir.exist?(project_folder_for(project_name: project_name))
        end

        def project_metadata
          project_folder_names.each_with_index.with_object([]) do |(project_name, index), array|
            array << {
              project_number: index + 1,
              project_name: project_name,
              current_project: project_name == current_project_name,
              default_projet: project_name == default_project_name
            }
          end
        end

        def project_number_for(project_name:)
          project_metadata.find do |metadata|
            metadata[:project_name] == project_name
          end&.[](:project_number) || -1
        end

        private

        def project_folder_names
          Pathname.new(projects_folder)
            .children
            .select(&:directory?)
            .map(&:basename)
            .map(&:to_s)
            .sort { |a, b| a.casecmp(b) }
        end
      end
    end
  end
end
