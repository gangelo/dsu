# frozen_string_literal: true

require_relative '../crud/json_file'

module Dsu
  module Migration
    class RawJsonFile < Crud::JsonFile
      public :read, :read!, :version=

      def to_h
        read.merge(version: version)
      end
    end
  end
end
