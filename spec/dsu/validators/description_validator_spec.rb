# frozen_string_literal: true

RSpec.describe Dsu::Validators::DescriptionValidator do
  subject(:description_validator) do
    Class.new do
      include ActiveModel::Model

      class << self
        def name
          'Test'
        end
      end

      attr_reader :description

      def initialize(description:)
        @description = description
      end

      validates_with Dsu::Validators::DescriptionValidator
    end.new(description: description)
  end

  context 'when description is blank' do
    let(:description) { nil }
    let(:expected_errors) { [/can't be blank/] }

    it_behaves_like 'the validation fails'
  end

  context 'when description is not a string' do
    let(:description) { 1 }
    let(:expected_errors) { [/is the wrong object type/] }

    it_behaves_like 'the validation fails'
  end
end
