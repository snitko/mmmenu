# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mmmenu/version"

Gem::Specification.new do |s|
  s.name        = "mmmenu"
  s.version     = Mmmenu::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Roman Snitko"]
  s.email       = ["subscribe@snitko.ru"]
  s.homepage    = "https://github.com/snitko/mmmenu"
  s.summary     = %q{Flexible menu generator for Rails}
  s.description = %q{Flexible menu generator for Rails}

  s.rubyforge_project = "mmmenu"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-core", "~> 2.8.0"
end
