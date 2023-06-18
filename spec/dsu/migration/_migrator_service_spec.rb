# frozen_string_literal: true
# # frozen_string_literal: true

#
# RSpec.describe Dsu::Migration::MigratorService do
#   subject(:migrator_service) { described_class.new(object: object) }

#   include_context 'with migrations'

#   let(:object) { {} }

#   describe '#initialize' do
#     context 'when the arguments are invalid' do
#       let(:object) { nil }
#       let(:expected_error) { /object is nil/ }

#       it_behaves_like 'an error is raised'
#     end

#     context 'when the arguments are valid' do
#       let(:object) { :valid }

#       it_behaves_like 'no error is raised'

#       it 'sets the object attribute' do
#         expect(migrator_service.object).to eq(object)
#       end
#     end
#   end

#   describe 'class methods' do
#     subject(:migrator_service) { described_class }

#     before do
#       allow(described_class).to receive(:run_migration!)
#       allow(described_class).to receive(:migrate_folder).and_return(migrate_folder)
#     end

#     describe '.run_migrations!' do
#       context 'when there are no migrations to run' do
#         it 'does not run any migrations' do
#           migrator_service.run_migrations!
#           expect(described_class).not_to have_received(:run_migration!)
#         end
#       end

#       context 'when there are migrations to run' do
#         before do
#           allow(described_class).to receive(:migrate_folder).and_return(test_migrations_folder)
#         end

#         it 'runs the migrations' do
#           migrator_service.run_migrations!
#           expect(described_class).to have_received(:run_migration!).exactly(3).times
#         end
#       end
#     end
#   end

#   describe '#call' do
#     subject(:migrator_service_instance) { migrator_service.call }

#     let(:expected_error) { NotImplementedError }

#     it_behaves_like 'an error is raised'
#   end

#   describe '#migrate?' do
#     subject(:migrator_service_instance) { migrator_service }

#     context 'when the migration version is greater than the current migration version' do
#       before do
#         allow(migrator_service_instance).to receive(:migration_version).and_return(1)
#         allow(migrator_service_instance).to receive(:current_migration_version).and_return(0)
#       end

#       it 'returns true' do
#         expect(migrator_service_instance.migrate?).to eq(true)
#       end
#     end

#     context 'when the migration version is less than the current migration version' do
#       before do
#         allow(migrator_service_instance).to receive(:migration_version).and_return(1)
#         allow(migrator_service_instance).to receive(:current_migration_version).and_return(2)
#       end

#       it 'returns true' do
#         expect(migrator_service_instance.migrate?).to eq(false)
#       end
#     end

#     context 'when the migration version is equal to the current migration version' do
#       before do
#         allow(migrator_service_instance).to receive(:migration_version).and_return(3)
#         allow(migrator_service_instance).to receive(:current_migration_version).and_return(3)
#       end

#       it 'returns true' do
#         expect(migrator_service_instance.migrate?).to eq(false)
#       end
#     end
#   end
# end
# # rubocop:enable RSpec/SubjectStub
