# frozen_string_literal: true

RSpec.describe Dsu::Validators::VersionValidator do
  subject(:version_validator) do
    Class.new do
      include ActiveModel::Model

      attr_reader :version

      class << self
        def name
          'Test'
        end
      end

      def initialize(version:)
        @version = version
      end

      validates_with Dsu::Validators::VersionValidator
    end.new(version: version)
  end

  before do
    version_validator.class.const_set(:VERSION, Dsu::VERSION)
  end

  context 'when version is nil' do
    let(:version) { nil }
    let(:expected_errors) do
      [
        'Version is nil'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when version is not in Integer' do
    let(:version) { '1' }
    let(:expected_errors) { [/is the wrong object type/] }

    it_behaves_like 'the validation fails'
  end
end
