name = 'irt'

def ensure_clean(action, force=false)
  if !force && ! `git status -s`.empty?
    puts <<-EOS.gsub(/^ {6}/, '')
      Rake task aborted: the working tree is dirty!
      If you know what you are doing you can use \`rake #{action}[force]\`"
    EOS
    exit(1)
  end
end

desc "Install the gem"
task :install, :force do |t, args|
  ensure_clean(:install, args.force)
  orig_version = version = File.read('VERSION').strip
  begin
    commit_id = `git log -1 --format="%h" HEAD`.strip
    version = "#{orig_version}.#{commit_id}"
    File.open('VERSION', 'w') {|f| f.puts version }
    gem_name = "#{name}-#{version}.gem"
    sh %(gem build #{name}.gemspec)
    sh %(gem install #{gem_name} --local)
    puts <<-EOS.gsub(/^ {6}/, '')

      *******************************************************************************
      *                                   NOTICE                                    *
      *******************************************************************************
      * The version id of locally installed gems is comparable to a --pre version:  *
      * i.e. it is alphabetically ordered (not numerically ordered), besides it     *
      * includes the sah1 commit id which is not aphabetically ordered, so be sure  *
      * your application picks the version you really intend to use                 *
      *******************************************************************************

    EOS
  ensure
    remove_entry_secure gem_name, true
    File.open('VERSION', 'w') {|f| f.puts orig_version }
  end
end

desc %(Remove all the "#{name}" installed gems and executables and install this version)
task :clean_install, :force do |t, args|
  ensure_clean(:install, args.force)
  sh %(gem uninstall #{name} --all --ignore-dependencies --executables)
  Rake::Task['install'].invoke(args.force)
end

desc "Push the gem to rubygems.org"
task :push, :force do |t, args|
  begin
    ensure_clean(:push, args.force)
    version = File.read('VERSION').strip
    gem_name = "#{name}-#{version}.gem"
    sh %(gem build #{name}.gemspec)
    sh %(gem push #{gem_name})
  ensure
    remove_entry_secure gem_name, true
  end
end
