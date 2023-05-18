# frozen_string_literal: true

# These helpers are used to create and delete the entry group data
# file as needed for tests.
module EntryGroupHelpers
  def create_entry_group_file!(entry_group:)
    Dsu::Services::EntryGroupWriterService.new(entry_group: entry_group).call
  end

  def delete_entry_group_file!(time:)
    time = localtime_for(time)
    return unless entry_group_file_exists?(time: time)

    Dsu::Services::EntryGroupDeleterService.new(time: time).call
  end

  def entry_group_file_exists?(time:)
    time = localtime_for(time)
    Dsu::Services::EntryGroupReaderService.entry_group_file_exists?(time: time)
  end

  def entry_group_file_matches?(time:, entry_group_hash:)
    time = localtime_for(time)
    return false unless entry_group_file_exists?(time: time)

    Dsu::Models::EntryGroup.load(time: time).to_h == entry_group_hash
  end

  def entry_group_file_entries_matches?(time:, entry_group_entries_hash:)
    time = localtime_for(time)
    return false unless entry_group_file_exists?(time: time)

    Dsu::Models::EntryGroup.load(time: time).to_h[:entries] == entry_group_entries_hash
  end

  def localtime_for(time)
    return time.localtime if time.utc?

    time
  end
end
