require_relative './literals'
module SpecProducer
  module RspecText
    class Base
      include Builder
      include Literals

      attr_reader :_text

      def initialize(t = "")
        @_text = t.to_s
        yield self if block_given?
      end

      # ins.add("some").with_2_spaces
      def method_missing(method_sym, *args, &block)
        if method_sym.to_s =~ /^with_(\d+)_lines?$/
          add("\n" * $1.to_i) if $1.to_i > 0
          self
        else
          super
        end
      end

      def respond_to?(name)
        if name =~ /with_\d+_spaces/
          true
        else
          super
        end
      end

      def add(text)
        _text << text
        self
      end
      alias_method :<<, :add
      alias_method :append, :add

      def flush!
        @_text = ""
      end

      def start_spec(resource)
      end

      def finish_spec(resource)
        Utils::FileUtils.try_to_create_spec_file(resource.type, resource.name.underscore, self)
        self.flush!
      end

      def +(other)
        self.to_s + other.to_s
      end

      def tab
        add "  "
      end

      def new_line
        add "\n"
      end

      def expectation(model, match, match_key, footer=nil)
        res = "it { is_expected.to #{match}(:#{match_key})#{footer} }"
      end

      def to_s
        _text
      end

      def inspect
        to_s
      end

    end
  end
end
