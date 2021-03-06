require 'date'
require File.expand_path('../lib/irt/ruby_version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name                      = 'irt'
  s.authors                   = ["Domizio Demichelis"]
  s.email                     = 'dd.nexus@gmail.com'
  s.homepage                  = 'http://github.com/ddnexus/irt'
  s.summary                   = 'Interactive Ruby Tools - Very improved irb and Rails Console with a lot of cool features.'
  s.description               = 'If you use IRT in place of irb or Rails Console, you will have more tools that will make your life a lot easier.'
  s.executables               = ['irt', 'irt_irb', 'irt_rails2']
  s.extra_rdoc_files          = ["README.markdown"]
  s.require_paths             = ["lib"]
  s.files                     = `git ls-files -z`.split("\0") - %w[irt-tutorial.pdf]
  s.version                   = File.read(File.expand_path('../VERSION', __FILE__)).strip
  s.date                      = Date.today.to_s
  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options              = ["--charset=UTF-8"]
  s.post_install_message      = <<EOM
________________________________________________________________________________

                              IRT IMPORTANT NOTES
________________________________________________________________________________

  1. If you notice a messed prompt while navigating the history, you must
     enable the 'fix_readline_prompt' option in the ~/.irtrc file:

        IRT.fix_readline_prompt = true

     (see the README file for details)

________________________________________________________________________________

  2. In order to use the IRT contextual ri command, on ruby < 1.9.3,
     one of the following gems must be installed:

       "bri"    if you run ruby >= 1.9.2
       "fastri" if you run ruby  < 1.9.2

     (no extra installation needed if you use ruby >= 1.9.3)
________________________________________________________________________________

EOM
  s.add_runtime_dependency('differ', [">= 0.1.1"])
  s.add_runtime_dependency('prompter', [">= 0.1.5"])
end
