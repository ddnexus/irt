name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ["Domizio Demichelis"]
  s.email = 'dd.nexus@gmail.com'
  s.homepage = 'http://github.com/ddnexus/irt'
  s.summary = 'Interactive Ruby Testing - Use irb or rails console for testing.'
  s.description = 'IRT records and rerun the steps of your interactive irb or rails console session, ignoring the inspecting commands and reporting test diffs.'

  s.add_runtime_dependency('differ', [">= 0.1.1"])
  s.add_runtime_dependency('colorer', [">= 0.5.0"])

  s.executables = ["irt"]
  s.files = `git ls-files -z`.split("\0") - %w[irt-tutorial.pdf]

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end
