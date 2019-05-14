# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'fints/version'

Gem::Specification.new do |s|
  s.name        = 'ruby_fints'
  s.version     = FinTS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Marvin Killing']
  s.email       = ['marvin@playtestcloud.com']
  s.homepage    = ''
  s.summary     = %q{Basic FinTS 3.0 implementation in Ruby}
  s.description = %q{FinTS (formerly known as HBCI) is a protocol to programmatically interface with German banks. This gem is a translation of https://github.com/raphaelm/python-fints into Ruby.}

  s.add_runtime_dependency 'cmxl'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'delorean'
  s.add_development_dependency 'mocha'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ['lib']
end
