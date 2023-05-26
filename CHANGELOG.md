## [1.2.0] 2023-05-26
* Changes
  - Various refactors.
  - Bring test coverage to >= 85%.
## [1.1.2] 2023-05-26
* Changes
  - Various refactors.
  - Add more test coverage.
## [1.1.1] - 2023-05-23
* See previous alpha releases for changes.
## [1.1.1.alpha.2] - 2023-05-23
* Changes
  - For convenience, the `dsu list date` command now takes a MNEUMONIC in addition to a DATE. See `dsu list help date` for more information.
* Bug fixes
  - Fix a bug that did not display `dsu list dates SUBCOMMAND` date list properly when the `--from` option was a date mneumonic and the `--to` optoin was a relative time mneumonic (e.g. `dsu list dates -f today -t +1`). In this case, DSU dates `Time.now` and `Time.now.tomorrow` should be displayed; instead, the bug would consider the `--to` option as relative to `Time.now`, so only 1 DSU date (`Time.now` would be returned).
## [1.1.0.alpha.1] - 2023-05-23
* Changes
  - Added new configuration option `carry_over_entries_to_today` (`true|false`, default: `false`); if true, when editing DSU entries **for the first time** on any  given day (e.g. `dsu edit today`), DSU entries from the previous day will be copied to the editing session. If there are no DSU entries from the previous day, `dsu` will search backwards up to 7 days to find a DSU date that has entries to copy. If after searching back 7 days, no DSU entries are found, the editor session will simply start with no previous DSU entries.
  - Added new configuration option `include_all` (`true|false`, default: `false`); if true, when using dsu commands that list date ranges (e.g. `dsu list dates`), the displayed list will include dates that have no dsu entries. If false, the displayed list will only include dates that have dsu entries. For all other `dsu list` commands, if true, this option will behave in the aforementioned manner. If false, the displayed list will unconditionally display the first and last dates regardless of whether or not the DSU date has entries or not; all other dates will not be displayed if the DSU date has no entries.
  - Changed the look of the editor template when editing entry group entries.
## [1.0.0] - 2023-05-18
* First official release.
* NOTE: If you have been using the alpha version of `dsu`, you will need to delete the `entries` folder (e.g. `/Users/<whoami>/dsu/entries` on a nix os) as the old entries .json files are incompatible with this official release.
* Changes from the alpha version
  - When editing an entry group, editor commands are no longer necessary. Simply add, remove or change entries as needed. See the README.md for more information.
  - When editing an entry group and saving the results, take note of the folowing behavior:
    - Entering duplicate entries are not allowed, only one entry with a given description is allowed per entry group.
    - Entering entries whose descriptions are < 2 or > 256 characters will fail validation and will not be saved.
    - When editing and encountering any of the aforementioned, the errors will be displayed to the console after the editor file is saved.
  - Sha's are no longer being used, as I've not found a good use (currently) to use them. I may add them back in the future if I find a good use for them (tracking entries across entry groups, etc.).
  - When adding an entry (`dsu add OPTION`), it used to be that after the entry was added, the entry group for the date being edited would be displayed, as well as "yesterday's" date. This is no longer the case; now, only the entry group for the date being edited is displayed.
## [0.1.0.alpha.5] - 2023-05-12
* Changes
  - `dsu edit SUBCOMMAND` will now allow editing of an entry group for a date that does not yet exist. This will allow you to add entries in the editor using `+|a|add DESCRIPTION`. Be sure to follow the instructions in the editor when editing entry group entries.
  - `dsu edit SUBCOMMAND` will gracefully display an error if the entry sha (Entry#uuid) or entry discription (Entry#description) are not unique. In this case, the entry will not be added to the entry group.
  NOTE: Not all edge cases are being handled currently by `dsu edit SUBCOMMAND`.
  - `dsu add OPTION` will raise an error if the entry discription (Entry#description) are not unique. This will be handled gracefully in a future release.
## [0.1.0.alpha.4] - 2023-05-09
* Changes
  - Gemfile gemspec description changes.
## [0.1.0.alpha.3] - 2023-05-09
* Changes
  - Entry groups are now editable using the `dsu edit SUBCOMMAND` command. See the README.md or `dsu help edit` for more information.
  - Added `editor` configuration option to specify the editor to use when editing an entry group. This configuration option is used if the $EDITOR environment variable is not set.
* Bug fixes
  - Fix bug that failed to load default configuration values properly when provided (surfaced in specs).

## [0.1.0.alpha.2] - 2023-05-08
* ATTENTION: After installing this pre-release, run `dsu config info` and take note of the `entries_folder` config option value (e.g. something like '/Users/<whoami>/dsu/entries' on a nix os). You'll need to delete the entry group files therein ( \<YYYY\>\-\<MM\>\-\<DD\>.json e.g. 2023-05-07.json) to avoid errors when running this version of `dsu`.
* WIP (not fully implemented yet)
  - Added `dsu edit` command to edit an existing entry.
* Changes
  - Remove Entry#long_description and make Entry#description longer (to 256 bytes max).
  - Added `dsu` short-cut commands|options `a|-a`, `c|-c`, `e|-e` and `l|-l` for `add`, `config`, `edit` and `list` commands respectively. For example, can now do `dsu a` or `dsu -a` instead of `dsu add`.
   - Added `dsu list` short-cut subcommand|options `d|-d`, `n|-n`, `t|-t` and `y|-y` for `date DATE`, `today`, `tomorrow` and `yesterday` subcommands respectively. For example, can now do `dsu n` or `dsu -n` instead of `dsu today` to list your DSU entries for "today".
  - `dsu list` commands now lists all DSU entries from the date being requested (SUBCOMMAND i.e. `today`, `tomorrow`, `yesterday` or `date`), back to and including the previous Friday IF the date being being requested falls on a Monday or weekend. This is so that the DSU entries for the weekend and previous Friday can be shared at DSU if you hold a DSU on the weekend (if you're insane enough to work and have DSU on the weekend) or on a Monday if you happened to work on the weekend as well.
  - `dsu config info` now displays the default configuration being used if no configuration file is being used.
* Bug fixes
  - Fix bug that fails to load/use configuration file options when a config file exists.

## [0.1.0.alpha.1] - 2023-05-06
- Initial (alpha) release. See README.md for instructions.
