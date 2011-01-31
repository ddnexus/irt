require 'differ'
module IRT
  class Differ

    def initialize(a, b, kind=:value, options={})
      if kind == :value
        a = IRT.yaml_dump a
        b = IRT.yaml_dump b
      end
      @a = a
      @b = b
      @options = { :a_label  => 'saved',
                   :b_label  => 'actual',
                   :a_marker => '~',
                   :b_marker => '!' }.merge options
      IRT::Differ::Format.options = @options
      @diff = ::Differ.diff_by_line(@b, @a)
    end

    def output
      out = "\n"
      out << IRT.dye(' = same ', :reversed, :bold)
      a = "#{@options[:a_marker]} #{@options[:a_label]}"
      out << IRT.dye(" #{a} ", " (#{a}) ", :diff_a_color, :reversed, :bold)
      b = "#{@options[:b_marker]} #{@options[:b_label]}"
      out << IRT.dye(" #{b} ", " (#{b}) ", :diff_b_color, :reversed, :bold)
      out << "\n"
      diff = @diff.format_as(IRT::Differ::Format)
      out << diff.sub(/^\n/,'')
      out << "\n"
      out
    end

    module Format
      extend self

      attr_accessor :options

      def format(change)
       (change.is_a?(String) && as_same(change)) ||
       (change.change? && as_change(change)) ||
       (change.delete? && as_delete(change)) ||
       (change.insert? && as_insert(change)) ||
       ''
      end

      private

      def process(string, mark='=', color=:null, bold=:null)
        string.sub(/^\n/,'').split("\n").map do |s|
          IRT.dye(" #{mark} ", " #{mark} |", color, :bold, :reversed) + ' ' + IRT.dye(s, color)
        end.join("\n") + "\n"
      end

      def as_same(string)
        process string
      end

      def as_insert(change)
        process(change.insert(), options[:b_marker], :diff_b_color, :bold)
      end

      def as_delete(change)
        process(change.delete(), options[:a_marker], :diff_a_color, :bold)
      end

      def as_change(change)
        as_delete(change) << as_insert(change)
      end
    end

  end
end

module Differ
  class Diff

    def format_as(f)
      f = Differ.format_for(f)
      @raw.inject('') do |sum, part|
        part = f.format(part)
        sum << part
      end
    end

  end
end
