# frozen_string_literal: true

require_relative 'lib/dsu/version'

Gem::Specification.new do |spec|
  spec.name = 'dsu'
  spec.version = Dsu::VERSION

  spec.authors      = ['Gene M. Angelo, Jr.']
  spec.email        = ['public.gma@gmail.com']

  spec.summary      = 'dsu (Agile Daily Stand Up/DSU) mini-manager.'
  spec.description  = <<-DESC
    dsu is little gem that helps manage your Agile DSU (Daily Stand Up) participation. How? by providing a simple command line interface (CLI) which allows you to create, read, update, and delete (CRUD) noteworthy activities that you performed during your day. During your DSU, you can then easily recall and share these these activities with your team. Activities are grouped by day and can be viewed in simple text format from the command line. When displaying DSU entries for a particular day or date (date), dsu will display the given day or date's (date) DSU entries, as well as the DSU entries for the previous day, relative to the given day or date. If the date or day you are trying to view falls on a weekend or Monday, dsu will display back to, and including the weekend and previous Friday inclusive; this is so that you can share what you did over the weekend (if anything) and the previous Friday at your DSU.
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

  spec.add_dependency 'activesupport', '~> 7.0', '>= 7.0.4'
  spec.add_dependency 'activemodel', '~> 7.0', '>= 7.0.4.3'
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'os', '~> 1.1', '>= 1.1.4'
  spec.add_dependency 'thor', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'thor_nested_subcommand', '~> 1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
