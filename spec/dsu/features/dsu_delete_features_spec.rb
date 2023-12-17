# frozen_string_literal: true

RSpec.describe 'Dsu delete features', type: :feature do
  subject(:cli) { Dsu::CLI.start(args) }

  shared_examples 'the entry groups are deleted' do |deleted_count|
    let(:expected_output) do
      Dsu::Services::StdoutRedirectorService.call do
        message = I18n.t('subcommands.delete.messages.deleted', count: deleted_count)
        Dsu::Views::Shared::Success.new(messages: message).render
      end
    end

    it 'displays the entry groups that were deleted' do
      escaped_expected_output = Regexp.escape(expected_output)

      expect { cli }.to output(/.*#{escaped_expected_output}.*/m).to_stdout
    end
  end

  shared_examples 'an error is displayed to stderr' do
    it 'displays the error' do
      escaped_expected_output = Regexp.escape(expected_output)

      expect { cli }.to output(/.*#{escaped_expected_output}.*/m).to_stderr
    end
  end

  before do
    [-3, -2, -1, 0, 1, 2, 3].each do |index|
      time = Time.now.localtime + index.days
      create(:entry_group, :with_entries, time: time)
    end
  end

  let(:options) { {} }
  let(:configuration) do
    build(:configuration)
  end

  context "when 'dsu help delete' is used" do
    let(:args) { %w[help delete] }

    it 'displays help' do
      expect { cli }.to output(/Commands:.*rspec delete/m).to_stdout
    end
  end

  context "when 'dsu delete date DATE|MNEUMONIC' is used" do
    context 'with no DATE | MNEUMONIC argument' do
      let(:args) { %w[delete date] }
      let(:expected_output) do
        'ERROR: "rspec delete date" was called with no arguments'
      end

      it_behaves_like 'an error is displayed to stderr'
    end

    context 'with a date' do
      let(:args) do
        [
          'delete',
          'date',
          Dsu::Support::TimeFormatable.yyyy_mm_dd(time: time, separator: '/'),
          '--prompts', 'any:true'
        ]
      end
      let(:time) { Time.now.localtime }
      let(:times) do
        [time, time.yesterday]
      end

      it_behaves_like 'the entry groups are deleted', 1
    end

    context 'with a mneumonic' do
      context "with '+n'" do
        let(:args) do
          [
            'delete',
            'date',
            '+1',
            '--prompts', 'any:true'
          ]
        end
        # + 1.day to reflect our +1 mneumonic
        let(:time) { Time.now + 1.day }
        let(:times) { [time, time.yesterday] }

        it_behaves_like 'the entry groups are deleted', 1
      end

      context "with '-n'" do
        let(:args) do
          [
            'delete',
            'date',
            '-1',
            '--prompts', 'any:true'
          ]
        end
        # - 1.day to reflect our -1 mneumonic
        let(:time) { Time.now - 1.day }
        let(:times) { [time.yesterday, time] }

        it_behaves_like 'the entry groups are deleted', 1
      end

      context "with 'today'" do
        let(:args) do
          [
            'delete',
            'date',
            'today',
            '--prompts', 'any:true'
          ]
        end
        let(:times) { [Time.now.yesterday, Time.now] }

        it_behaves_like 'the entry groups are deleted', 1
      end

      context "with 'tomorrow'" do
        let(:args) do
          [
            'delete',
            'date',
            'tomorrow',
            '--prompts', 'any:true'
          ]
        end
        let(:times) { [Time.now, Time.now.tomorrow] }

        it_behaves_like 'the entry groups are deleted', 1
      end

      context "with 'yesterday'" do
        let(:args) do
          [
            'delete',
            'date',
            'yesterday',
            '--prompts', 'any:true'
          ]
        end
        let(:times) { [Time.now.yesterday, Time.now.yesterday.yesterday] }

        it_behaves_like 'the entry groups are deleted', 1
      end
    end
  end

  context "when 'dsu delete dates OPTIONS' is used" do
    context 'with no OPTIONS or OPTION values' do
      let(:args) do
        %w[
          delete
          dates
        ]
      end
      let(:expected_output) do
        "No value provided for required options '--from', '--to'"
      end

      it_behaves_like 'an error is displayed to stderr'
    end

    context 'with no --from or --to OPTION values' do
      let(:args) do
        [
          'delete',
          'dates',
          '--from',
          '--to'
        ]
      end
      let(:expected_output) do
        "No value provided for option '--from'"
      end

      it_behaves_like 'an error is displayed to stderr'
    end

    context 'with invalid FROM_DATE | TO_DATE argument' do
      context 'with invalid FROM_DATE and invalid TO_DATE' do
        let(:args) do
          [
            'delete',
            'dates',
            '--from', 'bad-from-date',
            '--to', 'bad-to-date'
          ]
        end
        let(:expected_output) do
          'Option -f, [--from=DATE|MNEMONIC] value is invalid ["bad-from-date"]'
        end

        it_behaves_like 'an error is displayed to stderr'
      end

      context 'with invalid FROM_DATE' do
        let(:args) do
          [
            'delete',
            'dates',
            '--from', 'bad-date',
            '--to', Dsu::Support::TimeFormatable.mm_dd(time: Time.now)
          ]
        end
        let(:expected_output) do
          'Option -f, [--from=DATE|MNEMONIC] value is invalid ["bad-date"]'
        end

        it_behaves_like 'an error is displayed to stderr'
      end

      context 'with invalid TO_DATE' do
        let(:args) do
          [
            'delete',
            'dates',
            '--from', Dsu::Support::TimeFormatable.mm_dd(time: Time.now),
            '--to', 'bad-date'
          ]
        end
        let(:expected_output) do
          'Option -t, [--to=DATE|MNEMONIC] value is invalid ["bad-date"]'
        end

        it_behaves_like 'an error is displayed to stderr'
      end
    end

    context "when 'dsu delete dates -f FROM_DATE -t TO_DATE' is used" do
      let(:args) do
        [
          'delete',
          'dates',
          '-f', Dsu::Support::TimeFormatable.mm_dd(time: times.min),
          '-t', Dsu::Support::TimeFormatable.mm_dd(time: times.max),
          '--prompts', 'any:true'
        ]
      end
      let(:times) { [Time.now.yesterday, Time.now] }

      it_behaves_like 'the entry groups are deleted', 2
    end

    context "when 'dsu delete dates -f MNEUMONIC -t TO_DATE' is used" do
      let(:args) do
        [
          'delete',
          'dates',
          '-f', 'yesterday',
          '-t', Dsu::Support::TimeFormatable.mm_dd(time: Time.now),
          '--prompts', 'any:true'
        ]
      end
      let(:times) { [Time.now.yesterday, Time.now] }

      it_behaves_like 'the entry groups are deleted', 2
    end

    context "when 'dsu delete dates -f FROM_DATE -t MNEUMONIC' is used" do
      let(:args) do
        [
          'delete',
          'dates',
          '-f', Dsu::Support::TimeFormatable.mm_dd(time: Time.now.yesterday),
          '-t', 'today',
          '--prompts', 'any:true'
        ]
      end
      let(:times) { [Time.now.yesterday, Time.now] }

      it_behaves_like 'the entry groups are deleted', 2
    end

    context "when 'dsu delete dates -f MNEUMONIC -t MNEUMONIC' is used" do
      context "when '-f MNEUMONIC_STRING -t MNEUMONIC_STRING'" do
        let(:args) do
          [
            'delete',
            'dates',
            '-f', 'yesterday',
            '-t', 'today',
            '--prompts', 'any:true'
          ]
        end
        let(:times) { [Time.now.yesterday, Time.now] }

        it_behaves_like 'the entry groups are deleted', 2
      end

      context "when '-f MNEUMONIC_NUM -t MNEUMONIC_STRING'" do
        let(:args) do
          [
            'delete',
            'dates',
            '-f', '-1',
            '-t', 'today',
            '--prompts', 'any:true'
          ]
        end
        let(:times) { [Time.now - 1.day, Time.now] }

        it_behaves_like 'the entry groups are deleted', 2
      end

      context "when '-f MNEUMONIC_STRING -t MNEUMONIC_NUM'" do
        let(:args) do
          [
            'delete',
            'dates',
            '-f', 'yesterday',
            '-t', '+2',
            '--prompts', 'any:true'
          ]
        end
        let(:times) { [Time.now.yesterday, Time.now.yesterday + 2.days] }

        it_behaves_like 'the entry groups are deleted', 3
      end
    end
  end
end
