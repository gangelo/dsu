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
