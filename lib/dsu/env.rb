# frozen_string_literal: true

module Dsu
  class << self
    def env
      @env ||= Struct.new(:env) do
        def test?
          env.fetch('DSU_ENV', nil) == 'test'
        end

        def development?
          env.fetch('DSU_ENV', nil) == 'development'
        end

        def local?
          test? || development?
        end

        def production?
          env.fetch('DSU_ENV', 'production') == 'production'
        end
      end.new(ENV)
    end
  end
end
