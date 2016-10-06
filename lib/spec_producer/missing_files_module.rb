module SpecProducer::MissingFilesModule
  def self.print_missing_model_specs
    files_list = Dir["app/models/**/*.rb"]

    puts "\n" << "## Searching for missing model specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing model spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_controller_specs
    files_list = Dir["app/controllers/**/*.rb"]

    puts "\n" << "## Searching for missing controller specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing controller spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_job_specs
    files_list = Dir["app/jobs/**/*.rb"]

    puts "\n" << "## Searching for missing jobs specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing job spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_mailer_specs
    files_list = Dir["app/mailers/**/*.rb"]

    puts "\n" << "## Searching for missing mailers specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing mailer spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_helper_specs
    files_list = Dir["app/helpers/**/*.rb"]

    puts "\n" << "## Searching for missing helper specs..."
    files_list.each do |file|
      unless FileTest.exists?(file.gsub('app/', 'spec/').gsub('.rb', '_spec.rb'))
        puts "Missing helper spec file for: #{file}"
      end
    end

    nil
  end

  def self.print_missing_view_specs
    files_list = Dir["app/views/**/*.erb"]

    puts "\n" << "## Searching for missing view specs..."
    files_list.each do |file|
      unless FileTest.exists?("#{file.gsub('app/', 'spec/')}_spec.rb")
        puts "Missing spec file for: #{file}"
      end
    end

    nil
  end
end