# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'i18n'
require 'thor'
require 'time'

I18n.load_path += Dir[File.join(__dir__, 'locales/**/*', '*.yml')]
# I18n.default_locale = :en # (note that `en` is already the default!)

Dir.glob("#{__dir__}/core/**/*.rb").each do |file|
  require file
end

Array.include(WrapAndJoin)
Hash.include(ColorThemeColors)
Hash.include(ColorThemeMode)

require_relative 'dsu/env'
require 'pry-byebug' if Dsu.env.development?

Dir.glob("#{__dir__}/dsu/**/*.rb").each do |file|
  require file
end

unless Dsu.env.test? || Dsu.env.development?
  if Dsu::Migration::Service.run_migrations?
    begin
      Dsu::Migration::Service.new.call
    rescue StandardError => e
      puts I18n.t('migrations.error.failed', message: e.message)
      exit 1
    end
  end
  # TODO: Hack. Integrate this into the migration service
  # so that this runs only if the migration version changes.
  theme_file = 'light.json'
  destination_theme_file_path = File.join(Dsu::Support::Fileable.themes_folder, theme_file)
  unless File.exist?(destination_theme_file_path)
    source_theme_file_path = File.join(Dsu::Support::Fileable.seed_data_folder, 'themes', theme_file)
    FileUtils.cp(source_theme_file_path, destination_theme_file_path)
    puts I18n.t('migrations.information.theme_copied', from: source_theme_file_path, to: destination_theme_file_path)
  end
end
