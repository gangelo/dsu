# frozen_string_literal: true

shared_examples 'the version is a valid version' do
  it 'defines a valid version' do
    expect(described_class::VERSION).to be_a(Integer)
  end
end
