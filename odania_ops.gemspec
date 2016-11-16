# -*- encoding: utf-8 -*-
require File.expand_path('../lib/odania_ops/version', __FILE__)

Gem::Specification.new do |gem|
	gem.authors       = ['Mike Petersen']
	gem.email         = ['mike@odania-it.com']
	gem.description   = %q{Ops tools for managing servers}
	gem.summary       = %q{Ops tools for managing servers}
	gem.homepage      = 'http://www.odania.com/ops-tools'

	gem.files         = `git ls-files`.split($\)
	gem.executables   = %w(ops odania-ops)
	gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
	gem.name          = 'odania_ops'
	gem.require_paths = ['lib']
	gem.version       = OdaniaOps::VERSION
	gem.license       = 'MIT'

	gem.add_dependency 'activesupport'
	gem.add_dependency 'deep_merge'
	gem.add_dependency 'docker-api'
	gem.add_dependency 'erubis'
	gem.add_dependency 'httparty'
	gem.add_dependency 'thor'
	gem.add_dependency 'sshkit'
	gem.add_dependency 'bigdecimal'
end
