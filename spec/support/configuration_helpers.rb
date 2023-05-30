# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ConfigurationHelpers
  def create_config_file!
    config_hash = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS
    service = Dsu::Services::Configuration::WriterService.new(config_hash: config_hash)
    service.call unless service.config_file_exist?
  end

  # NOTE: This overwrites any existing config file!
  def create_config_file_using!(config_hash:)
    Dsu::Services::Configuration::WriterService.new(config_hash: config_hash).call
  end

  def delete_config_file!
    # TODO: Change this once the Dsu::Services::Configuration::DeleterService
    # is implemented.
    config.delete_config_file! if config.config_file_exist?
  end

  def config_with_bad_config_file
    # TODO: Replce this.
    @config_with_bad_config_file ||= Class.new do
      include Dsu::Support::Configuration

      def config_file
        # Bad config file.
        folder = File.dirname(original_config_file)
        original_config_file.gsub(folder, Random.uuid)
      end

      private

      def original_config_file
        method = Dsu::Support::Configuration.instance_method(:config_file)
        method.bind_call(self)
      end
    end.new
  end

  def config
    @config ||= Class.new do
      include Dsu::Support::Configuration
    end.new
  end
end
