# `dsu`

[![GitHub version](http://badge.fury.io/gh/gangelo%2Fdsu.svg)](https://badge.fury.io/gh/gangelo%2Fdsu)
[![Gem Version](https://badge.fury.io/rb/dsu.svg)](https://badge.fury.io/rb/dsu)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/dsu/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/dsu/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

<img align="center" src="https://i.imgur.com/ff79twF.gif" alt="dsu" />

## About
`dsu` is a simple, but powerful little gem I wrote for myself to help me manage my Agile DSU (Daily Stand Up) participation. How? by providing a simple command line interface (CLI) which allows me to create, read, update, and delete (CRUD) DSU entries on a daily basis. During my DSU, I'm then able to list, recall and share my DSU activities with my team. DSU entries are grouped by day and are viewed in simple text format from the command line, in a myriad of ways, to meet my personal needs. When viewing DSU entries for a particular day, `dsu` will automatically display the previous day's activities as well, using the typical "what I did yesterday", "What I'm doing today" DSU paradigm. If the DSU date I am trying to view falls on a weekend or Monday, `dsu` will automatically display back to and including the weekend and previous Friday (inclusive), so that I can share what I did over the weekend (if anything) and "last" Friday.

You may want to install it and give it a try. If you happen to find `dsu` helpful, give it a star and tell a friend `:)`

## Help

After installation (`gem install dsu`), the first thing you may want to do is run the `dsu` help:
### Displaying Help
`$ dsu` or `$ dsu help`
```shell
#=>
Commands:
  dsu add|-a [OPTIONS] DESCRIPTION  # Adds a DSU entry...
  dsu config|-c SUBCOMMAND          # Manage configuration...
  dsu delete|-d SUBCOMMAND          # Delete DSU entries...
  dsu edit|-e SUBCOMMAND            # Edit DSU entries...
  dsu help [COMMAND]                # Describe available...
  dsu info|-i                       # Displays information...
  dsu list|-l SUBCOMMAND            # Displays DSU entries...
  dsu theme|-t SUBCOMMAND           # Manage DSU themes...
  dsu version|-v                    # Displays this gem version

Options:
  [--debug], [--no-debug]
```

The next thing you may want to do is `add` some DSU activities (entries) for a particular day:

## Adding DSU Entries
`dsu add [OPTIONS] DESCRIPTION`

Adding DSU entry using this command will _add_ the DSU entry for the given day (or date, `-d`), and also _display_ the given day's (or date's, `-d`) DSU entries, as well as the DSU entries for the previous day relative to the given day or date (`-d`). *NOTE: You cannot add duplicate entry group entries; that is, the entry DESCRIPTION needs to be unique within an entry group.*

### Today
If you need to add a DSU entry to the current day (today), you can use the `-n`|`--today` option. Today (`-n`) is the default; therefore, the `-n` flag is optional when adding DSU entries for the current day:

`$ dsu add -n|-today "Pair with John on ticket IN-12345"`

### Yesterday
If for some reason you need to add a DSU entry for yesterday, you can use the `-y`| `--yesterday` option:

`$ dsu add -y|--yesterday "Pick up ticket IN-12345"`

### Tomorrow
If you need to add a DSU entry for tomorrow, you can use the `-t`|`--tomorrow` option:

`$ dsu add -t|--tomorrow "Pick up ticket IN-12345"`

### Miscellaneous Date

Both of the below examples will accomplish the same thing, assuming the current year is 2023; the current year is assumed if omitted:

`$ dsu add -d "12/31/2023" "Attend company New Years Coffee Meet & Greet"`
`$ dsu add -d "12/31" "Attend company New Years Coffee Meet & Greet"`

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.

## Displaying DSU Entries
You can display DSU entries for a particular day or date (`date`) using any of the following commands. When displaying DSU entries for a particular day or date (`date`), `dsu` will display the given day or date's (`date`) DSU entries, as well as the DSU entries for the _previous_ day, relative to the given day or date. If the date or day you are trying to view falls on a weekend or Monday, `dsu` will display back to, and including the weekend and previous Friday inclusive; this is so that you can share what you did over the weekend (if anything) and the previous Friday at your DSU:

- `$ dsu list today|n`
- `$ dsu list tomorrow|t`
- `$ dsu list yesterday|y`
- `$ dsu list date|d DATE|MNEMONIC`
- `$ dsu list dates|dd OPTIONS`

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.
See the [Mnemonics](#mnemonics) section for more information on acceptable MNEMONIC rules and formats used by `dsu`.

IMPORTANT: In some cases the behavior RDNs have on some commands are context dependent; in such cases the behavior will be noted in the help appropriate to the command, for example see the following `dsu` command help: `dsu list help date` and `dsu list help dates`.

### Examples
The following displays the entries for "Today", where `Time.now == '2023-05-06 08:54:57.6861 -0400'`

`$ dsu list today`
```shell
#=>
Saturday, (Today) 2023-05-06
  1. Blocked for locally failing test IN-12345

Friday, (Yesterday) 2023-05-05
  1. Pick up ticket IN-12345
  2. Attend new hire meet & greet
```

`$ dsu list date 5/6/2023`
`$ dsu list date 5/6`

```shell
#=>
Saturday, (Today) 2023-05-06
  1. Blocked for locally failing test IN-12345

Friday, (Yesterday) 2023-05-05
  1. Pick up ticket IN-12345
  2. Attend new hire meet & greet
```

#### Listing Date Ranges
For more information, see the [Mnemonics](#mnemonics) section for more information on acceptable MNEMONIC rules and formats used by `dsu`.

Output omitted for brevity...

Display the DSU entries for the last 3 days.

`dsu list dates --from yesterday --to -2`

Display the DSU entries for 1/1 to 1/4.

`dsu list dates --from 1/1 --to +3`

Display the DSU entries for 1/2 to 1/5.

`dsu list dates --from 1/5 --to -3`

Display the DSU entries for the last week.

`dsu list dates --from today --to -7`

Display the DSU entries back 1 week from yesterday's date. *This example is silly,* but it illustrates the fact that you can use relative mnemonics for both `--from` and `--to` options. While you *can* use relative mnemonics for both `--from` and `--to` options, there is always a more intuitive way.

`dsu list dates --from -7 --to +6`

The above can be accomplished MUCH easier by using the `yesterday` mnemonic. This will display the DSU entries back 1 week from yesterday's date.

`dsu list dates --from yesterday --to -6`

## Editing DSU Entries

You can edit DSU entry groups by date. `dsu` will allow you to edit a DSU entry group using the `dsu edit SUBCOMMAND` date (`n|today|t|tomorrow|y|yesterday|date DATE`) you specify. `dsu edit` will open your DSU entry group entries in your editor, where you'll be able to perform editing functions against one or all of the entries.

If no entries exist for the DSU date, the editor will open and allow you to add entries for that date. If you have the `:carry_over_entries_to_today` configuration option setting set to `true`, entries from the last DSU date will be copied into the editor for your convenience.

*NOTE: duplicate entries are not allowed; that is, the entry DESCRIPTION need to be unique within an entry group. Non-unique entries will not be added to the entry group. The same holds true for entries whose DESCRIPTION that do not pass validation (between 2 and 256 characters (inclusive) in length).*

NOTE: See the "[Customizing the `dsu` Configuration File](#customizing-the-dsu-configuration-file)" section to configure `dsu` to use the editor of your choice and other configuration options to make editing more convenient.

- `$ dsu edit today|n`
- `$ dsu edit tomorrow|t`
- `$ dsu edit yesterday|y`
- `$ dsu edit date|d DATE`

### Examples

The following will edit your DSU entry group entries for "Today", where `Time.now == '2023-05-09 12:13:45.8273 -0400'`. Simply follow the directions in the editor file, then save and close your editor to apply the changes:

`$ dsu edit today`
`$ dsu e n`

```shell
#=> In your editor, you will see...
################################################################################
# Editing DSU Entries for Tuesday, (Today) 2023-05-23 EDT
################################################################################

################################################################################
# DSU ENTRIES
################################################################################

Interative planning meeting 11:00AM.
Pair with Chad on ticket 31211.
Investigate spike ticket 31255.
Review Kelsey's PR ticket 30721.

################################################################################
# INSTRUCTIONS
################################################################################
#    ADD a DSU entry: type an ENTRY DESCRIPTION on a new line.
#   EDIT a DSU entry: change the existing ENTRY DESCRIPTION.
# DELETE a DSU entry: delete the ENTRY DESCRIPTION.
#  NOTE: deleting all of the ENTRY DESCRIPTIONs will delete the entry group file;
#        this is preferable if this is what you want to do :)
# REORDER a DSU entry: reorder the ENTRY DESCRIPTIONs in order preference.
#
# *** When you are done, save and close your editor ***
################################################################################
```

#### Edit an Entry

Simply change the entry descripton text.

For example...
```
from: Interative planning meeting 11:00AM.
  to: Interative planning meeting 12:00AM.
```

#### Add an Entry

Simply type a new entry on a separate line. *Note: any entry that starts with a `#` in the first character position will be ignored.*

For example...
```
Add me to this entry group.
```

#### Delete an Entry

Simply delete the entry.

For example...
```
# Delete this this entry from the editor file
from: Interative planning meeting 11:00AM.
  to: <deleted>
```

#### Reorder Entries

Simply reorder the entries in the editor.

For example...
```
from: Interative planning meeting 11:00AM.
      Pair with Chad on ticket 31211.
      Investigate spike ticket 31255.
      Review Kelsey's PR ticket 30721.
  to: Review Kelsey's PR ticket 30721.
      Investigate spike ticket 31255.
      Pair with Chad on ticket 31211.
      Interative planning meeting 11:00AM.
```
## Deleting DSU Entry Groups
You can delete DSU groups, which will delete all the entries associated with a particular day or date range. When deleting DSU entries for a particular day (`date`, `today`, `tomorrow`, `yesterday`), or date range (`dates`), `dsu` will delete the the entries associated with that day or date range:

- `$ dsu delete today|n`
- `$ dsu delete tomorrow|t`
- `$ dsu delete yesterday|y`
- `$ dsu delete date|d DATE|MNEMONIC`
- `$ dsu delete dates|dd OPTIONS`

NOTE: Before any `dsu` command is executed to delete an entry group, `dsu` will prompt you to confirm your action; you can continue ('y') or cancel ('N').

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.
See the [Mnemonics](#mnemonics) section for more information on acceptable MNEMONIC rules and formats used by `dsu`.

IMPORTANT: In some cases the behavior RDNs have on some commands are context dependent; in such cases the behavior will be noted in the help appropriate to the command, for example see the following `dsu` command help: `dsu delete help date` and `dsu delete help dates`.

### Examples
The following deletes the entry group and all entries for today's date, yesterday's date, and tomorrow's date respectfully.

`$ dsu delete today`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-17 (1 entry groups)? [y/N]> y
Deleted 1 entry group(s).
```

`$ dsu delete yesterday`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-16 (1 entry groups)? [y/N]> y
Deleted 1 entry group(s).
```

`$ dsu delete tomorrow`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-18 (1 entry groups)? [y/N]> y
Deleted 1 entry group(s).
```

The following deletes the entry group and all entries for 12/17 of the current year.

`$ dsu delete date 12/17`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-17 (0 entry groups)? [y/N]> y
Deleted 1 entry group(s)
```

The following deletes the entry group and all entries for the past week, starting from today (12/17/2023).

`$ dsu delete dates --from today --to -6`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-11 thru 2023-12-17 (7 entry groups)? [y/N]> y
Deleted 7 entry group(s).
```
## Customizing the `dsu` Configuration File

It is **not** recommended that you get too attached to the `dsu` configuration options when this gem is in pre-release (e.g. `n.n.n.alpha.n`, `n.n.n.beta.n`, etc.). This is because changes to the configuration file options could change; however, if you're curious, ambitious, or just like living on the edge, have at it. However, just keep in mind that things could change. With an official release (`n.n.n.n`), edit all you want. Regardless, if you *do* want to customize the `dsu` configuration file, you may do the following:

### Customizing the `dsu` Configuration File

```shell
# Locate the dsu configuration file in your home folder.
$ dsu config info
#=>
Dsu v2.0.0

Configuration file contents (/Users/<whoami>/dsu/.dsu)
 1.  version: '20230613121411'
 2.  editor: 'nano'
 3.  entries_display_order: 'desc'
 4.  carry_over_entries_to_today: 'false'
 5.  include_all: 'false'
 6.  theme_name: 'default'
___________________________________
Theme: default
```

Where `<whoami>` would be your username (`$ whoami` on nix systems)

Taking note of the confiruration file path above, you may then edit this file using your favorite editor.

#### Configuration File Options

##### version
_DO NOT_ edit this value. This value coincides with the `dsu` migration version and should not be edited.

##### editor
This is the default editor to use when editing entry groups if the EDITOR environment variable on your system is not set.

Default: `nano` (you'll need to change the default editor on Windows systems)

NOTE: [Visual Studio Code](https://code.visualstudio.com/docs/editor/command-line), users, use `"code --wait"` (or `"code -w"`, short form) to make sure the vscode editor waits for the edited file to be saved and closed before returning control to the dsu process.

##### entries_display_order
Valid values are 'asc' and 'desc', and will sort listed DSU entries in ascending or descending order respectfully, by day.

Default: `'desc'`

##### carry_over_entries_to_today
Applicable to the `dsu edit` command.  Valid values are `true|false`. If `true`, when editing DSU entries *for the first time* on any  given day (e.g. `dsu edit today`), DSU entries from the previous day will be copied into the current editing session. If there are no DSU entries from the previous day, `dsu` will search backwards up to 7 days to find a DSU date that has entries to copy. If after searching back 7 days, no DSU entries are found, the editor session will simply provide no previous DSU entries.

Default: `false`

##### include_all
Applicable to `dsu` commands that display DSU date lists (e.g. `dsu list` commands). Valid values are `true|false`. If `true`, all DSU dates within the specified range will be displayed, regardless of whether or not a particular date has entries. If `false`, only DSU dates between the first and last DSU dates that have entries *will be displayed*.

Default: `false`

##### theme_name
Valid values are any theme names available as a result of running `dsu theme list`. For example: "cherry", default", "lemon", "matrix" and "whiteout".

## Dates

These notes apply to anywhere DATE is used...

DATE may be any date string that can be parsed using `Time.parse`. Consequently, you may omit the year if the date you want to display is the current year (e.g. <month>/<day>, or 1/31). For example: `require 'time'; Time.parse('2023/01/02'); Time.parse('1/2/2023'); Time.parse('1/2') # etc.`

## Mnemonics

These notes apply to anywhere MNEMONIC is used...

A *mnemonic* may be any of the following: `n|today|t|tomorrow|y|yesterday|+n|-n`.

Where `n`, `t`, `y` are aliases for `today`, `tomorrow`, and `yesterday`, respectively.

Where `+n`, `-n` are relative date mnemonics (RDNs). Generally speaking, RDNs are relative to the current date. For example, a RDN of `+1` would be equal to `Time.now + 1.day` (or tomorrow), and a RDN of `-1` would be equal to `Time.now - 1.day` (or yesterday).

NOTE: In some cases the behavior RDNs have on some commands are context dependent; in such cases the behavior will be noted in the help appropriate to the command, for example see the following `dsu` command help: `dsu list help date` and `dsu list help dates`.


## Installation

    $ gem install dsu

## Usage

TODO: Write usage instructions here (see the [Quick Start](#quick-start) for now)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gangelo/dsu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/dsu/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dsu project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dsu/blob/main/CODE_OF_CONDUCT.md).
