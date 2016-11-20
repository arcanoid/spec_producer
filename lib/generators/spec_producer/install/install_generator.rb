module SpecProducer
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Adds spec_generator in bin/ folder"
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def copy_executable
        template "spec_producer", "bin/spec_producer.rb"
      end
    end

  end
end
