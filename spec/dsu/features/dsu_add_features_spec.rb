# frozen_string_literal: true

RSpec.describe 'Dsu add features', type: :feature do
  subject(:cli) { Dsu::CLI.start(args) }

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
      expect { cli }.to output(/Usage:.*rspec add/m).to_stdout
    end
  end

  context "when 'dsu add DESCRIPTION' is called" do
    let(:args) { ['add', 'Added description'] }
    let(:expected_output) do
      /\(Today\) #{today_yyyymmdd_string}.*1\..*Added description/m
    end

    it 'displays the description that was added' do
      expect { cli }.to output(expected_output).to_stdout
    end
  end

  context "when 'dsu add --date=DATE' is called" do
    before do
      with_entries
    end

    let(:args) { ['add', '--date', entry_date, entry_description] }
    let(:entry_date) { '2023-06-16' }
    let(:entry_description) { 'This is a test' }
    let(:expected_output) do
      /\b+3\..+#{entry_description}/m
    end

    it 'displays the description that was added' do
      expect { cli }.to output(expected_output).to_stdout
    end
  end

  context "when 'dsu add --tomorrow' is called" do
    before do
      with_entries

      allow(Time).to receive(:now).and_return(Time.parse('2023-06-16'))
    end

    let(:args) { ['add', '--tomorrow', entry_description] }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.now.tomorrow)
    end
    let(:expected_output) do
      /.+#{expected_date}.+3\..+#{entry_description}/m
    end

    it 'displays the description that was added' do
      expect { cli }.to output(expected_output).to_stdout
    end
  end

  context "when 'dsu add --yesterday' is called" do
    before do
      with_entries

      allow(Time).to receive(:now).and_return(Time.parse('2023-06-16'))
    end

    let(:args) { ['add', '--yesterday', entry_description] }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.now.yesterday)
    end
    let(:expected_output) do
      /.+#{expected_date}.+3\..+#{entry_description}/m
    end

    it 'displays the description that was added' do
      expect { cli }.to output(expected_output).to_stdout
    end
  end

  context "when 'dsu add --today' is called" do
    before do
      with_entries

      allow(Time).to receive(:now).and_return(Time.parse('2023-06-16'))
    end

    let(:args) { ['add', '--today', entry_description] }
    let(:entry_description) { 'This is a test' }
    let(:expected_date) do
      Dsu::Support::TimeFormatable.formatted_time(time: Time.now)
    end
    let(:expected_output) do
      /.+#{expected_date}.+3\..+#{entry_description}/m
    end

    it 'displays the description that was added' do
      expect { cli }.to output(expected_output).to_stdout
    end
  end
end
