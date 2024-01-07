# frozen_string_literal: true

module Dsu
  class << self
    def env # rubocop:disable Metrics/MethodLength
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

        def screen_shot_mode?
          development? && (env.fetch('SCREEN_SHOT_USERNAME', '').present? ||
            env.fetch('SCREEN_SHOT_HOSTNAME', '').present?)
        end

        def screen_shot_prompt
          username = screen_shot_username
          hostname = screen_shot_hostname
          "#{username}@#{hostname}:~ $"
        end

        def screen_shot_username
          env.fetch('SCREEN_SHOT_USERNAME', 'username')
        end

        def screen_shot_hostname
          env.fetch('SCREEN_SHOT_HOSTNAME', 'hostname')
        end
      end.new(ENV)
    end
  end
end
