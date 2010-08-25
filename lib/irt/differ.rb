require 'differ'
module IRT
  class Differ
    class << self
      attr_accessor :classic
    end

    def initialize(expected, current, kind)
      unless classic?
        if kind == :value
          expected = IRT.yaml_dump expected
          current = IRT.yaml_dump current
        end
        @expected = expected.gsub(/^/, '  | ')
        @current = current.gsub(/^/, '  | ')
        @diff = ::Differ.diff_by_line(@current, @expected)
      else
        @expected = expected
        @current = current
      end
    end

    def classic?
      self.class.classic
    end

    def output
      classic? ? expected_current_block : differ_block
    end

  private

    def expected_current_block
      "expected: #{@expected}\ncurrent: #{@current}\n\n"
    end

    def differ_block
      x = IRT.colorize(:green, "-expected")
      g = IRT.colorize(:red, "+current")
      out = "diff: #{x} #{g}\n"
      out << @diff.format_as(IRT::Differ::Format) + "\n"
      out << "  | "
      out
    end

    module Format
      class << self
        def format(change)
         (change.change? && as_change(change)) ||
         (change.delete? && as_delete(change)) ||
         (change.insert? && as_insert(change)) ||
         ''
        end

        private
        def as_insert(change)
          IRT.colorize(:red, change.insert.gsub(/^(.)/,"+"))
        end

        def as_delete(change)
          IRT.colorize(:green, change.delete.gsub(/^(.)/,"-"))
        end

        def as_change(change)
          as_delete(change) << "\n" + as_insert(change)
        end
      end
    end

  end
end

