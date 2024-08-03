# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class ListPresenter < BasePresenterEx
        def initialize(options: {})
          super
        end

        def projects
          @projects ||= Dsu::Models::Project.all
        end

        private

        attr_reader :options
      end
    end
  end
end
