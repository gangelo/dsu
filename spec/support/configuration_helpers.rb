# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ConfigurationHelpers
  def create_config_file!
    config.create_config_file! unless config.config_file?
  end

  def delete_config_file!
    config.delete_config_file! if config.config_file?
  end

  def config
    @config ||= Class.new do
      include Dsu::Support::Configuration
    end.new
  end
end
