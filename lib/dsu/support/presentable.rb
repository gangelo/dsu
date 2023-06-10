# frozen_string_literal: true

# Dir[File.expand_path('../presenters/*.rb', __dir__)].each do |file|
#   require_relative file
# end

module Dsu
  module Support
    module Presentable
      def presenter
        "Dsu::Presenters::#{self.class.name.demodulize}Presenter".constantize.new(self)
      end
    end
  end
end
