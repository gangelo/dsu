# frozen_string_literal: true

module Dsu
  module Migration
    module Version20
      class MigrationService
        def version
          File.basename(__dir__).to_f
        end
      end
    end
  end
end
