# frozen_string_literal: true

require_relative 'lib/legion/extensions/relevance_theory/version'

Gem::Specification.new do |spec|
  spec.name    = 'lex-relevance-theory'
  spec.version = Legion::Extensions::RelevanceTheory::VERSION
  spec.authors = ['Esity']
  spec.email   = ['matthewdiverson@gmail.com']

  spec.summary     = 'Sperber & Wilson relevance theory for LegionIO'
  spec.description = 'Evaluates cognitive inputs by relevance (effect/effort ratio). ' \
                     'High-effect low-effort inputs get attention; irrelevant inputs filtered. ' \
                     'Based on Sperber & Wilson (1986) Relevance Theory.'
  spec.homepage    = 'https://github.com/LegionIO/lex-relevance-theory'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-relevance-theory'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-relevance-theory'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-relevance-theory/blob/master/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-relevance-theory/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
end
