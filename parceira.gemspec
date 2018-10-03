# frozen_string_literal: true

require File.expand_path('lib/parceira/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['Marcos G. Zimmermann']
  gem.email         = ['mgzmaster@gmail.com']
  gem.description   = 'Importing of CSV Files as Array(s) of Hashes with featured to process large csv files and better support for file encoding.'
  gem.summary       = 'Importing of CSV Files as Array(s) of Hashes'
  gem.homepage      = 'http://github.com/marcosgz/parceira'
  gem.license       = 'MIT'

  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.add_dependency 'activesupport', '>= 2.3.4'
  gem.add_dependency 'i18n'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'parceira'
  gem.require_paths = ['lib']
  gem.version       = Parceira::VERSION
end
