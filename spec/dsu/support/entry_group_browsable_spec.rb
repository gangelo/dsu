# frozen_string_literal: true

RSpec.describe Dsu::Support::EntryGroupBrowsable do
  subject(:entry_group_browsable) do
    Class.new do
      include Dsu::Support::EntryGroupBrowsable

      def configuration
        @configuration ||= FactoryBot.build(:configuration) # rubocop:disable FactoryBot/SyntaxMethods
      end
    end.new.browse_entry_groups(time: time, options: options)
  end

  let(:time) { Time.now }
  let(:options) { { browse: :xyz, include_all: true, pager: false } }

  describe '#browse_entry_groups' do
    context 'when the :time argument is invalid' do
      let(:time) { :bad }
      let(:expected_error) { /time must be a Time object/ }

      it_behaves_like 'an error is raised'
    end

    context 'when the :options argument is invalid' do
      let(:options) { :bad }
      let(:expected_error) { /options must be a Hash/ }

      it_behaves_like 'an error is raised'
    end

    context 'when the :browse command is not valid' do
      let(:expected_error) { /Unhandled option; expected :week, :month, or :year but received xyz/ }

      it_behaves_like 'an error is raised'
    end
  end
end
