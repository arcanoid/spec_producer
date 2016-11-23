namespace :spec_producer do
  desc 'Produces model specs files'
  task :models => :environment do
    SpecProducer.produce(only: :models)
  end
end

namespace :spec_producer do
  desc 'Produces all spec files the current gem supports (currently only model specs)'
  task :all => :environment do
    SpecProducer.produce()
  end
end

