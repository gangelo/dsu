# frozen_string_literal: true

require 'active_support/core_ext/date/calculations'

RSpec.describe NotToday do
  subject(:time) { Time.now }

  describe '#not_today?' do
    context 'when the date is today' do
      it 'returns false' do
        expect(time.not_today?).to be false
      end
    end

    context 'when the date is not today' do
      context 'when in the past' do
        it 'returns true' do
          expect(time.yesterday.not_today?).to be true
        end
      end

      context 'when in the future' do
        it 'returns true' do
          expect(time.tomorrow.not_today?).to be true
        end
      end
    end
  end
end
