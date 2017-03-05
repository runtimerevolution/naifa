# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'naifa/version'

Gem::Specification.new do |spec|
  spec.name          = "naifa"
  spec.version       = Naifa::VERSION
  spec.authors       = ["Filipe Dias"]
  spec.email         = ["f.dias@runtime-revolution.com"]

  spec.summary       = %q{Naifa is a portuguese street knife that with a little tools that will help in your day to day web development}
  spec.description   = %q{Naifa is a portuguese street knife that with a little tools that will help in your day to day web development}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-nav", "~> 0.2.4"
  spec.add_dependency "activesupport", ">= 4"
  spec.add_dependency "thor", "~> 0.19"
end
