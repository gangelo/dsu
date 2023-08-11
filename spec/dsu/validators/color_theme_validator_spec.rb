# frozen_string_literal: true

RSpec.describe Dsu::Validators::ColorThemeValidator do
  subject(:color_theme_validator) do
    Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash)
  end

  shared_examples 'the extra key/value pairs are ignored' do
    it 'passes validation' do
      expect(subject.valid?).to be true
    end
  end

  let(:theme_name) { 'test' }
  let(:theme_hash) { Dsu::Models::ColorTheme::DEFAULT_THEME.dup }

  context 'when the color theme colors are valid' do
    it_behaves_like 'the validation passes'
  end

  context 'when a color theme color Hash is empty' do
    before do
      allow(color_theme_validator).to receive(:date).and_return({}) # rubocop:disable RSpec/SubjectStub
    end

    let(:expected_errors) do
      [
        /:date colors Hash is empty/
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when a color theme color Hash value is not a Symbol' do
    before do
      allow(color_theme_validator).to receive(:date) # rubocop:disable RSpec/SubjectStub
        .and_return({ color: :default, mode: :default, background: 'bad' })
    end

    let(:expected_errors) do
      [
        ":background key value 'bad' in theme color Hash {:color=>:default, :mode=>:default, :background=>\"bad\"} " \
        'is not a valid color. One of :black, :light_black, :red, :light_red, :green, :light_green, :yellow, ' \
        ':light_yellow, :blue, :light_blue, :magenta, :light_magenta, :cyan, :light_cyan, :white, :light_white, ' \
        ":default was expected, but 'bad' was received."
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when a color theme color Hash is not a Hash' do
    before do
      allow(color_theme_validator).to receive(:date).and_return(:foo) # rubocop:disable RSpec/SubjectStub
    end

    let(:expected_errors) do
      [
        /:date value is the wrong object type. "Hash" was expected, but "Symbol" was received./
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

  context 'when the color theme color values are an empty Hash' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:error] = {}
      end
    end

    it_behaves_like 'the validation passes'
  end

  context 'when the color theme value color is invalid' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:info] = { color: :foo, mode: :bold }
      end
    end
    let(:expected_errors) do
      [
        ':color key value :foo in theme color Hash {:color=>:foo, :mode=>:bold, :background=>:default} ' \
        'is not a valid color. One of :black, :light_black, :red, :light_red, ' \
        ':green, :light_green, :yellow, :light_yellow, :blue, :light_blue, :magenta, :light_magenta, ' \
        ':cyan, :light_cyan, :white, :light_white, :default was expected, but :foo was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when the color theme value mode is invalid' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:info] = { color: :red, mode: :foo }
      end
    end
    let(:expected_errors) do
      [
        ':mode key value :foo in theme color Hash {:color=>:red, :mode=>:foo, :background=>:default} ' \
        'is not a valid mode value. One of :default, :bold, :italic, :underline, :blink, :swap, :hide ' \
        'was expected, but :foo was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end

  context 'when the color theme value background color is invalid' do
    let(:theme_hash) do
      Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |hash|
        hash[:info] = { color: :red, mode: :bold, background: :foo }
      end
    end
    let(:expected_errors) do
      [
        ':background key value :foo in theme color Hash {:color=>:red, :mode=>:bold, :background=>:foo} ' \
        'is not a valid color. One of :black, :light_black, :red, :light_red, ' \
        ':green, :light_green, :yellow, :light_yellow, :blue, :light_blue, :magenta, :light_magenta, ' \
        ':cyan, :light_cyan, :white, :light_white, :default was expected, but :foo was received.'
      ]
    end

    it_behaves_like 'the validation fails'
  end
end
