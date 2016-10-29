require 'colorize'

module SpecProducer::MissingGemsModule
  def self.set_up_necessities
    # TODO: Update spec_helper or rails helper with proper configurations
    gemfiles = Dir.glob(Rails.root.join('Gemfile'))

    if gemfiles.size > 0
      contents = File.read(gemfiles.first)
      gems = contents.scan(/gem \'(?<gem>\S*)\'/).flatten.uniq
      missing_gems = []

      missing_gems << 'rspec-rails' unless (gems.include? 'rspec-rails')
      missing_gems << 'factory_girl_rails' unless (gems.include? 'factory_girl_rails')
      missing_gems << 'shoulda-matchers' unless (gems.include? 'shoulda-matchers')
      missing_gems << 'webmock' unless (gems.include? 'webmock')
      missing_gems << 'rubocop' unless (gems.include? 'rubocop')

      # No need for capybara if there are no views to parse
      missing_gems << 'capybara' unless ((gems.include? 'capybara') && Dir["app/views/**/*.erb"] != [])

      if missing_gems.size > 0
        actions_needed = ""
        useful_info = "\nGems installed:\n"
        contents << "\n\ngroup :test do\n"

        missing_gems.each do |gem|
          contents << "  gem '#{gem}'\n"

          if gem == 'rspec-rails'
            useful_info << "# Rspec: https://github.com/rspec/rspec-rails\n"
          elsif gem == 'factory_girl_rails'
            useful_info << "# FactoryGirl: https://github.com/thoughtbot/factory_girl_rails\n"
          elsif gem == 'shoulda-matchers'
            useful_info << "# Shoulda Matchers: https://github.com/thoughtbot/shoulda-matchers\n"
          elsif gem == 'webmock'
            actions_needed << "# Add 'require \'webmock/rspec\'' in your spec_helper or rails_helper\n"
            useful_info << "# Webmock: https://github.com/bblimke/webmock\n"
          elsif gem == 'rubocop'
            useful_info << "# RuboCop: https://github.com/bbatsov/rubocop\n"
          end
        end

        contents << "end"

        f = File.open(gemfiles.first, 'wb+')
        f.write(contents)
        f.close

        if defined?(Bundler)
          Bundler.with_clean_env do
            puts "\n\nRunning bundle after setting list of gems in you Gemfile.".colorize(:yellow)

            system 'bundle install'
          end
        end

        if 'rspec-rails'.in? missing_gems
          puts "\n\nInitializing Rspec files and helpers.".colorize(:yellow)

          system 'rails generate rspec:install'
        end

        if actions_needed != ''
          puts "\n\nYou will additionally need to:\n".colorize(:green)
          puts actions_needed.colorize(:green)
        end

        puts useful_info.colorize(:light_blue)
      else
        puts 'Could not find anything missing!'.colorize(:light_blue)
      end
    else
      puts "We couldn't find a Gemfile and setting up halted!".colorize(:red)
    end
  end
end	
