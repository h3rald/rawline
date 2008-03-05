#!/usr/bin/env ruby

require 'rake/gempackagetask'
 
spec = Gem::Specification.new do |s|
  s.name = %q{inline}
  s.version = "1.0.0"
  s.date = %q{2008-3-15}
  s.summary = %q{A library for definign custom key bindings and perform line editing operations}
  s.email = %q{h3rald@h3rald.com}
  s.homepage = %q{http://rubyforge.org/projects/inline}
  s.rubyforge_project = %q{inline}
  s.description = %q{InLine can be used to define custom key bindings, perform common line editing operations, manage command history and define custom command completion rules. }
  #s.has_rdoc = true
  s.authors = ["Fabio Cevasco"]
  s.files = FileList["{lib}/**/*"].to_a #+["README.txt", "LICENSE.txt", "CHANGES.txt"]
  #s.rdoc_options = ["--main", "README.txt"]
  #s.extra_rdoc_files = ["README.txt", "LICENSE.txt", "CHANGES.txt"]
	s.test_file  = 'test/test_all.rb'  
	s.add_dependency("highline", ">= 1.4.0")
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.gem_spec = spec
  pkg.need_tar = true
	pkg.need_zip = true
end

