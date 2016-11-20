module SpecProducer
  module RspecText
    module Literals

      class SpecBegin < String
        def to_s
          @require_helper_string ||= Utils::FileUtils.collect_helper_strings
        end
      end

      class Describe < String
      end

      class Subject < String
      end

      class It < String
      end

      class Expect < String
      end

      class SpecEnd < String
        def to_s
          "end"
        end
      end
    end
  end
end
