# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "facilbook/version"

Gem::Specification.new do |s|
  s.name        = "facilbook"
  s.version     = Facilbook::VERSION
  s.authors     = ["Eric Berry", "Brian Johnson"]
  s.email       = ["cavneb@gmail.com", "bjohnson@1on1.com"]
  s.homepage    = "https://github.com/cavneb/facilbook"
  s.summary     = "Simple (facil) Facebook helpers that allow for navigation"
  s.description = "Simple (facil) Facebook helpers that allow for navigation"

  s.rubyforge_project = "facilbook"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency "rails"
  s.add_development_dependency "rake"
end
