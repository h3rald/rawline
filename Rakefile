#!/usr/bin/env ruby

require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"


Rake::TestTask.new do |test|
  test.libs       << "spec"
  test.test_files =  [ "spec/rawline_spec.rb" ]
  test.verbose    =  true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README.rdoc",
                           "CHANGELOG.rdoc",
                           "LICENSE", "lib/" )
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "RawLine Documentation"
end

spec = Gem::Specification.new do |s|
  s.name = %q{rawline}
  s.version = "0.3.1"
  s.date = %q{2009-03-07}
  s.summary = %q{A library for defining custom key bindings and perform line editing operations}
  s.email = %q{h3rald@h3rald.com}
  s.homepage = %q{http://rubyforge.org/projects/rawline}
  s.rubyforge_project = %q{rawline}
  s.description = %q{RawLine can be used to define custom key bindings, perform common line editing operations, manage command history and define custom command completion rules. }
  s.has_rdoc = true
  s.authors = ["Fabio Cevasco"]
  s.files = FileList["{lib}/**/*"].to_a+FileList["{examples}/*"].to_a+FileList["{spec}/*"].to_a+["README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
	s.test_file  = 'spec/rawline_spec.rb'  
	s.add_dependency("highline", ">= 1.4.0")
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.gem_spec = spec
  pkg.need_tar = true
	pkg.need_zip = true
end

