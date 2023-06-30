# frozen_string_literal: true

require 'psych'
require 'json'

# rubocop:disable Style/StringHashKeys, Style/NumericLiterals
module ConfigurationHelpers
  # Store configuration hashes per migration version so
  # that we can use these in migration testing.
  CONFIGURATION_HASHES =
    {
      '0' => {
        editor: 'vim',
        entries_display_order: 'asc',
        entries_file_name: '%Y-%m-%d.json',
        entries_folder: '/Users/gangelo/dsu/entries',
        carry_over_entries_to_today: true,
        include_all: true
      },
      '20230613121411' => {
        version: 20230613121411,
        editor: 'nano',
        entries_display_order: :desc,
        carry_over_entries_to_today: false,
        include_all: false,
        theme_name: 'matrix'
      }
    }.freeze

  def read_configuration_version0!(config_path:)
    raise ArgumentError, 'config_path must exist' unless File.exist?(config_path)

    Psych.safe_load(File.read(config_path), [Symbol]).transform_keys(&:to_sym)
  end

  def update_configuration_version0!(config_hash:, config_path:)
    raise ArgumentError, 'config_hash must be a Hash' unless config_hash.is_a?(Hash)
    raise ArgumentError, 'config_path must be a String' unless config_path.is_a?(String)
    raise ArgumentError, 'config_path must exist' unless File.exist?(config_path)

    old_config_hash = Psych.safe_load(File.read(config_path), [Symbol]).transform_keys(&:to_sym)
    File.write(config_path, old_config_hash.merge!(config_hash).to_yaml)
  end

  def read_configuration_version20230613121411!(config_path:)
    raise ArgumentError, 'config_path must exist' unless File.exist?(config_path)

    config_json = File.read(config_path)
    Dsu::Services::Configuration::HydratorService.new(config_json: config_json).call
  end

  def update_configuration_version20230613121411!(config_hash:, config_path:)
    raise ArgumentError, 'config_hash must be a Hash' unless config_hash.is_a?(Hash)
    raise ArgumentError, 'config_path must be a String' unless config_path.is_a?(String)
    raise ArgumentError, 'config_path must exist' unless File.exist?(config_path)

    old_config_json = File.read(config_path)
    old_config_hash = Dsu::Services::Configuration::HydratorService.new(config_json: old_config_json).call
    config_hash = old_config_hash.merge!(config_hash)
    File.write(config_path, JSON.pretty_generate(config_hash))
  end
end
# rubocop:enable Style/StringHashKeys, Style/NumericLiterals
