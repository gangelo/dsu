# `dsu` (alpha)

[![GitHub version](http://badge.fury.io/gh/gangelo%2Fdsu.svg)](https://badge.fury.io/gh/gangelo%2Fdsu)
[![Gem Version](https://badge.fury.io/rb/dsu.svg)](https://badge.fury.io/rb/dsu)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/dsu/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/dsu/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

## About
`dsu` is little gem that helps manage your Agile DSU (Daily Stand Up) participation. How? by providing a simple command line interface (CLI) which allows you to create, read, update, and delete (CRUD) noteworthy activities that you performed during your day. During your DSU, you can then easily recall and share these these activities with your team. Activities are grouped by day and can be viewed in simple text format from the command line. When viewing a particular day, dsu will automatically display the previous day's activities as well. This is useful for remembering what you did yesterday, so you can share your "Today" and "Yesterday" activities with your team during your DSU.

**NOTE:** This gem is in development (alpha version). Please see the [WIP Notes](#wip-notes) section for current `dsu` features.

## Quick Start

After installation (`gem install dsu`), the first thing you may want to do is run the `dsu` help:
### Displaying Help
`$ dsu` or `$ dsu help`
```shell
#=>
Commands:
  dsu --version, -v                                 # Displays...
  dsu add [OPTIONS] DESCRIPTION [LONG-DESCRIPTION]  # Adds a dsu entry...
  dsu config SUBCOMMAND                             # Manage...
  dsu help [COMMAND]                                # Describe...
  dsu today                                         # Displays...
  dsu tomorrow                                      # Displays...
  dsu yesterday                                     # Displays...

Options:
  [--debug], [--no-debug]
```

The next thing you may want to do is add some DSU activities (entries) for a particular day:

### Adding DSU Entries
`dsu add [OPTIONS] DESCRIPTION [LONG-DESCRIPTION]`

Adding DSU entry using this command will _add_ the DSU entry for the given day (or date, `-d`), and also _display_ the given day's (or date's, `-d`) DSU entries, as well as the DSU entries for the previous day relative to the given day or date (`-d`).

#### Today
If you need to add a DSU entry to the current day (today), you can use the `-t, [--today]` option. Today (`-t`) is the default; therefore, the `-t` flag is optional when adding DSU entries for the current day:

`$ dsu add [-t] "Pair with John on ticket IN-12345"`

#### Yesterday
If for some reason you need to add a DSU entry for the previous day, you can use the `-p, [--previous-day]` option:

`$ dsu add -p "Pick up ticket IN-12345"`

#### Tomorrow
If you need to add a DSU entry for the previous day, you can use the `-n, [--next-day]` option:

`$ dsu add -n "Pick up ticket IN-12345"`

#### Miscellaneous Date
If you need to add a DSU entry for a date other than yesterday, today or tomorrow, you can use the `-d, [--date=DATE]` option, where DATE is any date string that can be parsed using `Time.parse`. For example: `require 'time'; Time.parse("2023-01-01")`:

`$ dsu add -d "2022-12-31" "Attend company New Years Coffee Meet & Greet"`

### Display DSU Entries
You can display DSU entries for a particular day or date (`date`) using any of the following commands. When displaying DSU entries for a particular day or date (`date`), `dsu` will display the given day or date's (`date`) DSU entries, as well as the DSU entries for the _previous_ day, relative to the given day or date (see [WIP Notes](#wip-notes) for caveats when displaying DSU entries for a particular day or date):

`dsu today`
`dsu tomorrow`
`dsu yesterday`
`dsu date`

#### Examples
The following displays the entries for "Today", where `Time.now == '2023-05-06 08:54:57.6861 -0400'`

`$ dsu today`
```shell
#=>
Saturday, (Today) 2023-05-06
  1. 587a2f29 Blocked for locally failing test IN-12345
              Hope to pair with John on it

Friday, (Yesterday) 2023-05-05
  1. edc25a9a Pick up ticket IN-12345
  2. f7d3018c Attend new hire meet & greet
```

`$ dsu date "2023-05-06"`
```shell
#=>
Saturday, (Today) 2023-05-06
  1. 587a2f29 Blocked for locally failing test IN-12345
              Hope to pair with John on it

Friday, (Yesterday) 2023-05-05
  1. edc25a9a Pick up ticket IN-12345
  2. f7d3018c Attend new hire meet & greet
```


## WIP Notes
This gem is in development (alpha release) and currently does not provide the ability to UPDATE or DELETE activities. These features will be added in future releases.

In addition to this...

`dsu`'s current behavior when viewing a particular day is to display the _previous_ day's activities. This behavior is not necessarily ideal when sharing activities for a DSU that occurs on a Monday. This is because Monday's DSU typically includes sharing what you did on last FRIDAY (not necessarily "Yesterday"), as well as what you plan on doing "Today". This behavior will be changed in a future release to display the previous Friday's activities (as well as Saturday and Sunday) if "Today" happens to fall on a Monday.

## Installation

    $ gem install dsu

## Usage

TODO: Write usage instructions here (see the [Quick Start](#quick-start) for now)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dsu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/dsu/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dsu project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dsu/blob/main/CODE_OF_CONDUCT.md).
