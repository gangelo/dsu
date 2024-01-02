# `dsu`- Streamline Your Daily Stand-Up Meeting Participation!

[![Ruby](https://github.com/gangelo/dsu/actions/workflows/ruby.yml/badge.svg)](https://github.com/gangelo/dsu/actions/workflows/ruby.yml)
[![GitHub version](http://badge.fury.io/gh/gangelo%2Fdsu.svg?refresh=5)](https://badge.fury.io/gh/gangelo%2Fdsu)
[![Gem Version](https://badge.fury.io/rb/dsu.svg?refresh=5)](https://badge.fury.io/rb/dsu)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/dsu/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/dsu/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

<img align="center" src="https://i.imgur.com/ff79twF.gif" alt="dsu" />

## Simplify Your Agile Routine
`dsu` is a sleek and powerful gem that transforms the way you participate in Agile Daily Stand-Ups (DSU). It's designed for developers who love simplicity and efficiency. With `dsu`, you get a user-friendly command-line interface to quickly manage your daily stand-up activities.

## Why dsu?
- **Organize Your Tasks:** Easily add, view, update, or delete your DSU entries.
- **Be Prepared:** Instantly list out your activities for "Yesterday" and plans for "Today" during stand-ups.
- **Smart Handling of Dates:** `dsu` intelligently includes your weekend and previous Friday activities when necessesary, so you're always ready to share comprehensive updates.
- **CLI Lovers Rejoice:** If you're a fan of simple command-line tools, `dsu` is a perfect fit.

### Getting Started Is Easy
Just run `gem install dsu` from your terminal, and you're on your way to more organized and efficient stand-ups. Check out the help section with `$ dsu help` for quick guidance.

## Engage with `dsu`
Found `dsu` helpful? Star it on GitHub and spread the word! Your feedback and contributions are welcome to make `dsu` even better.

## Quick Install
```shell
gem install dsu
```

## Help

After installation (`gem install dsu`), the first thing you may want to do is run the `dsu` help:
### Displaying Help
`$ dsu` or `$ dsu help`
```shell
#=>
Commands:
  dsu add|a [OPTIONS] DESCRIPTION  # Adds a DSU entry...
  dsu browse|b SUBCOMMAND          # Browse DSU entries...
  dsu config|c SUBCOMMAND          # Manage configuration...
  dsu delete|d SUBCOMMAND          # Delete DSU entries...
  dsu edit|e SUBCOMMAND            # Edit DSU entries...
  dsu export|x SUBCOMMAND          # Export DSU entries...
  dsu help [COMMAND]               # Describe available...
  dsu import|m SUBCOMMAND          # Imports DSU entries...
  dsu info|i                       # Displays information...
  dsu list|l SUBCOMMAND            # Displays DSU entries...
  dsu theme|t SUBCOMMAND           # Manage DSU themes...
  dsu version|-v|v                 # Displays this gem version

Options:
  [--debug], [--no-debug]
```

# Using `dsu`
The folowing section outlines how to use the `dsu` gem.

## Adding DSU Entries
The next thing you may want to do is `add` some DSU activities (entries) for a particular day:

`$ dsu add [OPTIONS] DESCRIPTION`

`$ dsu a [OPTIONS] DESCRIPTION`

Adding DSU entry using this command will _add_ the DSU entry for the given day or date, and then _display_ the DSU entries for that day or date.

**NOTE:** You cannot add duplicate entries for the same day; that is, entry DESCRIPTIONS need to be unique within an entry group for the given day.

### Today
If you need to add a DSU entry for the current day (today), you can use the `-n`|`--today` option. Today (`-n`) is the default; therefore, the `-n` flag is optional if you want to add a DSU entry for the _current day_ (today). For example, the below commands will both accomplish the same thing:

`$ dsu add [-n|--today] "Pair with John on ticket IN-12345"`

`$ dsu a "Pair with John on ticket IN-12345"`

### Yesterday
If for some reason you need to add a DSU entry for yesterday, you can use the `-y`| `--yesterday` option. Both of the below commands accomplish the same thing:

`$ dsu add --yesterday "Pick up ticket IN-12345"`

`$ dsu a -y "Pick up ticket IN-12345"`

### Tomorrow
If you need to add a DSU entry for tomorrow, you can use the `-t`|`--tomorrow` option:

`$ dsu add --tomorrow "Pick up ticket IN-12345"`

`$ dsu a -t "Pick up ticket IN-12345"`

### Miscellaneous Date

Both of the below examples will accomplish the same thing, assuming the current year is 2023; the current year is assumed when omitted:

**NOTE:** When **omitting year**, dates must be entered in `MM/DD` format.
**NOTE:** When **including year**, dates must be entered in `YYYY/MM/DD` format.

`$ dsu add --date 2023/12/31 "Attend New Years Coffee Meet & Greet"`

`$ dsu a -d 12/31 "Attend New Years Coffee Meet & Greet"`

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.

## Displaying DSU Entries
You can display DSU entries for a particular day or date using any of the following commands. When displaying DSU entries for a particular day or date, `dsu` will display the DSU entries for the given day or date, as well as the DSU entries for the _previous_ day, relative to the given day or date. If the given day or date falls on a weekend or Monday, `dsu` will display any entries for the preceeding weekend _and_ Friday; this is so that you can share any activities that occurred over the weekend (if anything) as well as any activities for the previous Friday:

- `$ dsu list today`
- `$ dsu l n` # Equivalent to the above, only using shortcuts
- `$ dsu list tomorrow`
- `$ dsu l t` # Equivalent to the above, only using shortcuts
- `$ dsu list yesterday`
- `$ dsu l y` # Equivalent to the above, only using shortcuts
- `$ dsu list date DATE|MNEMONIC`
- `$ dsu l d DATE|MNEMONIC` # Equivalent to the above, only using shortcuts
- `$ dsu list dates OPTIONS`
- `$ dsu l dd OPTIONS` # Equivalent to the above, only using shortcuts

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.
See the [Mnemonics](#mnemonics) section for more information on acceptable MNEMONIC rules and formats used by `dsu`.

**IMPORTANT:** In some cases the behavior _relative date mnemonics_ (RDMs, see the [Mnemonics](#mnemonics) section for more information about RDMs) have on some commands are context dependent; in such cases the behavior will be noted in the help appropriate to the command, for example see the following `dsu` command help: `dsu list help date` and `dsu list help dates`.

### Examples
The following displays the entries for "Today", where `Time.now == '2023-05-06 08:54:57.6861 -0400'`

`$ dsu list today`

`$ dsu l t`
```shell
#=>
Saturday, (Today) 2023-05-06
  1. Blocked for locally failing test IN-12345

Friday, (Yesterday) 2023-05-05
  1. Pick up ticket IN-12345
  2. Attend new hire meet & greet
```

`$ dsu list date 5/7/2023`

`$ dsu list d 2023/7/5`

`$ dsu l d 7/5` # When omitting YYYY, MM/DD is assumed

```shell
#=>
Wednesday, (Today) 2023-07-05
  1. Blocked for locally failing test IN-12345

Tuesday, (Yesterday) 2023-07-04
  1. Pick up ticket IN-12345
  2. Attend new hire meet & greet
```
**NOTE:** If `DATE` (`date`|`d`) falls on a weekend or Monday, `dsu` will display any entries for the preceeding weekend _and_ Friday.

#### Listing Date Ranges
For more information, see the [Mnemonics](#mnemonics) section for more information on acceptable MNEMONIC rules and formats used by `dsu`.

**NOTE:** Output omitted for brevity...

##### Display the DSU entries for the last 3 days
`$ dsu list dates --from yesterday --to -2`

`$ dsu l dd -f y -t -2`

##### Display the DSU entries for 1/1 to 1/4 for the current year
`$ dsu list dates --from 1/1 --to +3`

`$ dsu l dd -f 1/1 -t +3`

##### Display the DSU entries for 1/2 to 1/5
`$ dsu list dates --from 1/5 --to -3`

`$ dsu l dd -f 1/5 -t -3`

##### Display the DSU entries for the last week
`$ dsu list dates --from today --to -6`

`$ dsu l dd -f n -t -6`

##### Display the DSU entries back 1 week from yesterday's date
`$ dsu list dates --from -7 --to +6`

`$ dsu l dd -f -7 -t +6`

**NOTE:** **The above example is silly,** but it illustrates the fact that you can use relative mnemonics for both `--from` and `--to` options. While you *can* use relative mnemonics for both the `--from` and `--to` options, there is usually a more intuitive way.

For example:

This can be accomplished MUCH easier by using the `yesterday` mnemonic. This will display the DSU entries back 1 week from yesterday's date.

`$ dsu list dates --from yesterday --to -6`

`$ dsu l dd -f y -t -6`

## Browsing DSU Entries
You can browse DSU entries for the current week, month and year using any of the following commands. `dsu browse` somewhat similar to `dsu list` with added `week`, `month` and `year` convenience SUBCOMMANDs. `dsu browse` also pipes the output to the terminal, so you can conveniently scroll through the listed entries using your keyboard or mouse:

**NOTE:** Keyboard and/or mouse behavior while browsing (scrolling), is operating system dependent; `dsu browse` pipes its output to the terminal using `less` on nix systems, and `more` on Windows systems.

- `$ dsu browse week`
- `$ dsu b w` # Equivalent to the above, only using shortcuts
- `$ dsu browse month`
- `$ dsu b m` # Equivalent to the above, only using shortcuts
- `$ dsu browse year`
- `$ dsu b y` # Equivalent to the above, only using shortcuts

## Editing DSU Entries

You can edit DSU entry groups by date. `dsu` will allow you to edit a DSU entry group using the `dsu edit SUBCOMMAND` date (`n|today|t|tomorrow|y|yesterday|date DATE`) you specify. `dsu edit` will open your DSU entry group entries in your editor, where you'll be able to perform editing functions against one or all of the entries.

If no entries exist for the DSU date, the editor will open and allow you to add entries for that date. If you have the `:carry_over_entries_to_today` configuration option setting set to `true`, entries from the last DSU date will be copied into the editor for your convenience.

**NOTE:** duplicate entries are not allowed; that is, the entry DESCRIPTION must be unique within an entry group. Non-unique entries will not be added to the entry group. The same holds true for entries whose DESCRIPTION that do not pass validation (between 2 and 256 characters (inclusive) in length).

**NOTE:** See the "[Customizing the `dsu` Configuration File](#customizing-the-dsu-configuration-file)" section to configure `dsu` to use the editor of your choice and other configuration options to make editing more convenient.

- `$ dsu edit today`
- `$ dsu e n` # Equivalent to the above, only using shortcuts
- `$ dsu edit tomorrow`
- `$ dsu e t` # Equivalent to the above, only using shortcuts
- `$ dsu edit yesterday`
- `$ dsu e y` # Equivalent to the above, only using shortcuts
- `$ dsu edit date DATE`
- `$ dsu e d DATE` # Equivalent to the above, only using shortcuts

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

Simply type a new entry on a separate line.

For example...
```
Add me to this entry group.
```

**NOTE:** Any entry that starts with a `#` in the first character position will be ignored.*

#### Delete an Entry

Simply delete the entry.

For example...
```
# Delete this entry from the editor file
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
You can delete DSU entry groups; this will delete *all* the entries for the particular day or date range. When deleting DSU entries for a particular day (`date`, `today`, `tomorrow`, `yesterday`), or date range (`dates`), `dsu` will delete the entry group(s) and *all* the associated entries for that day or date range:

- `$ dsu delete today`
- `$ dsu d n` # Equivalent to the above, only using shortcuts
- `$ dsu delete tomorrow`
- `$ dsu d t` # Equivalent to the above, only using shortcuts
- `$ dsu delete yesterday`
- `$ dsu d y` # Equivalent to the above, only using shortcuts
- `$ dsu delete date DATE|MNEMONIC`
- `$ dsu d d DATE|MNEMONIC` # Equivalent to the above, only using shortcuts
- `$ dsu delete dates OPTIONS`
- `$ dsu d dd OPTIONS` # Equivalent to the above, only using shortcuts

**NOTE:** Before any of the above `dsu` commands are executed, `dsu` will prompt you to confirm the delete; you can continue ('y') or cancel ('N').

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.
See the [Mnemonics](#mnemonics) section for more information on acceptable MNEMONIC rules and formats used by `dsu`.

**IMPORTANT:** In some cases the behavior that _relative date mnemonics_ (RDMs, see the [Mnemonics](#mnemonics) section for more information about RDMs) have on some commands are context dependent; in such cases the behavior will be noted in the help appropriate to the command, for example see the following `dsu` command help: `dsu delete help date` and `dsu delete help dates`.

### Examples
The following example deletes the entry group and *all* entries for today's date.

`$ dsu delete today`

`$ dsu d n`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-17 (1 entry groups)? [y/N]> y
Deleted 1 entry group(s).
```
The following example deletes the entry group and *all* entries for yesterday's date.

`$ dsu delete yesterday`

`$ dsu d y`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-16 (1 entry groups)? [y/N]> y
Deleted 1 entry group(s).
```
The following example deletes the entry group and *all* entries for tomorrow's date.

`$ dsu delete tomorrow`

`$ dsu d t`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-18 (1 entry groups)? [y/N]> y
Deleted 1 entry group(s).
```

The following deletes the entry group and all entries for 12/17 of the current year.

`$ dsu delete date 12/17`

`$ dsu d d 12/17`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-17 (0 entry groups)? [y/N]> y
Deleted 1 entry group(s)
```

The following deletes the entry group and all entries for the past week, starting from today (12/17/2023).

`$ dsu delete dates --from today --to -6`

`$ dsu d dd -f n -t -6`
```shell
#=>
Are you sure you want to delete all the entries for 2023-12-11 thru 2023-12-17 (7 entry groups)? [y/N]> y
Deleted 7 entry group(s).
```

## Exporting DSU Entries

Some ingenious soul may want to write a utility at some point, so `dsu` provides the means to export its data into a `csv` file for convenience. Of course, if you feel so inclined, you may also use the `dsu` entry group `json` files directly. The `dsu` entry group `json` files can be located by running the `dsu info` command, and locating the "Entries folder" value.

If you want to use a `csv` file, you can export `dsu` entries to a `csv` file by using any of the following commands:

- `$ dsu export all`
- `$ dsu x a` # Equivalent to the above, only using shortcuts
- `$ dsu export dates OPTIONS`
- `$ dsu x dd OPTIONS` # Equivalent to the above, only using shortcuts

**NOTE:** Each `export` command will prompt you to confirm the export. If confirmed, `dsu` will write a `csv` file to your operating systems temp folder, in the following format: `"dsu-<timestamp>-<from date>-thru-<to date>.csv"`:

Where:
- <timestamp> = '%Y%m%d%H%M%S'
- <from date> = the date of the earliest entry group exported (if `export all`) or the earliest date of the entry group dates to be exported (if `export dates`).
- <to date> = the date of the most resent entry group exported (if `export all`) or the most recent date of the entry group dates to be exported (if `export dates`).
-
### For example

The following command, when run on December 25, 2023, at 20:15:46...

`$ dsu export dates -f 1/1/1999 -t 12/23/2023`

...will export `dsu` entries for all Entry Groups that fall between the dates of January 1st, 1999 through December 23rd 2023 in the time zone it was executed, and write them to the following file:

`/var/folders/yv/5n77gtzn7z33ytwgr9mlbbrhf5rws6/T/dsu-20231225201546-1999-01-01-thru-2023-12-23.csv`

For more information, see `dsu` help (`$ dsu export` or `dsu help export`) for more information.

## Importing DSU Entries

`dsu` provides a means to import entry group entry data from a previously exported `csv` file (see [Exporting DSU Entries](#exporting-dsu-entries)).

If you want to import a previously expoeted `csv` file, you can import `dsu` entries from a `csv` file by using any of the following commands:

- `$ dsu import all`
- `$ dsu m a` # Equivalent to the above, only using shortcuts
- `$ dsu import dates OPTIONS`
- `$ dsu m dd OPTIONS` # Equivalent to the above, only using shortcuts

**NOTE:** Each `import` command will prompt you to confirm the import. If confirmed, `dsu` will import the entry group entry data from the `csv` file into `dsu`.

### For example

### Importing all entries from a `csv` file
You can import _all_ entry group entries from a `csv` file.

The following command will import all the `dsu` entries from the given `csv` file, and merge the imported entries with any existing entry group entries you may have:

`$ dsu import all -i ~/Downloads/dsu-20231225201546-2023-01-01-thru-2024-01-01.csv`

The following command will import all the `dsu` entries from the given `csv` file, and **_overwrite_** all entry groups entries with the same entry group date using the `dsu export all` shortcut command:

`$ dsu m a -m false -i ~/Downloads/dsu-20231225201546-2023-01-01-thru-2024-01-01.csv`

### Importing specific entries from a `csv` file
You can import _specific_ entry group entries from a `csv` file for a date range.

The following command will import the `dsu` entries from the given `csv` file for the given date range, and merge the imported entries with any existing entry group entries you may have:

`$ dsu import dates --from 1/1/2023 --to 12/31/2023 -i ~/Downloads/dsu-20231225201546-2023-01-01-thru-2024-01-01.csv`

The following command will import the `dsu` entries from the given `csv` file for the given date range, and **_overwrite_** all entry groups entries with the same entry group date using the `dsu import dates` shortcut command:

`$ dsu m dd -m false -f 1/1/2023 -t 12/31/2023 -i ~/Downloads/dsu-20231225201546-2023-01-01-thru-2024-01-01.csv`

## Customizing the `dsu` Configuration File
To customize the `dsu` configuration file, you may follow the instructions outlined here. It is only recommended that you customize the `dsu` configuration file *only* if you are working with an official release (`n.n.n.n`).

**NOTE:** It is **not** recommended that you get too attached to the `dsu` configuration options when this gem is in **pre-release** (e.g. `n.n.n.alpha.n`, `n.n.n.beta.n`, etc.). This is because changes to the configuration file options, of course, could change. With an official release (`n.n.n.n`), edit all you want!

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

Where `+n`, `-n` are relative date mnemonics (RDMs). Generally speaking, RDMs are relative to the current date. For example, a RDM of `+1` would be equal to `Time.now + 1.day` (or tomorrow), and a RDM of `-1` would be equal to `Time.now - 1.day` (or yesterday).

NOTE: In some cases the behavior RDMs have on some commands are context dependent; in such cases the behavior will be noted in the help appropriate to the command, for example see the following `dsu` command help: `dsu list help date` and `dsu list help dates`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gangelo/dsu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/dsu/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dsu project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dsu/blob/main/CODE_OF_CONDUCT.md).
