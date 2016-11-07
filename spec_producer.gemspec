# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spec_producer/version'

Gem::Specification.new do |spec|
  spec.name          = "spec_producer"
  spec.version       = SpecProducer::VERSION
  spec.authors       = ["Vasilis Kalligas"]
  spec.email         = ["billkall@gmail.com"]

  spec.summary       = %q{This gem can be used in Rails apps to automatically generate rspec tests and files}
  spec.description   = %q{This gem reads through the files of the rails app and produces as many specs as possible.}
  spec.homepage      = "https://rubygems.org/gems/spec_producer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.executables   = [ "produce_specs" ]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "colorize"
end
