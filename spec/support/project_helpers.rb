# frozen_string_literal: true

module ProjectHelpers
  def current_project
    Dsu::Models::Project.current_project
  end

  def default_project
    Dsu::Models::Project.default_project
  end
end
