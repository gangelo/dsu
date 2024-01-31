# frozen_string_literal: true

shared_examples 'the import file does not exist' do
  context 'when the import file does not exist' do
    let(:import_file_path) { 'spec/fixtures/files/does-not-exist.csv' }

    it "displays the 'import file does not exist' message" do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        import_view.render
      end.chomp)).to include('Import file spec/fixtures/files/does-not-exist.csv does not exist.')
    end
  end
end

shared_examples 'there is nothing to import' do
  context 'when there is nothing to import' do
    let(:import_file_path) { 'spec/fixtures/files/nothing-to-import.csv' }

    it "displays the 'nothing to import' message" do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        import_view.render
      end.chomp)).to include('No entry groups to import.')
    end
  end
end

shared_examples 'there is something to import' do
  context 'when the user responds with "Y"' do
    before do
      stub_import_prompt(response: 'Y')
    end

    let(:expected_output) do
      <<~OUTPUT
        Entry group for 2023-12-31 imported successfully.
        Entry group for 2024-01-01 imported successfully.
        Entry group for 2024-01-02 imported successfully.
      OUTPUT
    end

    context 'when all imports are successful' do
      it "displays the 'imported successfully' message" do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          import_view.render
        end.chomp)).to include(expected_output.chomp)
      end
    end
  end

  context 'when the user responds with "n"' do
    before do
      stub_import_prompt(response: 'n')
    end

    it "displays the 'nothing to import' message" do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        import_view.render
      end.chomp)).to include('Cancelled.')
    end
  end
end

shared_examples 'the import raises an error' do
  before do
    stub_import_prompt(response: 'Y')
  end

  let(:import_file_path) { 'spec/fixtures/files/import-with-errors.csv' }
  let(:expected_output) { /The entry groups failed to import/ }

  it "displays the 'imported successfully' message" do
    expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
      import_view.render
    end.chomp)).to match(expected_output)
  end
end

shared_examples 'the import has errors' do
  before do
    stub_import_prompt(response: 'Y')
  end

  let(:options) { { merge: false } }
  let(:expected_output) do
    <<~OUTPUT
      Entry group for 2023-12-31 imported with an error: Entries array contains duplicate entry: "Entry 2023-12-31...".
      Entry group for 2024-01-01 imported successfully.
      Entry group for 2024-01-02 imported successfully.
    OUTPUT
  end

  let(:import_file_path) { 'spec/fixtures/files/import-with-duplicate-errors.csv' }

  it "displays the 'imported successfully' message" do
    expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
      import_view.render
    end.chomp)).to include(expected_output.chomp)
  end
end
