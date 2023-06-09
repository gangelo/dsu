# frozen_string_literal: true

shared_examples 'the version is a valid version string' do
  it 'defines a valid version' do
    expect(described_class::VERSION).to match Dsu::VERSION_REGEX
  end
end
