# These helpers are used to create and delete the entry group data
# file as needed for tests.
module EntryGroupHelpers
  def create_entry_group_file!
  end

  def delete_entry_group_file!
  end

  def entry_group_file_exists?(time:)
    Dsu::Services::EntryGroupReaderService.entry_group_file_exists?(time: time)
  end

  def entry_group_file_matches?(time:, entry_group_hash:)
    Dsu::Support::EntryGroupLoadable.entry_group_hash_for(time: time) == entry_group_hash
  end
end
