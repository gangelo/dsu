# frozen_string_literal: true

require_relative 'lib/dsu/version'

Gem::Specification.new do |spec|
  spec.name = 'dsu'
  spec.version = Dsu::VERSION

  spec.authors      = ['Gene M. Angelo, Jr.']
  spec.email        = ['public.gma@gmail.com']

  spec.summary      = 'dsu (Agile Daily Stand Up/DSU) mini-manager.'
  spec.description  = <<-DESC
    dsu is a small, but powerful gem that helps manage your Agile DSU (Daily Stand Up) participation. How? by providing a simple command-line interface (CLI) which allows you to create, read, update, and delete (CRUD) your DSU entries (activities). During your DSU, you can use dsu's CLI to list and share what you did "yesterday" and what you plan on doing "Today" with your team. DSU entries are grouped by day and can be viewed in simple text format from the command-line. When displaying DSU entries for a particular day, dsu will also display DSU entries for the previous day. If the day you are trying to display falls on a weekend or Monday, dsu will automatically search back to include the weekend and previous Friday dates and display the entries; this is so that you can share what you did over the weekend (if anything) and the previous Friday with your team. When searching for "Yesterday's" DSU entries, dsu will automatically search back a maximimum of 7 days to find DSU entries to share. This could be helpful if, for example, if you are sharing what you plan to do today (Wednesday), but were sick yesterday (Tuesday); dsu in this case will display the last DSU entries it can find searching backwards a maximum of 7 days. dsu does a LOT more and is perfect for command-line junkies and those who LOVE simplicity. Give it a try and a star if you like it!
  DESC
  spec.homepage = 'https://github.com/gangelo/dsu'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.1'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
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

  spec.add_dependency 'activesupport', '>= 7.0.8', '< 7.2.0'
  spec.add_dependency 'activemodel', '~> 7.0', '>= 7.0.4.3'
  spec.add_dependency 'colorize', '>= 0.8.1', '< 1.2.0'
  spec.add_dependency 'os', '~> 1.1', '>= 1.1.4'
  spec.add_dependency 'thor', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'thor_nested_subcommand', '~> 1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.post_install_message = <<~POST_INSTALL
    Thank you for installing dsu.

    Run `dsu` from your command line to get started.

    View the dsu README.md here: https://github.com/gangelo/dsu
    View the dsu CHANGELOG.md: https://github.com/gangelo/dsu/blob/main/CHANGELOG.md

    Try a dsu theme by running `dsu theme list` and then `dsu theme use THEME_NAME` where THEME_NAME is the name of the theme you want to try :)
  POST_INSTALL
end
