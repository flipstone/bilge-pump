# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bilge-pump/version"

Gem::Specification.new do |s|
  s.name        = "bilge-pump"
  s.version     = Bilge::Pump::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Vollbracht"]
  s.email       = ["david@flipstone.com"]
  s.homepage    = "http://github.com/flipstone/bilge-pump"
  s.summary     = %q{Let bilge-pump remove the crud from your controllers}
  s.description = %q{bilge pump provides modules and testing for rails resource style crud controllers.
Bilge pump was extracted from Flipstone projects.}

  s.rubyforge_project = "bilge-pump"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
