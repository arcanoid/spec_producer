require "spec_producer/version"

module SpecProducer
  def self.produce_specs_for_all_types
    produce_specs_for_models
    produce_specs_for_routes
  end

  def self.produce_specs_for_models
    Dir.glob(Rails.root.join('app/models/*.rb')).each do |x|
      require x
    end

    ActiveRecord::Base.descendants.each do |descendant|
      final_text = "require 'rails_helper'\n"
      final_text << "describe #{descendant.name} do\n"

      descendant.attribute_names.each do |attribute|
        final_text << "\tit { should respond_to :#{attribute}, :#{attribute}= }\n"
      end

      final_text << "end"

      if File.exists?(Rails.root.join("spec/models/#{descendant.name.downcase}_spec.rb"))
        puts '#'*100
        puts "Please, check whether the following lines are included in: " + descendant.name.downcase + "_spec.rb\n"
        puts '#'*100
        puts "\n"
        puts final_text
      else
        unless Dir.exists? Rails.root.join("spec/models")
          puts "Generating spec/models directory"
          Dir.mkdir(Rails.root.join("spec/models"))
        end

        path = "spec/models/#{descendant.name.downcase}_spec.rb"
        puts "Creating spec file for #{path}"
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end

  def self.produce_specs_for_routes
    routes = Rails.application.routes.routes.map do |route|
      path = route.path.spec.to_s.gsub(/\(\.:format\)/, "")
      verb = %W{ GET POST PUT PATCH DELETE }.grep(route.verb).first.downcase.to_sym
      controller = route.defaults[:controller]
      action = route.defaults[:action]

      if controller.present? && !/^rails/.match(controller)
        { :path => path, :verb => verb, :controller => controller, :action => action }
      end
    end.compact

    routes.group_by { |route| route[:controller] }.each do |route_group|
      final_text = "require 'rails_helper'\n\n"
      final_text << "describe '#{route_group[0]} routes' do\n"

      route_group[1].each do |route|
        final_text << "\tit \"#{route[:verb].upcase} #{route[:path]} should route to '#{route[:controller]}##{route[:action]}'\" do\n"

        final_text << "\t\t{ :#{route[:verb]} => '#{route[:path].gsub(/:[a-zA-Z_]+/){ |param| param.gsub(':','').upcase }}'}.\n"
        final_text << "\t\t\tshould route_to(:controller => '#{route[:controller]}',\n"

        /:[a-zA-Z_]+/.match(route[:path]).to_a.each do |parameter|
          final_text << "\t\t\t\t\t#{parameter} => '#{parameter.gsub(':','').upcase}',\n"
        end

        final_text << "\t\t\t\t\t:action => '#{route[:action]}')\n"
        final_text << "\t\tend\n\n"
      end

      final_text << 'end'

      if File.exists?(Rails.root.join("spec/routing/#{route_group[0]}_routing_spec.rb"))
        puts '#'*100
        puts "Please, check whether the following lines are included in: spec/routing/#{route_group[0]}_routing_spec.rb\n"
        puts '#'*100
        puts "\n"
        puts final_text
      else
        unless Dir.exists? Rails.root.join("spec/routing")
          puts "Generating spec/routing directory"
          Dir.mkdir(Rails.root.join("spec/routing"))
        end

        path = "spec/routing/#{route_group[0]}_routing_spec.rb"
        puts "Creating spec file for #{route_group[0]}"
        f = File.open("#{Rails.root.join(path)}", 'wb+')
        f.write(final_text)
        f.close
      end
    end

    nil
  end
end
