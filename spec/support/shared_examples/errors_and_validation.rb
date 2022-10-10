# frozen_string_literal: true

shared_examples 'an error is raised' do
  it 'raises an error' do
    expect { subject }.to raise_error(expected_error)
  end
end

shared_examples 'no error is raised' do
  it 'does not raise an error' do
    expect { subject }.not_to raise_error
  end
end

shared_examples 'the validation fails' do
  it 'fails validation' do
    expect(subject.errors.full_messages).to match_array expected_errors
  end
end

shared_examples 'the validation passes' do
  it 'passes validation' do
    expect(subject.valid?).to be true
  end
end
