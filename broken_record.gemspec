# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'broken_record/version'

Gem::Specification.new do |spec|
  spec.name          = 'broken_record'
  spec.version       = BrokenRecord::VERSION
  spec.authors       = ['Nicholas Gervasi']
  spec.email         = ['nick@zenpayroll.com']
  spec.description   = %q{Detects ActiveRecord models that are not valid.}
  spec.summary       = %q{Provides a rake task for scanning your ActiveRecord models and detecting validation errors.}
  spec.homepage      = 'https://github.com/nickgervasi/broken_record'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gemstash.zp-int.com/private'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.add_development_dependency 'bundler', '~> 2'

  spec.add_runtime_dependency 'rake', '>= 10.1.10'
  spec.add_runtime_dependency 'parallel', '>= 1.2.3'
  spec.add_runtime_dependency 'colorize', '>= 0.8.1'
  spec.add_runtime_dependency 'dogapi', '~> 1'
  spec.add_runtime_dependency 'bugsnag', '~> 6'
  spec.add_runtime_dependency 'bugsnag-capistrano', '~> 1.1', '>= 1.1.1'
end
