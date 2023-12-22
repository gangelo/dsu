# frozen_string_literal: true

RSpec.describe 'Dsu browse features', type: :feature do
  subject(:cli) { Dsu::CLI.start(args) }

  let(:options) { {} }
  let(:configuration) do
    build(:configuration)
  end

  context "when 'dsu help browse' is used" do
    let(:args) { %w[help browse] }

    it 'displays help' do
      expect { cli }.to output(/Commands:.*rspec browse/m).to_stdout
    end
  end

  context "when 'dsu browse COMMAND' is used" do
    context 'with no COMMAND argument' do
      let(:args) { %w[browse] }
      let(:expected_output) do
        'ERROR: "rspec browse" was called with no arguments'
      end

      it 'an error is displayed to stderr'
    end

    context 'with a mnemonic' do
      context "with 'week'" do
        let(:args) { %w[browse week] }

        it 'the entry groups for the week are displayed'
      end

      context "with 'month'" do
        let(:args) { %w[browse month] }

        it 'the entry groups for the month are displayed'
      end

      context "with 'year'" do
        let(:args) { %w[browse year] }

        it 'the entry groups for the year are displayed'
      end
    end
  end
end
