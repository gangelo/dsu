# frozen_string_literal: true

RSpec.describe 'Dsu add features', type: :feature do
  subject(:cli) do
    strip_escapes(Dsu::Services::StdoutRedirectorService.call { Dsu::CLI.start(args) })
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

  context "when 'dsu add --date=DATE' is called" do
    before do
      with_entries
    end

    let(:args) { ['add', '--date', entry_date, entry_description] }
    let(:entry_date) { '2023-06-16' }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.parse(entry_date))
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
end
