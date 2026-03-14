# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_load/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-load'
  spec.version       = Legion::Extensions::CognitiveLoad::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Load'
  spec.description   = "Sweller's Cognitive Load Theory modeled for brain-based agentic AI: " \
                       'intrinsic, extraneous, and germane load tracking with capacity management'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-load'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-load'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-load'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-load'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-load/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-cognitive-load.gemspec Gemfile LICENSE README.md]
  end
  spec.require_paths = ['lib']
end
