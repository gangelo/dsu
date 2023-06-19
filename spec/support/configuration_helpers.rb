# frozen_string_literal: true

# rubocop:disable Style/StringHashKeys, Style/NumericLiterals
module ConfigurationHelpers
  # Store configuration hashes per migration version so
  # that we can use these in migration testing.
  CONFIGURATION_HASHES =
    {
      '0' => {
        editor: 'vim',
        entries_display_order: 'asc',
        entries_file_name: '%Y-%m-%d.json',
        entries_folder: '/Users/gangelo/dsu/entries',
        carry_over_entries_to_today: true,
        include_all: true
      },
      '20230613121411' => {
        version: 20230613121411,
        editor: 'nano',
        entries_display_order: :desc,
        carry_over_entries_to_today: false,
        include_all: false,
        theme_name: 'matrix'
      },
      '20230618204155' => {
        version: 20230618204155,
        editor: 'nano',
        entries_display_order: :desc,
        carry_over_entries_to_today: false,
        include_all: false,
        theme_name: 'matrix'
      }
    }
end
# rubocop:enable Style/StringHashKeys, Style/NumericLiterals
