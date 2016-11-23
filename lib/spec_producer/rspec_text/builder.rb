module SpecProducer
  module RspecText
    module Builder
      def self.included(base)
        base.include InstanceMethods
        base.extend ClassMethods
      end

      # begin_new_spec(resource) do
      #   
      # end
      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
