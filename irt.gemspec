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

  s.executables = ['irt', 'irt_irb', 'irt_rails2']
  s.files = `git ls-files -z`.split("\0") - %w[irt-tutorial.pdf]
  s.post_install_message = <<EOM
________________________________________________________________________________

                                IMPORTANT NOTES
________________________________________________________________________________

  1. If you notice a messed prompt while navigating the history, you must
     enable the 'fix_readline_prompt' option in the ~/.irtrc file:

        IRT.fix_readline_prompt = true

     (see the README file for details)

________________________________________________________________________________

  2. In order to use the IRT contextual ri command, one of the following gems
     must be installed:

       "bri"    if you run ruby >= 1.9.2
       "fastri" if you run ruby  < 1.9.2

________________________________________________________________________________

EOM
  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = ["README.markdown"]
  s.require_paths = ["lib"]

end
