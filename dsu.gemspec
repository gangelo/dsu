# frozen_string_literal: true

require_relative 'lib/dsu/version'

Gem::Specification.new do |spec|
  spec.name = 'dsu'
  spec.version = Dsu::VERSION

  spec.authors      = ['Gene M. Angelo, Jr.']
  spec.email        = ['public.gma@gmail.com']

  spec.summary      = 'dsu (Agile Daily Stand Up/DSU) mini-manager.'
  spec.description  = <<-DESC
    dsu is ruby gem that enables anyone practicing Agile methodology to record, keep track of, and manage their daily standup (DSU) activities.

    * dsu uses no network connections whatsoever.
    * dsu stores all of its data locally, in .json files.
    * dsu is a simple (but powerful) command-line tool for users who love to work within the terminal.
    * dsu versioning follows the semantic versioning standard (MAJOR.MINOR.PATCH).
  DESC
  spec.homepage = 'https://github.com/gangelo/dsu'
  spec.license = 'MIT'
  spec.required_ruby_version = ['>= 3.0.1', '< 4.0']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = 'https://github.com/gangelo/dsu/wiki'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/gangelo/dsu/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 7.0.8', '< 8.0'
  spec.add_dependency 'activemodel', '>= 7.0.8', '< 8.0'
  spec.add_dependency 'colorize', '>= 1.1', '< 2.0'
  spec.add_dependency 'os', '>= 1.1', '< 2.0'
  spec.add_dependency 'thor', '>= 1.2', '< 2.0'
  spec.add_dependency 'thor_nested_subcommand', '>= 1.0', '< 2.0'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.post_install_message = <<~POST_INSTALL
    Thank you for installing dsu.

    Run `dsu` from your command line to get started.

    View the dsu README.md here: https://github.com/gangelo/dsu
    View the dsu CHANGELOG.md: https://github.com/gangelo/dsu/blob/main/CHANGELOG.md

                *
               ***
             *******
            *********
     ***********************
        *****************
          *************
         ******* *******
        *****       *****
       ***             ***
      **                 **

    Using dsu? dsu is made available free of charge. Please consider giving dsu a STAR on GitHub as well as sharing dsu with your fellow developers on social media.

    Knowing that dsu is being used and appreciated is a great motivator to continue developing and improving dsu.

    >>> Star it on github: https://github.com/gangelo/dsu
    >>> Share on social media: https://rubygems.org/gems/dsu

    Thank you!

    <3 Gene
  POST_INSTALL
end
