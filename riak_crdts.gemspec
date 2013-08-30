# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riak_crdts/version'

Gem::Specification.new do |gem|
  gem.name          = "riak_crdts"
  gem.version       = RiakCrdts::VERSION
  gem.authors       = ["Dan Kerrigan", "Drew Kerrigan"]
  gem.email         = ["dankerrigan@basho.com", "dkerrigan@basho.com"]
  gem.description   = "CRDTs implemented using Riak"
  gem.summary       = "CRDTs implemented using Riak"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'debugger'

  gem.add_runtime_dependency 'riak-client'
end
