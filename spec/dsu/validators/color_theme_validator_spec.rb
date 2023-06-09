# frozen_string_literal: true

RSpec.shared_examples 'the extra key/value pairs are ignored' do
  it 'passes validation' do
    expect(subject.valid?).to be true
  end
end

RSpec.describe Dsu::Validators::ColorThemeValidator do
  subject(:color_theme_validator) do
    Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash)
  end

  let(:theme_name) { 'test' }
  let(:theme_hash) { Dsu::Models::ColorTheme::DEFAULT_THEME.dup }

  context 'when the color theme colors are valid' do
    it_behaves_like 'the validation passes'
  end

  context 'when there are color theme color values that are nil' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:entry_group_highlight] = nil
      end
    end
    let(:expected_errors) do
      [
        ':entry_group_highlight is the wrong object type. "Array" was expected, but "NilClass" was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when there are extra color theme key/value pairs' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:extra] = 'extra'
      end
    end

    it_behaves_like 'the extra key/value pairs are ignored'
  end

  context 'when the color theme color values are the wrong object type' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:status_info] = :foo
      end
    end
    let(:expected_errors) do
      [
        ':status_info is the wrong object type. "Array" was expected, but "Symbol" was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when the color theme color values are an empty Array' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:status_error] = []
      end
    end
    let(:expected_errors) do
      [
        ':status_error colors Array is empty'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when the color theme value color is invalid' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:status_info] = [:foo]
      end
    end
    let(:expected_errors) do
      [
        'color value (status_info: value[0]) is not a valid color. One of :black, :light_black, :red, :light_red, ' \
        ':green, :light_green, :yellow, :light_yellow, :blue, :light_blue, :magenta, :light_magenta, :cyan, :light_cyan, ' \
        ':white, :light_white, :default was expected, but :foo was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when the color theme value mode is invalid' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:status_info] = %i[red foo]
      end
    end
    let(:expected_errors) do
      [
        'mode value (status_info: value[1]) is not a valid mode. One of :default, :bold, :italic, ' \
        ':underline, :blink, :swap, :hide was expected, but :foo was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when the color theme value background color is invalid' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:status_info] = %i[red bold foo]
      end
    end
    let(:expected_errors) do
      [
        'background color value (status_info: value[2]) is not a valid color. One of :black, :light_black, :red, :light_red, ' \
        ':green, :light_green, :yellow, :light_yellow, :blue, :light_blue, :magenta, :light_magenta, :cyan, :light_cyan, ' \
        ':white, :light_white, :default was expected, but :foo was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

end
