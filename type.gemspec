# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'type/version'

Gem::Specification.new do |spec|
  spec.name          = 'type'
  spec.version       = Type::VERSION
  spec.authors       = ['Ryan Biesemeyer']
  spec.email         = ['ryan@simplymeasured.com']
  spec.summary       = 'Type validation and Type casting'
  spec.description   = 'The `Type` gem provides tools for type-validation ' +
                       'and type-casting, and is useful for ensuring ' +
                       'well-formed messages are passed to external APIs/'
  spec.homepage      = 'https://github.com/simplymeasured/type-gem'
  spec.license       = 'Apache 2'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec',    '~> 2.14'
  spec.add_development_dependency 'ruby-appraiser-rubocop'
  spec.add_development_dependency 'ruby-appraiser-reek'
end
