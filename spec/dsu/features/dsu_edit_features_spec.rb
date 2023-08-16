# frozen_string_literal: true

RSpec.describe 'Dsu edit features', type: :feature do
  subject(:cli) { Dsu::CLI.start(args) }

  shared_examples 'the entry group for the entry date is edited' do
    before do
      with_entries
      mock_editor(entry_group: entry_group)
    end

    let(:entry_group) { Dsu::Models::EntryGroup.find(time: entry_date) }
    let(:expected_output) do
      Dsu::Views::EntryGroup::Edit.new(entry_group: entry_group).render
    end

    it 'edits entry group for the date' do
      expect { cli }.to output(expected_output).to_stdout
    end
  end

  let(:with_entries) do
    Dir.glob(File.join('spec/fixtures/files/entries', '*')).each do |file_path|
      file_name = File.basename(file_path)
      destination_path = File.join(Dsu::Support::Fileable.entries_folder, file_name)
      FileUtils.cp(file_path, destination_path)
    end
  end

  context "when 'dsu help edit' is called" do
    let(:args) { %w[help edit] }

    it 'displays help' do
      expect { cli }.to output(/Commands:.*rspec edit/m).to_stdout
    end
  end

  context "when 'dsu edit date DATE' is called" do
    let(:args) { ['edit', 'date', Dsu::Support::TimeFormatable.yyyy_mm_dd(time: entry_date)] }
    let(:entry_date) { Time.parse('2023-06-16') }

    it_behaves_like 'the entry group for the entry date is edited'
  end

  context "when 'dsu edit --today' is called" do
    let(:args) { ['edit', '--today', Dsu::Support::TimeFormatable.yyyy_mm_dd(time: entry_date)] }
    let(:entry_date) { Time.parse('2023-06-16') }

    it_behaves_like 'the entry group for the entry date is edited'
  end

  context "when 'dsu edit --tomorrow' is called" do
    let(:args) { ['edit', '--tomorrow', Dsu::Support::TimeFormatable.yyyy_mm_dd(time: entry_date)] }
    let(:entry_date) { Time.parse('2023-06-17') }

    it_behaves_like 'the entry group for the entry date is edited'
  end

  context "when 'dsu edit --yesterday' is called" do
    let(:args) { ['edit', '--yesterday', Dsu::Support::TimeFormatable.yyyy_mm_dd(time: entry_date)] }
    let(:entry_date) { Time.parse('2023-06-15') }

    it_behaves_like 'the entry group for the entry date is edited'
  end
end

def mock_editor(entry_group:)
  allow(Dsu::Services::EntryGroup::EditorService).to \
    receive(:call).with(entry_group: entry_group)
  allow(Dsu::Services::StdoutRedirectorService).to \
    receive(:call).and_return(Dsu::Views::EntryGroup::Edit.new(entry_group: entry_group).render_as_string)
  editor = Dsu::Models::Configuration::DEFAULT_CONFIGURATION[:editor]
  allow(Kernel).to receive(:system).with("${EDITOR:-#{editor}} #{temp_file.path}").and_return(true)
end
