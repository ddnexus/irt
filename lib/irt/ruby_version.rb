module IRT
  module RubyVersion

    class Version < Array
      include Comparable

      def initialize(version)
        replace version.split('.').map(&:to_i)
      end
    end

    extend self

    [:>, :>=, :<, :<=, :==, :between?].each do |m|
      define_method(m) do |*args|
        vers = args.map{|a| Version.new(a)}
        Version.new(RUBY_VERSION).send m, *vers
      end
    end

  end
end
