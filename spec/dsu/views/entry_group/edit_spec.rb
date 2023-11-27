# frozen_string_literal: true

RSpec.shared_examples 'the editor template shows no previous entries' do
  let(:expected_editor_template) do
    <<~TEMPLATE
      ENTER DSU ENTRIES BELOW
    TEMPLATE
  end

  it 'returns an editor template with no entries' do
    expect(edit_view.render_as_string).to include(expected_editor_template)
  end
end

RSpec.shared_examples "the editor template shows only today's entries" do
  let(:expected_editor_template) do
    <<~TEMPLATE
      ################################################################################
      # Editing DSU Entries for #{entry_group.time_formatted}
      ################################################################################

      ################################################################################
      # DSU ENTRIES
      ################################################################################

      #{entry_group.entries.map(&:description).join("\n").chomp}
    TEMPLATE
  end

  it 'has entries to edit' do
    expect(entry_group.entries.any?).to be true
  end

  it "returns an editor template with today's entries" do
    expect(edit_view.render_as_string).to include(expected_editor_template)
  end
end

RSpec.shared_examples "the editor template shows yesterday's entries" do
  let(:expected_editor_template) do
    <<~TEMPLATE
      ################################################################################
      # Editing DSU Entries for #{entry_group.time_formatted}
      ################################################################################

      ################################################################################
      # PREVIOUS DSU ENTRIES FROM #{yesterdays_entry_group.time_formatted}
      ################################################################################

      #{yesterdays_entry_group.entries.map(&:description).join("\n").chomp}
    TEMPLATE
  end

  it 'has no entries for today to edit' do
    expect(entry_group.entries.any?).to be false
  end

  it 'has entries from yesterday to edit' do
    expect(yesterdays_entry_group.entries.any?).to be true
  end

  it "returns an editor template with yesterday's entries" do
    expect(edit_view.render_as_string).to include(expected_editor_template)
  end
end

RSpec.describe Dsu::Views::EntryGroup::Edit do
  subject(:edit_view) { described_class.new(entry_group: entry_group, options: options) }

  after do
    Dsu::Models::EntryGroup.delete(time: today)
    Dsu::Models::EntryGroup.delete(time: yesterday)
  end

  let(:today) { Time.now }
  let(:yesterday) { Time.now.yesterday }
  let(:entry_group) { build(:entry_group, :with_entries, time: today) }
  let(:options) { {} }

  context 'when there are no entries for today and no previous entries' do
    context 'when carry_over_entries_to_today is false' do
      let(:entry_group) { build(:entry_group, time: today) }
      let(:options) { { 'carry_over_entries_to_today' => false } } # rubocop:disable Style/StringHashKeys

      it_behaves_like 'the editor template shows no previous entries'
    end

    context 'when carry_over_entries_to_today is true' do
      let(:entry_group) { build(:entry_group, time: today) }
      let(:options) { { 'carry_over_entries_to_today' => true } } # rubocop:disable Style/StringHashKeys

      it_behaves_like 'the editor template shows no previous entries'
    end
  end

  context 'when there are entries for today and no previous entries' do
    context 'when carry_over_entries_to_today is false' do
      let(:entry_group) { build(:entry_group, :with_entries, time: today) }
      let(:options) { { 'carry_over_entries_to_today' => false } } # rubocop:disable Style/StringHashKeys

      it_behaves_like "the editor template shows only today's entries"
    end

    context 'when carry_over_entries_to_today is true' do
      let(:entry_group) { build(:entry_group, :with_entries, time: today) }
      let(:options) { { 'carry_over_entries_to_today' => true } } # rubocop:disable Style/StringHashKeys

      it_behaves_like "the editor template shows only today's entries"
    end
  end

  context 'when there are entries for today and previous entries' do
    before do
      create(:entry_group, :with_entries, time: yesterday)
    end

    it 'has entries for yesterday on disk' do
      expect(Dsu::Models::EntryGroup.exist?(time: yesterday)).to be true
    end

    context 'when carry_over_entries_to_today is false' do
      let(:entry_group) { build(:entry_group, :with_entries, time: today) }
      let(:options) { { 'carry_over_entries_to_today' => false } } # rubocop:disable Style/StringHashKeys

      it_behaves_like "the editor template shows only today's entries"
    end

    context 'when carry_over_entries_to_today is true' do
      let(:entry_group) { build(:entry_group, :with_entries, time: today) }
      let(:options) { { 'carry_over_entries_to_today' => true } } # rubocop:disable Style/StringHashKeys

      it_behaves_like "the editor template shows only today's entries"
    end
  end

  context 'when there are no entries for today and previous entries' do
    before do
      entry_group
      yesterdays_entry_group
    end

    let(:entry_group) { build(:entry_group, time: today) }
    let(:yesterdays_entry_group) { create(:entry_group, :with_entries, time: yesterday) }

    it 'has no entries for today' do
      expect(entry_group.entries.any?).to be false
    end

    it 'has entries for yesterday on disk' do
      expect(Dsu::Models::EntryGroup.exist?(time: yesterday)).to be true
    end

    context 'when carry_over_entries_to_today is false' do
      let(:options) { { 'carry_over_entries_to_today' => false } } # rubocop:disable Style/StringHashKeys

      it_behaves_like 'the editor template shows no previous entries'
    end

    context 'when carry_over_entries_to_today is true' do
      let(:options) { { 'carry_over_entries_to_today' => true } } # rubocop:disable Style/StringHashKeys

      it_behaves_like "the editor template shows yesterday's entries"
    end
  end
end
