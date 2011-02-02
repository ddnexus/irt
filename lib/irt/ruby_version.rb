module IRT
  module RubyVersion

    extend self

    class Version < Array
      include Comparable

       def initialize(version=RUBY_VERSION)
         replace version.split('.').map(&:to_i)
       end
    end

    [:>, :>=, :<, :<=, :==, :between?].each do |m|
      define_method(m) do |*args|
        vers = args.map{|a| Version.new(a)}
        Version.new.send m, *vers
      end
    end

  end
end
