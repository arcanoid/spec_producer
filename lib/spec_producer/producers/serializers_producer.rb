require 'active_model_serializers'

module SpecProducer
  module Producers
    class SerializersProducer
      prepend Base

      # TODO Rethink this
      CLASSES_TO_IGNORE = [ 'ActiveModel::Serializer::ErrorSerializer' ]

      def resources
      	ActiveModel::Serializer.descendants.reject do |descendant|
          should_ignore?(descendant)
        end.map { |desc| Resource.new(desc, desc.name, 'serializer') }
      end

      def call(resource)
        builder.context('includes the expected attribute keys') do
          builder.subject(builder.initialize_serializer_for_object resource.obj)

          builder.it("expect(subject.attributes.keys).to contain_exactly(#{resource.obj._attributes.map { |x| ":#{x.to_s}" }.join(', ')})")
        end

        builder.context('to_json') do
          builder.subject(builder.json_parse_for_serialized_object resource.obj)

          resource.obj._attributes.each do |attribute|
            builder.it("expect(subject['#{attribute}']).to eq('')")
          end
        end
      end

      #######
      private
      #######

      def should_ignore?(descendant)
        CLASSES_TO_IGNORE.include?(descendant.to_s)
      end

      def require_helper_string
        @require_helper_string ||= Utils::FileUtils.collect_helper_strings
      end
    end
  end
end