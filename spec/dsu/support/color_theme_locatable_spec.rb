# frozen_string_literal: true

RSpec.describe Dsu::Support::ColorThemeLocatable do
  subject(:color_theme_locatable) do
    Class.new do
      include Dsu::Support::ColorThemeLocatable
    end.new
  end

  after do
    color_theme_locatable.delete_theme_file!(theme_name: theme_name) unless theme_name.nil?
  end

  let(:theme_name) { 'foo' }
  let(:theme_hash) { Dsu::Models::ColorTheme::DEFAULT_THEME }

  describe '#theme_file?' do
    context 'when the theme file does not exist' do
      it 'returns false' do
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be false
      end
    end

    context 'when the theme file exists' do
      before do
        color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'returns true' do
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be true
      end
    end
  end

  describe '#theme_file' do
    it 'returns the correct theme file path' do
      themes_folder = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS['themes_folder']
      expected_theme_file = File.join(themes_folder, theme_name)
      expect(color_theme_locatable.theme_file(theme_name: theme_name)).to eq expected_theme_file
    end
  end

  describe '#theme_folder' do
    it 'returns the correct themes folder' do
      expected_themes_folder = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS['themes_folder']
      expect(color_theme_locatable.themes_folder).to eq expected_themes_folder
    end
  end

  describe '#create_theme_file!' do
    context 'when the theme folder exists' do
      before do
        color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'creates the theme file' do
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be true
      end

      # TODO: Test this once the color theme reader service is created.
      it 'creates the theme file with the correct content'
    end

    context 'when the theme folder does not exist' do
      before do
        allow(Dir).to receive(:exist?).and_return(false)
      end

      it 'displays an error to the console' do
        expected_output = /Destination folder for theme file \(.+\) does not exist/
        expect do
          color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
        end.to output(expected_output).to_stdout
      end
    end

    context 'when the theme file already exists' do
      before do
        color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'displays an error to the console' do
        expected_output = /Theme file \(.+\) already exists/
        expect do
          color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
        end.to output(expected_output).to_stdout
      end
    end
  end

  describe '#delete_theme_file!' do
    context 'when the theme file already exists' do
      before do
        color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'creates the theme file before deleting it' do
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be true
      end

      it 'deletes the theme file' do
        color_theme_locatable.delete_theme_file!(theme_name: theme_name)
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be false
      end
    end

    context 'when the theme file does not exist' do
      it 'displays an error to the console' do
        expected_output = /Theme file \(.+\) does not exist/
        expect do
          color_theme_locatable.delete_theme_file!(theme_name: theme_name)
        end.to output(expected_output).to_stdout
      end
    end
  end

  describe '#print_theme_file' do
    context 'when the theme file does not exist' do
      it 'ensures the theme file does not exist before the test' do
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be false
      end

      it "prints the 'does not exist' message" do
        expected_output = /Theme file \(.+\) does not exist/
        expect { color_theme_locatable.print_theme_file(theme_name: theme_name) }.to output(expected_output).to_stdout
      end
    end

    context 'when the theme file exists' do
      before do
        color_theme_locatable.create_theme_file!(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'ensures the theme file exists before the test' do
        expect(color_theme_locatable.theme_file?(theme_name: theme_name)).to be true
      end

      it 'prints the theme file content' do
        expected_output = /Theme file \(.+\) contents/
        expect { color_theme_locatable.print_theme_file(theme_name: theme_name) }.to output(expected_output).to_stdout
      end
    end
  end
end
