module SpecProducer::MissingFilesModule
  def self.print_missing_model_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/models/**/#{options[:specific_namespace].gsub('app/models', '')}/**/*.rb"]
    else
      files_list = Dir["app/models/**/*.rb"]
    end

    puts "\n" << "## Searching for missing model specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing model spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_controller_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/controllers/**/#{options[:specific_namespace].gsub('app/controllers', '')}/**/*.rb"]
    else
      files_list = Dir["app/controllers/**/*.rb"]
    end

    puts "\n" << "## Searching for missing controller specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing controller spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_job_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/jobs/**/#{options[:specific_namespace].gsub('app/jobs', '')}/**/*.rb"]
    else
      files_list = Dir["app/jobs/**/*.rb"]
    end

    puts "\n" << "## Searching for missing jobs specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing job spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_mailer_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/mailers/**/#{options[:specific_namespace].gsub('app/mailers', '')}/**/*.rb"]
    else
      files_list = Dir["app/mailers/**/*.rb"]
    end

    puts "\n" << "## Searching for missing mailers specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing mailer spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_helper_specs(options = {})(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/helpers/**/#{options[:specific_namespace].gsub('app/helpers', '')}/**/*.rb"]
    else
      files_list = Dir["app/helpers/**/*.rb"]
    end

    puts "\n" << "## Searching for missing helper specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing helper spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_view_specs(options = {})
    if options[:specific_namespace]
      files_list = Dir["app/views/**/#{options[:specific_namespace].gsub('app/views', '')}/**/*.erb"]
    else
      files_list = Dir["app/views/**/*.erb"]
    end

    puts "\n" << "## Searching for missing view specs..."
    files_list.each do |file|
      unless FileTest.exists?("#{file.gsub('app/', 'spec/')}_spec.rb")
        puts "Missing spec file for: #{file}"
      end
    end

    nil
  end
end