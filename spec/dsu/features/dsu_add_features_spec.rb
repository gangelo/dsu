# frozen_string_literal: true

RSpec.describe 'Dsu add features', type: :feature do
  subject(:cli) do
    capture_stdout_and_strip_escapes { Dsu::CLI.start(args) }
  end

  let(:args) { %w[add] }
  let(:with_entries) do
    Dir.glob(File.join('spec/fixtures/files/entries', '*')).each do |file_path|
      file_name = File.basename(file_path)
      destination_path = File.join(Dsu::Support::Fileable.entries_folder, file_name)
      FileUtils.cp(file_path, destination_path)
    end
  end

  context "when 'dsu help add' is called" do
    let(:args) { %w[help add] }

    it 'displays help' do
      expect(cli).to include('add|a [OPTIONS] DESCRIPTION')
    end
  end

  context "when 'dsu add DESCRIPTION' is called" do
    before do
      freeze_time_at(time_string: '2023-06-16')
    end

    let(:args) { ['add', entry_description] }
    let(:entry_date) { Time.now }
    let(:entry_description) { 'Added description' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: entry_date)
    end

    it 'displays the entry group date' do
      expect(cli).to include(expected_date)
    end

    it 'displays the description that was added' do
      expect(cli).to include(entry_description)
    end
  end

  context "when 'dsu add --tomorrow' is called" do
    before do
      with_entries

      freeze_time_at(time_string: '2023-06-16')
    end

    let(:args) { ['add', '--tomorrow', entry_description] }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.now.tomorrow)
    end

    it 'displays the entry group date' do
      expect(cli).to include(expected_date)
    end

    it 'displays the entries already existing in the group' do
      expected_entry_descriptions = ['20230617 description 0', '20230617 description 1']
      expected_entry_descriptions.each do |entry_description|
        expect(cli).to include(entry_description)
      end
    end

    it 'displays the description that was added' do
      expect(cli).to include(entry_description)
    end
  end

  context "when 'dsu add --yesterday' is called" do
    before do
      with_entries

      freeze_time_at(time_string: '2023-06-16')
    end

    let(:args) { ['add', '--yesterday', entry_description] }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.now.yesterday)
    end

    it 'displays the entry group date' do
      expect(cli).to include(expected_date)
    end

    it 'displays the entries already existing in the group' do
      expected_entry_descriptions = ['20230615 description 0', '20230615 description 1']
      expected_entry_descriptions.each do |entry_description|
        expect(cli).to include(entry_description)
      end
    end

    it 'displays the description that was added' do
      expect(cli).to include(entry_description)
    end
  end

  context "when 'dsu add --today' is called" do
    before do
      with_entries

      freeze_time_at(time_string: '2023-06-16')
    end

    let(:args) { ['add', '--today', entry_description] }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.now)
    end

    it 'displays the entry group date' do
      expect(cli).to include(expected_date)
    end

    it 'displays the entries already existing in the group' do
      expected_entry_descriptions = ['20230616 description 0', '20230616 description 1']
      expected_entry_descriptions.each do |entry_description|
        expect(cli).to include(entry_description)
      end
    end

    it 'displays the description that was added' do
      expect(cli).to include(entry_description)
    end
  end

  context "when 'dsu add --date=DATE' is called" do
    before do
      with_entries
    end

    shared_examples 'the expected output is displayed' do
      it 'displays the expected output' do
        expect(cli.split("\n")[0..4].map(&:squish).reject(&:blank?)).to eq(expected_output.split("\n"))
      end
    end

    let(:expected_output) do
      <<~OUTPUT
        #{expected_date}
        1. #{entry_date.tr('-', '')} description 0
        2. #{entry_date.tr('-', '')} description 1
        3. #{entry_description}
      OUTPUT
    end

    context 'when using option --date' do
      let(:args) { ['add', '--date', entry_date, entry_description] }
      let(:entry_date) { '2023-06-16' }
      let(:entry_description) { 'This is a test' }
      let(:expected_date) do
        Dsu::Support::TimeFormatable.formatted_time(time: Time.parse(entry_date))
      end

      it_behaves_like 'the expected output is displayed'
    end

    context 'when using --date with a positive relative date mnemonic' do
      before do
        freeze_time_at(time_string: '2023-06-16')
      end

      let(:args) { ['add', '--date', '+1', entry_description] }
      let(:entry_date) { '2023-06-17' }
      let(:entry_description) { 'This is a test' }
      let(:expected_date) do
        Dsu::Support::TimeFormatable.formatted_time(time: Time.parse(entry_date))
      end

      it_behaves_like 'the expected output is displayed'
    end

    context 'when using --date with a negative relative date mnemonic' do
      before do
        freeze_time_at(time_string: '2023-06-16')
      end

      let(:args) { ['add', '--date', '-1', entry_description] }
      let(:entry_date) { '2023-06-15' }
      let(:entry_description) { 'This is a test' }
      let(:expected_date) do
        Dsu::Support::TimeFormatable.formatted_time(time: Time.parse(entry_date))
      end

      it_behaves_like 'the expected output is displayed'
    end

    context 'when an error is raised' do
      subject(:cli) do
        capture_stderr_and_strip_escapes { Dsu::CLI.start(args) }
      end

      before do
        allow(Dsu::Models::Entry).to receive(:new).and_raise(ArgumentError, 'Boom!')
      end

      let(:args) { ['add', '--date', '2023-06-15', 'This is a test'] }

      it 'displays the error message' do
        expect(cli).to include('Boom!')
      end
    end
  end
end
