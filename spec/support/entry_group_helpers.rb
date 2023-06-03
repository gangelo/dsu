# frozen_string_literal: true

# These helpers are used to create and delete the entry group data
# file as needed for tests.
module EntryGroupHelpers
  def entry_group_file_matches?(time:, entry_group_hash:)
    time = localtime_for(time)
    return false unless Dsu::Models::EntryGroup.exist?(time: time)

    Dsu::Models::EntryGroup.find(time: time).to_h == entry_group_hash
  end

  def entry_group_file_entries_matches?(time:, entry_group_entries_hash:)
    time = localtime_for(time)
    return false unless Dsu::Models::EntryGroup.exist?(time: time)

    Dsu::Models::EntryGroup.find(time: time).to_h[:entries] == entry_group_entries_hash
  end

  def localtime_for(time)
    return time.localtime if time.utc?

    time
  end
end
