# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'i18n'
require 'thor'
require 'time'

I18n.load_path += Dir["#{File.expand_path('config/locales/**/*')}/*.yml"]
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

if !(Dsu.env.test? || Dsu.env.development?) && Dsu::Migration::Service.run_migrations?
  begin
    Dsu::Migration::Service.new.call
  rescue StandardError => e
    puts I18n.t('errors.migration.error', message: e.message)
    exit 1
  end
end
