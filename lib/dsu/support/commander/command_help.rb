# frozen_string_literal: true

module Dsu
  module Support
    module Commander
      module CommandHelp
        private

        def command_help_for(command:, desc:, long_desc: nil, options: {}, commands: [])
          help =
            <<~HELP
              #{command_namespace} #{command}#{' [OPTIONS]' if options.any?} - #{desc}
              #{'OPTIONS:' if options.any?}
              #{options_help_for options}
              #{'OPTION ALIASES:' if any_option_aliases_for?(options)}
              #{options_aliases_help_for options}
              #{'---' unless long_desc.blank?}
              #{long_desc}
            HELP
          help.gsub(/\n{2,}/, "\n")
        end

        def options_help_for(options)
          options.map do |option, data|
            type = option_to_a(data[:type])&.join(' | ')
            type = :boolean if type.blank?
            "#{option} <#{type}>, default: #{data[:default]}"
          end.join("\n")
        end

        def options_aliases_help_for(options)
          return unless any_option_aliases_for?(options)

          options.filter_map do |option, data|
            aliases = option_to_a(data[:aliases])&.join(' | ')
            <<~HELP
              #{option} aliases: [#{aliases}]
            HELP
          end.join("\n")
        end

        def any_option_aliases_for?(options)
          options.keys.any? { |key| options.dig(key, :aliases).any? }
        end

        def option_to_a(option)
          return [] if option.blank?
          return option if option.is_a? Array

          [option]
        end
      end
    end
  end
end
