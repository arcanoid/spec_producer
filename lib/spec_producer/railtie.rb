require 'rails'

module SpecProducer
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'tasks/spec_producer_tasks.rake'
    end

    initializer 'spec_producer.initialization' do
      Rails.application.eager_load!
    end
  end
end
