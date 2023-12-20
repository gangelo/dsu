## [2.2.0] 2023-??-??

TODO: Change above date to release date.

Enhancements

- Added `dsu browse` command to interactively page through DSU entries.

## [2.1.4] 2023-12-19

Changes

- Minor code refactors.

Bug fixes

- Fix bug in relative date mnemonic (RDMs) regex matcher that incorrectly matched dates whose separater happened to be a "-" (e.g. 2023-12-31). The old regex (/[+-]\d+/) incorrectly interpreted this as an RDM. This bug would cause the `dsu list dates` command (for example) to create erroneous, relative dates.

## [2.1.3] 2023-12-17

Bug fixes

- Fix bug that did not recognize the `include_all` configuration option when using the `dsu list dates` command. The `include_all` configuration option is now recognized and used properly when using the `dsu list dates` command. See `dsu help list dates` for more information.

## [2.1.2] 2023-12-17

Changes

- WIP, continued I18n integration. See [2.1.0] for more information.
- Removed shortcut mappings for all commands (see `dsu help`) to remove dash ("-") preceeding command shortcuts. For example, `dsu -a` (i.e. shortcut for `dsu add`) is now `dsu a`, `dsu -c` (i.e. shortcut for `dsu config`) is now `dsu c`, etc. This was done to avoid confusion as this format is typically used for options, not shortcut commands. The only exception is `dsu version` which will accept shortcuts `dsu v` and `dsu -v`, as `-v` is generally used to display version information.
- Various code refactors.
- Massive updates to README.md.

Bug fixes

- Fix bug that did not apply the current theme to `dsu help add` help.

## [2.1.1] 2023-12-17

Bug fixes

- Fix bug that did not included I18n locale files in yanked version 2.1.0.

## [2.1.0] 2023-12-16

Enhancements

- Added `dsu delete` command to incorporate color themes. See `dsu help delete` for more information.

Bug fixes

- Fix bug that failed to show "(nothing to display for <day>, <date> <local time designator> through <day>, <date> <local time designator>)" for `dsu list dates` command when no entries existed for the entry groups associated with the given dates.

Miscellaneous

- WIP, begin I18n support/integration.
- Update ruby gems.
- Updated README.md to reflect new `dsu delete` command.
- Fix rubocop violations.

## [2.0.8] 2023-12-02

- Update ruby gems.

## [2.0.7] 2023-11-24

- Update ruby gems.
- Remove stale/unnecessary code.

## [2.0.6] 2023-10-30

- Update ruby gems.

## [2.0.5] 2023-10-30

- Update ruby gems.

## [2.0.4] 2023-08-28

- Update ruby gems.

## [2.0.3] 2023-08-17

- Bump activesupport from 7.0.5 to 7.0.7
- Bump simplecov from 0.21.2 to 0.22.0

## [2.0.2] 2023-08-17

- Bumps activemodel from 7.0.5 to 7.0.7.
- Update colorize requirement from ~> 0.8.1 to >= 0.8.1, < 1.2.0
- Bump rubocop-rspec from 2.22.0 to 2.23.2
- Bump rubocop-performance from 1.18.0 to 1.19.0
- Bump rubocop from 1.52.0 to 1.56.0

Changes

- Fix rubocop violations

## [2.0.1] 2023-08-16

Changes

- Bump to official release.
- None (see below).

## [2.0.0] 2023-08-16 (yanked)

## [2.0.0.alpha.1] 2023-08-16

Changes

- Major refactors to the `dsu` codebase.
- Added `dsu theme` command to incorporate color themes. See `dsu help theme` for more information.
- Added `dsu info` command to display details about the current dsu release. See `dsu help info` for more information.
- Added "migrations", which is really a method of backup whereby user data is backed up to the dsu folder under `backup/<migration version>`. Backups will occur whenever a breaking change is made to any of the dsu models (ColorTheme, Configuration, EntryGroup or MigrationVersion). In this way, users can create their own scripts to migrate their associated model `.json`` files to the latest model version, and move them back into the appropriate dsu folder structure so data can be retained.
- Changes to command help to be more uniform.

Bug fixes

- Various bug fixes.

## [2.0.0.alpha.0] 2023-06-26 (yanked)

## [1.2.1] 2023-06-02

Bug fixes

- Fixed a bug that raises an error `NoMethodError` for `entry_group_file_exists?` if the `carry_over_entries_to_today` configuration option is set to true, and attempting to edit today's dsu entries.

## [1.2.0] 2023-05-26

Changes

- Various refactors.
- Bring test coverage to >= 85%.

## [1.1.2] 2023-05-26

Changes

- Various refactors.
- Add more test coverage.

## [1.1.1] 2023-05-23

See previous alpha releases for changes.

## [1.1.1.alpha.2] 2023-05-23

Changes

- For convenience, the `dsu list date` command now takes a MNEMONIC in addition to a DATE. See `dsu list help date` for more information.

Bug fixes

- Fix a bug that did not display `dsu list dates SUBCOMMAND` date list properly when the `--from` option was a date mnemonic and the `--to` optoin was a relative time mnemonic (e.g. `dsu list dates -f today -t +1`). In this case, DSU dates `Time.now` and `Time.now.tomorrow` should be displayed; instead, the bug would consider the `--to` option as relative to `Time.now`, so only 1 DSU date (`Time.now` would be returned).

## [1.1.0.alpha.1] 2023-05-23

Changes

- Added new configuration option `carry_over_entries_to_today` (`true|false`, default: `false`); if true, when editing DSU entries **for the first time** on any given day (e.g. `dsu edit today`), DSU entries from the previous day will be copied to the editing session. If there are no DSU entries from the previous day, `dsu` will search backwards up to 7 days to find a DSU date that has entries to copy. If after searching back 7 days, no DSU entries are found, the editor session will simply start with no previous DSU entries.
- Added new configuration option `include_all` (`true|false`, default: `false`); if true, when using dsu commands that list date ranges (e.g. `dsu list dates`), the displayed list will include dates that have no dsu entries. If false, the displayed list will only include dates that have dsu entries. For all other `dsu list` commands, if true, this option will behave in the aforementioned manner. If false, the displayed list will unconditionally display the first and last dates regardless of whether or not the DSU date has entries or not; all other dates will not be displayed if the DSU date has no entries.
- Changed the look of the editor template when editing entry group entries.

## [1.0.0] 2023-05-18

First official release.

- NOTE: If you have been using the alpha version of `dsu`, you will need to delete the `entries` folder (e.g. `/Users/<whoami>/dsu/entries` on a nix os) as the old entries .json files are incompatible with this official release.

Changes from the alpha version

- When editing an entry group, editor commands are no longer necessary. Simply add, remove or change entries as needed. See the README.md for more information.
- When editing an entry group and saving the results, take note of the folowing behavior:
  - Entering duplicate entries are not allowed, only one entry with a given description is allowed per entry group.
  - Entering entries whose descriptions are < 2 or > 256 characters will fail validation and will not be saved.
  - When editing and encountering any of the aforementioned, the errors will be displayed to the console after the editor file is saved.
- Sha's are no longer being used, as I've not found a good use (currently) to use them. I may add them back in the future if I find a good use for them (tracking entries across entry groups, etc.).
- When adding an entry (`dsu add OPTION`), it used to be that after the entry was added, the entry group for the date being edited would be displayed, as well as "yesterday's" date. This is no longer the case; now, only the entry group for the date being edited is displayed.

## [0.1.0.alpha.5] 2023-05-12

Changes

- `dsu edit SUBCOMMAND` will now allow editing of an entry group for a date that does not yet exist. This will allow you to add entries in the editor using `+|a|add DESCRIPTION`. Be sure to follow the instructions in the editor when editing entry group entries.
- `dsu edit SUBCOMMAND` will gracefully display an error if the entry sha (Entry#uuid) or entry discription (Entry#description) are not unique. In this case, the entry will not be added to the entry group.
  NOTE: Not all edge cases are being handled currently by `dsu edit SUBCOMMAND`.
- `dsu add OPTION` will raise an error if the entry discription (Entry#description) are not unique. This will be handled gracefully in a future release.

## [0.1.0.alpha.4] 2023-05-09

Changes

- Gemfile gemspec description changes.

## [0.1.0.alpha.3] 2023-05-09

Changes

- Entry groups are now editable using the `dsu edit SUBCOMMAND` command. See the README.md or `dsu help edit` for more information.
- Added `editor` configuration option to specify the editor to use when editing an entry group. This configuration option is used if the $EDITOR environment variable is not set.

Bug fixes

- Fix bug that failed to load default configuration values properly when provided (surfaced in specs).

## [0.1.0.alpha.2] 2023-05-08

ATTENTION: After installing this pre-release, run `dsu config info` and take note of the `entries_folder` config option value (e.g. something like '/Users/<whoami>/dsu/entries' on a nix os). You'll need to delete the entry group files therein ( \<YYYY\>\-\<MM\>\-\<DD\>.json e.g. 2023-05-07.json) to avoid errors when running this version of `dsu`.

WIP (not fully implemented yet)

- Added `dsu edit` command to edit an existing entry.

Changes

- Remove Entry#long_description and make Entry#description longer (to 256 bytes max).
- Added `dsu` short-cut commands|options `a|-a`, `c|-c`, `e|-e` and `l|-l` for `add`, `config`, `edit` and `list` commands respectively. For example, can now do `dsu a` or `dsu -a` instead of `dsu add`.
- Added `dsu list` short-cut subcommand|options `d|-d`, `n|-n`, `t|-t` and `y|-y` for `date DATE`, `today`, `tomorrow` and `yesterday` subcommands respectively. For example, can now do `dsu n` or `dsu -n` instead of `dsu today` to list your DSU entries for "today".
- `dsu list` commands now lists all DSU entries from the date being requested (SUBCOMMAND i.e. `today`, `tomorrow`, `yesterday` or `date`), back to and including the previous Friday IF the date being being requested falls on a Monday or weekend. This is so that the DSU entries for the weekend and previous Friday can be shared at DSU if you hold a DSU on the weekend (if you're insane enough to work and have DSU on the weekend) or on a Monday if you happened to work on the weekend as well.
- `dsu config info` now displays the default configuration being used if no configuration file is being used.

Bug fixes

- Fix bug that fails to load/use configuration file options when a config file exists.

## [0.1.0.alpha.1] 2023-05-06

Initial (alpha) release. See README.md for instructions.
