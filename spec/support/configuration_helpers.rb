# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ConfigurationHelpers
  def create_config_file!
    config.create_config_file! unless config.config_file_exist?
  end

  def delete_config_file!
    config.delete_config_file! if config.config_file_exist?
  end

  def config_with_bad_config_file
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
