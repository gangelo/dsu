# frozen_string_literal: true

module Dsu
  module Presenters
    module Import
      module ImportFile
        def import_file_path_exist?
          File.exist? import_file_path
        end

        def nothing_to_import?
          return true unless import_file_path_exist?

          import_entry_groups.count.zero?
        end

        def import_entry_groups
          # Should return a Hash of entry group entries
          # Example: { '2023-12-32' => ['Entry description 1', 'Entry description 2', ...] }
          raise NotImplementedError
        end

        def import_entry_groups_count
          if overriding_project?
            import_entry_groups&.first&.count || 0
          else
            import_entry_groups[project_name]&.count || 0
          end
        end
      end
    end
  end
end
