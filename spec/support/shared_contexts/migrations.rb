# frozen_string_literal: true

RSpec.shared_context 'with migrations' do
  include_context 'with dirs'

  before do
    allow(Dsu::Migration::MigratorService).to receive(:migrate_folder).and_return(test_migrations_folder)
  end

  let(:migrate_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'migrate')).first }
  let(:test_migrations_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'test_migrations')).first }
end

RSpec.configure do |config|
  # config.include_context 'with migrations'
end
