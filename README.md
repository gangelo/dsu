# `dsu`

[![Ruby](https://github.com/gangelo/dsu/actions/workflows/ruby.yml/badge.svg)](https://github.com/gangelo/dsu/actions/workflows/ruby.yml)
[![GitHub version](http://badge.fury.io/gh/gangelo%2Fdsu.svg?refresh=9)](https://badge.fury.io/gh/gangelo%2Fdsu)
[![Gem Version](https://badge.fury.io/rb/dsu.svg?refresh=9)](https://badge.fury.io/rb/dsu)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/dsu/)
[![Report Issues](https://img.shields.io/badge/report-issues-red.svg)](https://github.com/gangelo/dsu/issues)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

`dsu` is a [ruby gem](https://rubygems.org/gems/dsu) that enables anyone practicing [Agile methodology](https://www.agilealliance.org/agile101/) to record, keep track of and manage their [daily standup (DSU)](https://www.agilealliance.org/glossary/daily-meeting/) activities.

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
[https://github.com/gangelo/dsu/wiki](https://github.com/gangelo/dsu/wiki)

# Examples
The [dsu wiki](https://github.com/gangelo/dsu/wiki) is repleat with practical examples on how to use `dsu`.

It you're interested in how _I personally_ use `dsu` every day, I blog about it [here](https://genemangelojr.blogspot.com/2024/01/the-dsu-ruby-gem-workflow-how-to-use-it.html).

# Supported ruby versions
`dsu` _should_ work with any ruby version `['>= 3.0.1', '< 4.0']`; however, `dsu` is currently tested against the following ruby versions:
- 3.0.1
- 3.0.6
- 3.1.4
- 3.2.2

Copyright (c) 2023-2024 Erik Gene Angelo. See [LICENSE](https://github.com/gangelo/dsu/blob/main/LICENSE.txt) for details.
