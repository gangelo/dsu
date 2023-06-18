# frozen_string_literal: true

def color_theme_regex_for(theme_names:, default_theme_name: Dsu::Models::ColorTheme::DEFAULT_THEME_NAME)
  theme_names << default_theme_name unless theme_names.include?(default_theme_name)
  regex_string = theme_names.sort.each_with_index.map do |theme_name, index|
    theme_name = "*#{theme_name}" if theme_name == default_theme_name
    ".*#{index + 1}..*#{theme_name}"
  end.join('.*')
  Regexp.new(regex_string, Regexp::MULTILINE)
end

RSpec.describe Dsu::Subcommands::Theme do
  subject(:cli) { Dsu::CLI.start(args) }

  let(:theme_name) { 'test' }
  let(:color_theme) { Dsu::Models::ColorTheme.default }

  shared_examples 'the color theme exists' do
    it 'creates the color theme' do
      cli
      expect(Dsu::Models::ColorTheme.exist?(theme_name: theme_name)).to be(true)
    end
  end

  shared_examples 'the color theme does not exist' do
    it 'does not create the color theme' do
      cli
      expect(Dsu::Models::ColorTheme.exist?(theme_name: theme_name)).to be(false)
    end
  end

  describe '#create' do
    context 'when the theme does not exist' do
      let(:create_color_theme_prompt) do
        color_theme.prompt_with_options(prompt: "Create color theme \"#{theme_name}\"?", options: %w[y N])
      end

      context 'when the user does not want to create the color theme' do
        let(:args) { ['theme', 'create', theme_name, '--prompts', "#{create_color_theme_prompt}:false"] }

        it 'displays a canceled message to the console' do
          expect { cli }.to output(/Canceled/).to_stdout
        end

        it_behaves_like 'the color theme does not exist'
      end

      context 'when the user wants to create the color theme' do
        let(:args) { ['theme', 'create', theme_name, '--prompts', "#{create_color_theme_prompt}:true"] }

        it 'displays a created message to the console' do
          expect { cli }.to output(/Created color theme "#{theme_name}"/).to_stdout
        end

        it_behaves_like 'the color theme exists'
      end
    end

    context 'when the color theme exists' do
      before do
        Dsu::Models::ColorTheme.find_or_create(theme_name: theme_name)
      end

      let(:args) { ['theme', 'create', theme_name] }

      it 'already exists' do
        expect(Dsu::Models::ColorTheme.exist?(theme_name: theme_name)).to be(true)
      end

      it 'displays an already exists error to the console' do
        expect { cli }.to output(/Color theme "#{theme_name}" already exists/).to_stdout
      end
    end
  end

  describe '#delete' do
    context 'when the color theme is the default theme' do
      let(:theme_name) { Dsu::Models::ColorTheme::DEFAULT_THEME_NAME }
      let(:args) { ['theme', 'delete', theme_name] }

      it 'displays a does not exist error to the console' do
        expect { cli }.to output(/Color theme "#{theme_name}" cannot be deleted/).to_stdout
      end
    end

    context 'when the color theme does not exists' do
      let(:args) { ['theme', 'delete', theme_name] }

      it 'displays a does not exist error to the console' do
        expect { cli }.to output(/Color theme "#{theme_name}" does not exist/).to_stdout
      end
    end

    context 'when the color theme exists' do
      before do
        Dsu::Models::ColorTheme.find_or_create(theme_name: theme_name)
      end

      let(:delete_color_theme_prompt) do
        color_theme.prompt_with_options(prompt: "Delete color theme \"#{theme_name}\"?", options: %w[y N])
      end

      context 'when the user does not want to delete the color theme' do
        let(:args) { ['theme', 'delete', theme_name, '--prompts', "#{delete_color_theme_prompt}:false"] }

        it 'displays a canceled message to the console' do
          expect { cli }.to output(/Canceled/).to_stdout
        end

        it_behaves_like 'the color theme exists'
      end

      context 'when the user wants to delete the color theme' do
        let(:args) { ['theme', 'delete', theme_name, '--prompts', "#{delete_color_theme_prompt}:true"] }

        it 'displays a deleted message to the console' do
          expect { cli }.to output(/Deleted color theme "#{theme_name}"/).to_stdout
        end

        it_behaves_like 'the color theme does not exist'
      end
    end
  end

  describe '#use' do
    context 'when the color theme file exists' do
      before do
        Dsu::Models::ColorTheme.find_or_create(theme_name: theme_name)
      end

      let(:args) { ['theme', 'use', theme_name] }

      it 'displays a using color theme message to the console' do
        expect { cli }.to output(/Using color theme "#{theme_name}"/).to_stdout
      end
    end

    context 'when the color theme file does not exist' do
      let(:create_color_theme_prompt) do
        color_theme.prompt_with_options(prompt: "Create color theme \"#{theme_name}\"?", options: %w[y N])
      end

      context 'when the user does not want to create the color theme' do
        let(:args) { ['theme', 'use', theme_name, '--prompts', "#{create_color_theme_prompt}:false"] }

        it 'displays a canceled message to the console' do
          expect { cli }.to output(/Canceled/).to_stdout
        end

        it_behaves_like 'the color theme does not exist'
      end

      context 'when the user wants to create the color theme' do
        let(:args) { ['theme', 'use', theme_name, '--prompts', "#{create_color_theme_prompt}:true"] }

        it 'displays a created color theme message to the console' do
          expect { cli }.to output(/Created color theme "#{theme_name}"/).to_stdout
        end

        it_behaves_like 'the color theme exists'
      end
    end
  end

  describe '#list' do
    let(:args) { %w[theme list] }

    context 'when there are no color themes' do
      it 'displays the default color theme' do
        expect { cli }.to output(/1\..+\*default.+-.+Default theme/).to_stdout
      end
    end

    context 'when there are color themes' do
      before do
        theme_names.each { |theme_name| create(:color_theme, theme_name: theme_name) }
      end

      let(:theme_names) { [theme_name, 'b_test', 'c_test'] }

      it 'displays the color theme' do
        expect { cli }.to output(color_theme_regex_for(theme_names: theme_names)).to_stdout
      end
    end
  end
end
