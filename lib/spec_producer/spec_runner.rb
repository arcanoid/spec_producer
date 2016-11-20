module SpecProducer
  module SpecRunner
    module_function

    def run(spec_types = [])
      puts "\nRunning related spec tests...\n"

      system 'bundle exec rake' if spec_types.empty?
      spec_types.each do |type|
        system "bundle exec rspec spec/#{type}"
      end
    end
  end
end
