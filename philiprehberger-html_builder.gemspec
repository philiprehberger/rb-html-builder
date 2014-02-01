# frozen_string_literal: true

require_relative 'lib/philiprehberger/html_builder/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-html_builder'
  spec.version       = Philiprehberger::HtmlBuilder::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Programmatic HTML builder with tag DSL and auto-escaping'
  spec.description   = 'Build HTML programmatically using a clean tag DSL with nested blocks, ' \
                       'automatic content escaping, void element support, and attribute hashes.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-html-builder'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
