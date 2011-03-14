name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'
require File.expand_path('../lib/irt/ruby_version.rb', __FILE__)

Gem::Specification.new do |s|

  s.authors = ["Domizio Demichelis"]
  s.email = 'dd.nexus@gmail.com'
  s.homepage = 'http://github.com/ddnexus/irt'
  s.summary = 'Interactive Ruby Tools - Very improved irb and Rails Console with a lot of cool features.'
  s.description = 'If you use IRT in place of irb or Rails Console, you will have more tools that will make your life a lot easier.'

  s.add_runtime_dependency('differ', [">= 0.1.1"])
  s.add_runtime_dependency('dye', [">= 0.1.3"])
  s.add_runtime_dependency('prompter', [">= 0.1.4"])
  s.requirements << "In order to use the IRT contextual ri command you must install the gem 'bri' (ruby >=1.9.2) or 'fastri' (ruby < 1.9.2)"

  s.executables = ['irt', 'irt_irb', 'irt_rails2']
  s.files = `git ls-files -z`.split("\0") - %w[irt-tutorial.pdf]
  s.post_install_message = <<EOM

********************************************************************************

  In order to use the IRT contextual ri command you must also install the gem:
  "bri"    if you run ruby >= 1.9.2
  "fastri" if you run ruby  < 1.9.2

********************************************************************************

EOM
  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = ["README.markdown"]
  s.require_paths = ["lib"]

end
