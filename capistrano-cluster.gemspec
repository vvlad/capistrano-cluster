# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/cluster/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-cluster"
  spec.version       = Capistrano::Cluster::VERSION
  spec.authors       = ["Vlad Verestiuc"]
  spec.email         = ["verestiuc.vlad@gmail.com"]
  spec.summary       = %q{Environment setup automation.}
  spec.description   = %q{Setup tasks and role additions for capistrano}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency "capistrano"
  spec.add_dependency "capistrano-rails"
  spec.add_dependency "capistrano-bundler"
  spec.add_dependency "nokogiri"

end
