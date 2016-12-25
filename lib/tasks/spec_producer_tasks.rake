namespace :spec_producer do
  desc 'Produces model specs files'
  task :models => :environment do
    SpecProducer.produce(only: :models)
  end
end

namespace :spec_producer do
  desc 'Produces controller specs files'
  task :controllers => :environment do
    SpecProducer.produce(only: :controllers)
  end
end

namespace :spec_producer do
  desc 'Produces route specs files'
  task :routes => :environment do
    SpecProducer.produce(only: :routes)
  end
end

namespace :spec_producer do
  desc 'Produces view specs files'
  task :views => :environment do
    SpecProducer.produce(only: :views)
  end
end

namespace :spec_producer do
  desc 'Produces helper specs files'
  task :helpers => :environment do
    SpecProducer.produce(only: :helpers)
  end
end

namespace :spec_producer do
  desc 'Produces mailer specs files'
  task :mailers => :environment do
    SpecProducer.produce(only: :mailers)
  end
end

namespace :spec_producer do
  desc 'Produces job specs files'
  task :jobs => :environment do
    SpecProducer.produce(only: :jobs)
  end
end

namespace :spec_producer do
  desc 'Produces serializer specs files'
  task :serializers => :environment do
    SpecProducer.produce(only: :serializers)
  end
end

namespace :spec_producer do
  desc 'Produces all spec files the current gem supports (currently only model specs)'
  task :all => :environment do
    SpecProducer.produce()
  end
end
