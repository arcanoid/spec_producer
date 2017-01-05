namespace :spec_producer do
  desc 'Produces controller specs files'
  task :controllers => :environment do
    SpecProducer.produce(only: :controllers)
  end

  desc 'Produces FactoryGirl factory files for each model'
  task :factories => :environment do
    SpecProducer.produce_factories
  end

  desc 'Produces helper specs files'
  task :helpers => :environment do
    SpecProducer.produce(only: :helpers)
  end

  desc 'Produces job specs files'
  task :jobs => :environment do
    SpecProducer.produce(only: :jobs)
  end

  desc 'Produces mailer specs files'
  task :mailers => :environment do
    SpecProducer.produce(only: :mailers)
  end

  desc 'Produces model specs files'
  task :models => :environment do
    SpecProducer.produce(only: :models)
  end

  desc 'Produces route specs files'
  task :routes => :environment do
    SpecProducer.produce(only: :routes)
  end

  desc 'Produces serializer specs files'
  task :serializers => :environment do
    SpecProducer.produce(only: :serializers)
  end

  desc 'Produces view specs files'
  task :views => :environment do
    SpecProducer.produce(only: :views)
  end

  desc 'Produces all spec files the current gem supports'
  task :all => :environment do
    SpecProducer.produce()
  end
end

namespace :missing_specs_printer do
  desc 'Prints missing view spec files'
  task :views => :environment do
    SpecProducer.print_missing_view_specs()
  end

  desc 'Prints missing controller spec files'
  task :controllers => :environment do
    SpecProducer.print_missing_controller_specs()
  end

  desc 'Prints missing job spec files'
  task :jobs => :environment do
    SpecProducer.print_missing_job_specs()
  end

  desc 'Prints missing helper spec files'
  task :helpers => :environment do
    SpecProducer.print_missing_helper_specs()
  end

  desc 'Prints missing mailer spec files'
  task :mailers => :environment do
    SpecProducer.print_missing_mailer_specs()
  end

  desc 'Prints missing model spec files'
  task :models => :environment do
    SpecProducer.print_missing_model_specs()
  end

  desc 'Prints missing route spec files'
  task :routes => :environment do
    SpecProducer.print_missing_route_specs()
  end

  desc 'Prints missing serializer spec files'
  task :serializers => :environment do
    SpecProducer.print_missing_serializer_specs()
  end

  desc 'Prints all types of missing spec files'
  task :all => :environment do
    SpecProducer.print_all_missing_spec_files()
  end
end