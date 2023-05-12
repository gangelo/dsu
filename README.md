# `dsu` (alpha)

[![GitHub version](http://badge.fury.io/gh/gangelo%2Fdsu.svg)](https://badge.fury.io/gh/gangelo%2Fdsu)
[![Gem Version](https://badge.fury.io/rb/dsu.svg)](https://badge.fury.io/rb/dsu)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/dsu/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/dsu/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

## About
`dsu` is little gem that helps manage your Agile DSU (Daily Stand Up) participation. How? by providing a simple command line interface (CLI) which allows you to create, read, update, and delete (CRUD) noteworthy activities that you performed during your day. During your DSU, you can then easily recall and share these these activities with your team. Activities are grouped by day and can be viewed in simple text format from the command line. When viewing a particular day, `dsu` will automatically display the previous day's activities as well. This is useful for remembering what you did yesterday, so you can share your "Today" and "Yesterday" activities with your team during your DSU. If the day you are trying to view falls on a weekend or Monday, `dsu` will display back to, and including the weekend and previous Friday inclusive, so that you can share what you did over the weekend (if anything) and the previous Friday.

**NOTE:** This gem is in development (alpha version). Please see the [WIP Notes](#wip-notes) section for current `dsu` features.

## Help

After installation (`gem install dsu`), the first thing you may want to do is run the `dsu` help:
### Displaying Help
`$ dsu` or `$ dsu help`
```shell
#=>
Commands:
  dsu add, -a [OPTIONS] DESCRIPTION  # Adds a DSU entry...
  dsu config, -c SUBCOMMAND          # Manage configuration...
  dsu edit, -e SUBCOMMAND            # Edit DSU entries...
  dsu help [COMMAND]                 # Describe available...
  dsu list, -l SUBCOMMAND            # Displays DSU entries...
  dsu version, -v                    # Displays this gem version

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

`$ dsu add -d "2022-12-31" "Attend company New Years Coffee Meet & Greet"`

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.

## Displaying DSU Entries
You can display DSU entries for a particular day or date (`date`) using any of the following commands. When displaying DSU entries for a particular day or date (`date`), `dsu` will display the given day or date's (`date`) DSU entries, as well as the DSU entries for the _previous_ day, relative to the given day or date. If the date or day you are trying to view falls on a weekend or Monday, `dsu` will display back to, and including the weekend and previous Friday inclusive; this is so that you can share what you did over the weekend (if anything) and the previous Friday at your DSU:

- `$ dsu list today|n`
- `$ dsu list tomorrow|t`
- `$ dsu list yesterday|y`
- `$ dsu list date|d DATE`

### Examples
The following displays the entries for "Today", where `Time.now == '2023-05-06 08:54:57.6861 -0400'`

`$ dsu list today`
```shell
#=>
Saturday, (Today) 2023-05-06
  1. 587a2f29 Blocked for locally failing test IN-12345
              Hope to pair with John on it

Friday, (Yesterday) 2023-05-05
  1. edc25a9a Pick up ticket IN-12345
  2. f7d3018c Attend new hire meet & greet
```

`$ dsu list date "2023-05-06"`

See the [Dates](#dates) section for more information on acceptable DATE formats used by `dsu`.

```shell
#=>
Saturday, (Today) 2023-05-06
  1. 587a2f29 Blocked for locally failing test IN-12345
              Hope to pair with John on it

Friday, (Yesterday) 2023-05-05
  1. edc25a9a Pick up ticket IN-12345
  2. f7d3018c Attend new hire meet & greet
```
## Editing DSU Entries

You can edit DSU entry groups by date. `dsu` will allow you to edit a DSU entry group using the `dsu edit SUBCOMMAND` date (today|tomorrow|yesterday|date DATE) you specify. `dsu edit` will open your DSU entry group entries in your editor, where you'll be able to perform editing functions against one or all of the entries. If no entries exist in the entry group, you can add entries using any of the the *add* (`+|a|add`) editor commands, followed by the entry description. *NOTE: you cannot add duplicate entries; that is, the entry SHA and DESCRIPTION need to be unique within an entry group. Non-unique entries will not be added to the entry group.*

Note: See the "[Customizing the `dsu` Configuration File](#customizing-the-dsu-configuration-file)"" section to configure `dsu` to use the editor of your choice.

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
# Editing DSU Entries for Tuesday, (Today) 2023-05-09 EDT

# [SHA/COMMAND] [DESCRIPTION]
3849f0c0 Interative planning meeting 11:00AM.
586478f5 Pair with Chad on ticket 31211.
9e5f82c8 Investigate spike ticket 31255.
59b25ca7 Review Kelsey's PR ticket 30721.

# INSTRUCTIONS:
# ADD a DSU entry: use one of the following commands: [+|a|add] followed by the description.
# EDIT a DSU entry: change the description.
# DELETE a DSU entry: delete the entry or replace the sha with one of the following commands: [-|d|delete].
# NOTE: deleting all the entries will delete the entry group file;
#       this is preferable if this is what you want to do :)
# REORDER a DSU entry: reorder the DSU entries in order preference.
#
# *** When you are done, save and close your editor ***
```

#### Edit an Entry

Simply change the entry descripton text.

For example...
```
from: 3849f0c0 Interative planning meeting 11:00AM.
  to: 3849f0c0 Interative planning meeting 12:00AM.
```

#### Add an Entry

Replace the entry `sha` one of the add commands: `[+|a|add]`.

For example...
```
+ Add me to this entry group.
```

#### Delete an Entry

Simply delete the entry or replace the entry `sha` one of the delete commands: `[-|d|delete]`.

For example...
```
# Delete this this entry from the editor file
3849f0c0 Interative planning meeting 11:00AM.
```
or
```
from: 3849f0c0 Interative planning meeting 11:00AM.
  to: - Interative planning meeting 11:00AM.
```

#### Reorder Entries

Simply reorder the entries in the editor.

For example...
```
from: 3849f0c0 Interative planning meeting 11:00AM.
      586478f5 Pair with Chad on ticket 31211.
      9e5f82c8 Investigate spike ticket 31255.
      59b25ca7 Review Kelsey's PR ticket 30721.
  to: 59b25ca7 Review Kelsey's PR ticket 30721.
      9e5f82c8 Investigate spike ticket 31255.
      586478f5 Pair with Chad on ticket 31211.
      3849f0c0 Interative planning meeting 11:00AM.
```

## Customizing the `dsu` Configuration File

It is **not** recommended that you create and customize a `dsu` configuration file while this gem is in alpha release. This is because changes to what configuration options are available may take place while in alpha that could break `dsu`. If you *do* want to create and customize the `dsu` configuration file reglardless, you may do the following.

### Initializing/Customizing the `dsu` Configuration File

```shell
# Creates a dsu configuration file in your home folder.
$ dsu config init

#=>
Configuration file (/Users/<whoami>/.dsu) created.
Config file (/Users/<whoami>/.dsu) contents:
---
editor: nano
entries_display_order: desc
entries_file_name: "%Y-%m-%d.json"
entries_folder: "/Users/<whoami>/dsu/entries"
```

Where `<whoami>` would be your username (`$ whoami` on nix systems)

Once the configuration file is created, you can locate where the `dsu` configuration file is located by running `$ dsu config info` and taking note of the confiruration file path. You may then edit this file using your favorite editor.

#### Configuration File Options

##### editor
This is the default editor to use when editing entry groups if the EDITOR environment variable on your system is not set.

Default: `nano` (you'll need to change the default editor on Windows systems)

##### entries_display_order
Valid values are 'asc' and 'desc', and will sort listed DSU entries in ascending or descending order respectfully, by day.

Default: `'desc'`

##### entries_file_name
The entries file name format. It is recommended that you do not change this. The file name must include `%Y`, `%m` and `%d` `Time` formatting specifiers to make sure the file name is unique and able to be located by `dsu` functions. For example, the default file name is `%Y-%m-%d.json`; however, something like `%m-%d-%Y.json` or `entry-group-%m-%d-%Y.json` would work as well.

ATTENTION: Please keep in mind that if you change this value `dsu` will not recognize entry files using a different format. You would (at this time), have to manually rename any existing entry file names to the new format.

Default: `'%Y-%m-%d.json'`

##### entries_folder
This is the folder where `dsu` stores entry files. You may change this to anything you want. `dsu` will create this folder for you, as long as your system's write permissions allow this.

ATTENTION: Please keep in mind that if you change this value `dsu` will not be able to find entry files in any previous folder. You would (at this time), have to manually mode any existing entry files to this new folder.

Default: `'/Users/<whoami>/dsu/entries'` on nix systems.

Where `<whoami>` would be your username (`$ whoami` on nix systems)

## Dates

These notes apply to anywhere DATE is used...

DATE may be any date string that can be parsed using `Time.parse`. Consequently, you may use also use '/' as date separators, as well as omit the year if the date you want to display is the current year (e.g. <month>/<day>, or 1/31). For example: `require 'time'; Time.parse('2023-01-02'); Time.parse('1/2') # etc.`

## WIP Notes
This gem is in development (alpha release).

- Not all edge cases are being handled currently by `dsu edit SUBCOMMAND`.
- `dsu add OPTION` will raise an error if the entry discription (Entry#description) are not unique. This will be handled gracefully in a future release.

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
