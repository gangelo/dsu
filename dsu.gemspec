# frozen_string_literal: true

require_relative 'lib/dsu/version'

Gem::Specification.new do |spec|
  spec.name = 'dsu'
  spec.version = Dsu::VERSION

  spec.authors      = ['Gene M. Angelo, Jr.']
  spec.email        = ['public.gma@gmail.com']

  spec.summary      = 'Daily Stand Up (DSU) mini-manager.'
  spec.description  = <<-DESC
    dsu is little gem that helps me manage my dsu participation.
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
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'deco_lite', '~> 1.3'
  spec.add_dependency 'os', '~> 1.1', '>= 1.1.4'
  spec.add_dependency 'thor', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'thor_nested_subcommand', '~> 1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
