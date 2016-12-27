module SpecProducer
  module Utils
    module FileUtils
      module_function

      def try_to_create_spec_file(context, filename, final_text)
        if File.exists?(Rails.root.join("spec/#{context}/#{filename}_spec.rb"))
          if File.open(Rails.root.join("spec/#{context}/#{filename}_spec.rb")).read == final_text
            # nothing to do here, pre-existing content is the same :)
          else
            puts ('#'*100).colorize(:light_blue)
            puts ("Please, check whether the following lines are included in: " + filename + "_spec.rb").colorize(:light_blue)
            puts ('#'*100).colorize(:light_blue)
            puts final_text
            puts "\n\n"
          end
        else
          unless Dir.exists? Rails.root.join("spec")
            puts "Generating spec directory".colorize(:yellow)
            Dir.mkdir(Rails.root.join("spec"))
          end

          unless Dir.exists? Rails.root.join("spec/#{context}")
            puts "Generating spec/#{context} directory".colorize(:yellow)
            Dir.mkdir(Rails.root.join("spec/#{context}"))
          end

          path = "spec/#{context}/#{filename}_spec.rb"
          puts "Producing model spec file for: #{path}".colorize(:green)
          f = File.open("#{Rails.root.join(path)}", 'wb+')
          f.write(final_text)
          f.close
        end
      end

      def collect_helper_strings
        spec_files = Dir.glob(Rails.root.join('spec/**/*_spec.rb'))
        helper_strings_used = []

        spec_files.each do |file|
          helper = /require \'(?<helpers>\S*)\'/.match File.read(file)

          helper_strings_used << helper[1] if helper.present?
        end

        helper_strings_used.compact!

        if helper_strings_used.uniq.length == 1
          "#{helper_strings_used.first}"
        else
          puts "More than one helpers are in place in your specs! Proceeding with 'rails_helpers'.".colorize(:yellow)
          "rails_helper"
        end
      end
    end
  end
end
