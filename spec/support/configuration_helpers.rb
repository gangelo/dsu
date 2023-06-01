# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ConfigurationHelpers
  def config_file_exist?
    Dsu::Models::Configuration.config_file_exist?
  end

  def create_config_file!
    config_hash = Dsu::Models::Configuration::DEFAULT_CONFIGURATION
    Dsu::Services::Configuration::WriterService.new(config_hash: config_hash).call unless config_file_exist?
  end

  # NOTE: This overwrites any existing config file!
  def create_config_file_using!(config_hash:)
    Dsu::Services::Configuration::WriterService.new(config_hash: config_hash).call
  end

  def delete_config_file!
    # TODO: Change this once the Dsu::Services::Configuration::DeleterService
    # is implemented.
    config.delete_config_file! if config_file_exist?
  end

  def config
    @config ||= Class.new do
      include Dsu::Models::Configuration
    end.new
  end
end
