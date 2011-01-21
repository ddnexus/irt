name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ["Domizio Demichelis"]
  s.email = 'dd.nexus@gmail.com'
  s.homepage = 'http://github.com/ddnexus/irt'
  s.summary = 'Interactive Ruby Testing - Use an improved irb / rails console for testing.'
  s.description = 'If you use IRT in place of irb, you will have all the regular irb/rails console features, plus a lot more.'

  s.add_runtime_dependency('differ', [">= 0.1.1"])
  s.add_runtime_dependency('colorer', [">= 0.7.0"])

  s.executables = ["irt", "irt_rails2"]
  s.files = `git ls-files -z`.split("\0") - %w[irt-tutorial.pdf]

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end
