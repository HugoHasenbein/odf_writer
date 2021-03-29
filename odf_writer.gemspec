# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "odf_writer/version"

Gem::Specification.new do |s|
  s.name = %q{odf_writer}
  s.version = ODFWriter::VERSION

  s.authors = ["Stephan Wenzel"]
  s.description = %q{Generates ODF files, given a template (.odt) and data, replacing tags. Based on odf-report gem}
  s.email = %q{stephan.wenzel@drwpatent.de}
  s.homepage = %q{https://github.com/HugoHasenbein/odf_writer}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Generates ODF files, given a template (.odt) and data, replacing tags. Based on odf-report gem}

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "faker"
  s.add_development_dependency "launchy"

  s.add_runtime_dependency('rubyzip', "~> 1.2.0")
  s.add_runtime_dependency('nokogiri', ">= 1.5.0")

end
