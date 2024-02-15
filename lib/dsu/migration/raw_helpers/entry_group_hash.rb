# frozen_string_literal: true

module Dsu
  module Migration
    module RawHelpers
      module EntryGroupHash
        def to_h
          read.merge(version: version)
        end
      end
    end
  end
end
