# `dsu`

[![Ruby](https://github.com/gangelo/dsu/actions/workflows/ruby.yml/badge.svg)](https://github.com/gangelo/dsu/actions/workflows/ruby.yml)
[![GitHub version](http://badge.fury.io/gh/gangelo%2Fdsu.svg?refresh=15)](https://badge.fury.io/gh/gangelo%2Fdsu)
[![Gem Version](https://badge.fury.io/rb/dsu.svg?refresh=15)](https://badge.fury.io/rb/dsu)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/dsu/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/dsu/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

`dsu` is a [ruby gem](https://rubygems.org/gems/dsu) that enables anyone practicing the [Agile methodology](https://www.agilealliance.org/agile101/) to record, keep track of and manage their [daily standup (DSU)](https://www.agilealliance.org/glossary/daily-meeting/) activities.

- `dsu` uses _no_ network connections whatsoever.
- `dsu` stores all of its data _locally_, in .json files.
- `dsu` is a simple (but powerful) command-line tool for users who _love_ to work within the terminal.
- `dsu` versioning follows the [semantic versioning standard](https://semver.org/) (MAJOR.MINOR.PATCH).
  - See the [CHANGELOG.md](https://github.com/gangelo/dsu/blob/main/CHANGELOG.md) before upgrading to a MAJOR `dsu` version.
  - See the [Exporting DSU entries](https://github.com/gangelo/dsu/wiki/Exporting-DSU-entries) wiki on how to export (backup) your data.

# Installation
```shell
gem install dsu
```

# Documentation
The [dsu wiki](https://github.com/gangelo/dsu/wiki) is currently the gold standard for `dsu` documentation.

# Examples
* The [dsu wiki](https://github.com/gangelo/dsu/wiki) is repleat with practical examples on how to use `dsu`.
* Visit the [How I use dsu daily as an Agile developer](https://github.com/gangelo/dsu/wiki/How-I-use-dsu-daily-as-an-Agile-developer) wiki for examples of how _I_ use `dsu` on a daily basis.

# Supported ruby versions
`dsu` _should_ work with any ruby version `['>= 3.0.7', '< 4.0']`; however, `dsu` is currently tested against the ubuntu-latest, macos-latest and windows-latest platforms, using the following ruby versions:
- 3.0.7
- 3.1
- 3.2
- 3.3

Copyright (c) 2023-2024 Gene Angelo. See [LICENSE](https://github.com/gangelo/dsu/blob/main/LICENSE.txt) for details.
