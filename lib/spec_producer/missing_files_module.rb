require 'colorize'

module SpecProducer::MissingFilesModule
  def self.print_missing_model_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/models/**/#{options[:specific_namespace].gsub('app/models', '')}/**/*.rb"]
    else
      files_list = Dir["app/models/**/*.rb"]
    end

    puts "\n" << "## Searching for missing model specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb')) }

    missing.each do |file|
      puts "Missing model spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing model spec files found!".colorize(:green)
    end
  end

  def self.print_missing_controller_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/controllers/**/#{options[:specific_namespace].gsub('app/controllers', '')}/**/*.rb"]
    else
      files_list = Dir["app/controllers/**/*.rb"]
    end

    puts "\n" << "## Searching for missing controller specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb')) }

    missing.each do |file|
      puts "Missing controller spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing controller spec files found!".colorize(:green)
    end
  end

  def self.print_missing_job_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/jobs/**/#{options[:specific_namespace].gsub('app/jobs', '')}/**/*.rb"]
    else
      files_list = Dir["app/jobs/**/*.rb"]
    end

    puts "\n" << "## Searching for missing jobs specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb')) }

    missing.each do |file|
      puts "Missing job spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing job spec files found!".colorize(:green)
    end
  end

  def self.print_missing_mailer_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/mailers/**/#{options[:specific_namespace].gsub('app/mailers', '')}/**/*.rb"]
    else
      files_list = Dir["app/mailers/**/*.rb"]
    end

    puts "\n" << "## Searching for missing mailers specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb')) }

    missing.each do |file|
      puts "Missing mailer spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing mailer spec files found!".colorize(:green)
    end
  end

  def self.print_missing_helper_specs(options = {})(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/helpers/**/#{options[:specific_namespace].gsub('app/helpers', '')}/**/*.rb"]
    else
      files_list = Dir["app/helpers/**/*.rb"]
    end

    puts "\n" << "## Searching for missing helper specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb')) }

    missing.each do |file|
      puts "Missing helper spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing helper spec files found!".colorize(:green)
    end
  end

  def self.print_missing_view_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/views/**/#{options[:specific_namespace].gsub('app/views', '')}/**/*.erb"]
    else
      files_list = Dir["app/views/**/*.erb"]
    end

    puts "\n" << "## Searching for missing view specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?("#{file.gsub('app/', 'spec/')}_spec.rb") }

    missing.each do |file|
      puts "Missing view spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing view spec files found!".colorize(:green)
    end
  end

  def self.print_missing_serializer_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/serializers/**/#{options[:specific_namespace].gsub('app/serializers', '')}/**/*.erb"]
    else
      files_list = Dir["app/serializers/**/*.erb"]
    end

    puts "\n" << "## Searching for missing serializers specs...".colorize(:light_blue)
    missing = files_list.select { |file| !FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb')) }

    missing.each do |file|
      puts "Missing serializer spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing serializer spec files found!".colorize(:green)
    end
  end

  def self.print_missing_route_specs(options = {})
    routes = Rails.application.routes.routes.map do |route|
      path = route.path.spec.to_s.gsub(/\(\.:format\)/, "")
      verb = %W{ GET POST PUT PATCH DELETE }.grep(route.verb).first.downcase.to_sym
      controller = route.defaults[:controller]
      action = route.defaults[:action]

      if controller.present? && !/^rails/.match(controller)
        { :path => path, :verb => verb, :controller => controller, :action => action }
      end
    end.compact

    puts "\n" << "## Searching for missing route specs...".colorize(:light_blue)
    missing = []

    routes.group_by { |route| route[:controller] }.each do |route_group|
      unless File.exists?(Rails.root.join("spec/routing/#{route_group[0]}_routing_spec.rb"))
        missing << "spec/routing/#{route_group[0]}_routing_spec.rb"
      end
    end

     missing.each do |file|
      puts "Missing route spec file for: #{file}".colorize(:red)
    end

    if missing.size == 0 
      puts "No missing route spec files found!".colorize(:green)
    end
  end
end