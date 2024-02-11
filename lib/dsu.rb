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
  # TODO: This is upgrading from migrations version 0 to 20230613121411
  # Move this to to its own class and call from Migration::Factory.
  if Dsu::Migration::Service.run_migrations?
    begin
      Dsu::Migration::Service.new.call
    rescue StandardError => e
      puts I18n.t('migrations.error.failed', message: e.message)
      exit 1
    end
  end

  Dsu::Migration::Factory.migrate_if!(options: { pretend: false })
end
