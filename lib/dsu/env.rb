# frozen_string_literal: true

module Dsu
  class << self
    def env
      @env ||= Struct.new(:env) do
        def test?
          env.fetch('DSU_DEV', nil) == 'test'
        end

        def development?
          env.fetch('DSU_DEV', nil) == 'development'
        end

        def production?
          env.fetch('DSU_DEV', 'production') == 'production'
        end
      end.new(ENV)
    end
  end
end
