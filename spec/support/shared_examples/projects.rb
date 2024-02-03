# frozen_string_literal: true

shared_examples 'the project does not exist' do
  it 'returns true' do
    expect(!project.exist?).to be true
  end
end

shared_examples 'the project exists' do
  it 'returns true' do
    expect(project.exist?).to be true
  end
end
