# coding: utf-8
require './lib/multisax'

Gem::Specification.new do |spec|
  spec.name          = "multisax"
  spec.version       = MultiSAX::VERSION
  spec.authors       = ["cielavenir"]
  spec.email         = ["cielartisan@gmail.com"]
  spec.description   = "Ruby Gem to handle multiple SAX libraries: ox/libxml/nokogiri/xmlparser(expat)/oga/rexml"
  spec.summary       = "Ruby Gem to handle multiple SAX libraries"
  spec.homepage      = "http://github.com/cielavenir/multisax"
  spec.license       = "Ruby License (2-clause BSDL or Artistic)"

  spec.files         = `git ls-files`.split($/) + [
    "LICENSE.txt",
    "README.md",
    "CHANGELOG.md",
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.requirements << "Optional dependencies: ox, libxml-ruby, nokogiri, xmlparser, oga"
end
