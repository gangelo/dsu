# frozen_string_literal: true

# See spec/dsu/services/entry_group_editor_service_spec.rb for an
# example of how to use this shared context.
RSpec.shared_context 'with tmp' do
  before do
    allow(Tempfile).to receive(:new).with('dsu').and_return(tmp_file)
  end

  let(:tmp_file) { Tempfile.new('dsu', tmp_folder) }
  let(:tmp_folder) { Gem::Specification.find_by_name('dsu').gem_dir + "/spec/#{tmp_folder_name}" }
  let(:tmp_folder_name) { '.tmp' }
end
