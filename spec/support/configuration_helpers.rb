# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ConfigurationHelpers
  def config_file_exist?
    Dsu::Models::Configuration.exist?
  end

  def create_config_file!
    Dsu::Models::Configuration.default.save! unless config_file_exist?
  end

  # NOTE: This overwrites any existing config file!
  def create_config_file_using!(config_hash:)
    Dsu::Models::Configuration.new(config_hash: config_hash).save!
  end

  def delete_config_file!
    Dsu::Models::Configuration.current.delete
  end

  def config
    @config ||= Dsu::Models::Configuration.current_or_default
  end
end
