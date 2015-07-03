# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rawline"
  s.version = "0.3.2"
  s.summary = %q{A library for defining custom key bindings and perform line editing operations}
  s.description = %q{RawLine can be used to define custom key bindings, perform common line editing operations, manage command history and define custom command completion rules. }
  s.email = %q{h3rald@h3rald.com}
  s.homepage = %q{http://rubyforge.org/projects/rawline}
  s.authors = ["Fabio Cevasco"]
  s.date = "2013-07-14"
  s.license = "MIT"
  s.authors = ["Fabio Cevasco"]
  s.files = Dir.glob("lib/**/*")
  s.files += Dir.glob("examples/*")
  s.files += Dir.glob("spec/*")
  s.files += ["README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
	s.add_runtime_dependency("highline", [">= 1.7.2"])
  s.add_development_dependency("rspec", ["~> 3.0"])
end
