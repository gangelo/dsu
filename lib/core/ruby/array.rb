# frozen_string_literal: true

# This is a monkey patch to the Ruby Array class that adds a method to
# that deletes only 1 instance of an item in the array. If the
# item is not in the array or the item is in the array only once,
# nothing happens. If the item is in the array more than once, only
# one instance of the item is deleted.
class Array
  def delete_one!(item)
    return unless include?(item)
    return if count(item) == 1

    index = index(item)
    deleted_item = self[index]
    self[index] = nil
    compact!
    deleted_item
  end
end
