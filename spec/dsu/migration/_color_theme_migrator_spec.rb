# # frozen_string_literal: true

# RSpec.shared_examples 'the color theme is updated' do
#   it 'updates the color theme' do
#     expect(subject.run).to eq expected_theme_hash
#   end
# end

# RSpec.describe Dsu::Migration::ColorThemeMigrator do
#   subject(:color_theme_migrator) do
#     described_class.new(theme_name: theme_name, theme_hash: theme_hash, options: options)
#   end

#   let(:theme_name) { Dsu::Models::ColorTheme::DEFAULT_THEME_NAME }
#   let(:theme_hash) { Dsu::Models::ColorTheme::DEFAULT_THEME }
#   let(:options) { {} }

#   describe '#initializer' do
#     context 'when the arguments are valid' do
#       it_behaves_like 'no error is raised'
#     end
#   end

#   describe '#run' do
#     context 'when the color theme hash version is the most recent version' do
#       context 'when a color theme key value is different' do
#         before do
#           color_theme_migrator.run
#         end

#         let(:theme_name) { 'test' }
#         let(:theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h.merge({
#             description: 'test description',
#           })
#         end
#         let(:expected_theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h.tap do |hash|
#             hash[:description] = theme_hash[:description]
#           end
#         end

#         it 'retains the color theme key value' do
#           expect(color_theme_migrator.run).to eq expected_theme_hash
#         end
#       end

#       context 'when the old color theme has extra hash key/value pairs' do
#         before do
#           color_theme_migrator.run
#         end

#         let(:theme_name) { 'test' }
#         let(:theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h.merge({
#             remove_me1: 'remove_me1',
#             remove_me2: 'remove_me2'
#           })
#         end
#         let(:expected_theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h
#         end

#         it 'removes the old color theme key/value pairs' do
#           expect(color_theme_migrator.run).to eq expected_theme_hash
#         end
#       end

#       context 'when the new color theme has extra hash key/value pairs' do
#         before do
#           stub_const('Dsu::Models::ColorTheme::DEFAULT_THEME', mocked_default_theme)
#           color_theme_migrator.run
#         end

#         let(:mocked_default_theme) do
#           Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |default_color_theme|
#             default_color_theme[:new_key] = 'new_value'
#           end
#         end
#         let(:theme_name) { 'test' }
#         let(:theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h
#         end
#         let(:expected_theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h.tap do |hash|
#             hash[:new_key] = 'new_value'
#           end
#         end

#         it 'adds the new color theme key/value pairs' do
#           expect(color_theme_migrator.run).to eq expected_theme_hash
#         end
#       end

#       context 'when a color theme key value is a different object type' do
#         before do
#           color_theme_migrator.run
#         end

#         let(:theme_name) { 'test' }
#         let(:theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h.merge({
#             description: :different_object_type
#           })
#         end
#         let(:expected_theme_hash) do
#           Dsu::Models::ColorTheme.default.to_h
#         end

#         it 'replaces the color theme key value' do
#           expect(color_theme_migrator.run).to eq expected_theme_hash
#         end
#       end

#       context 'when options: { force: } is true' do
#         before do
#           theme_hash
#           stub_const('Dsu::Models::ColorTheme::DEFAULT_THEME', mocked_default_theme)
#           color_theme_migrator.run
#         end

#         let(:mocked_default_theme) do
#           Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
#             hash.each_pair do |key, _value|
#               next if key == :version

#               hash[key] = "new_#{key}_value".to_sym
#             end
#           end
#         end
#         let(:theme_name) { 'test' }
#         let(:theme_hash) do
#           Dsu::Models::ColorTheme::DEFAULT_THEME.dup
#         end
#         let(:expected_theme_hash) do
#           Dsu::Models::ColorTheme::DEFAULT_THEME
#         end

#         it 'forces update of all color theme key values' do
#           expect(color_theme_migrator.run).to eq expected_theme_hash
#         end
#       end
#     end

#     context 'when the color theme hash version is not most recent version' do
#     end
#   end
# end
