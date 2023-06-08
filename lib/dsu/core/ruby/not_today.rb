# frozen_string_literal: true

# require 'active_support/core_ext/date/calculations'

# module DateAndTime
#   module Calculations
#     def not_today?
#       !today?
#     end
#   end
# end

module NotToday
  def not_today?
    !today?
  end
end
