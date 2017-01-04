module SpecProducer
  module Producers
    class RoutesProducer
      prepend Base

      def resources
        Rails.application.routes.routes.
        select { |route| route.defaults[:controller].present? && !/^rails/.match(route.defaults[:controller]) }.
        map { |route| { :path => route.path.spec.to_s.gsub(/\(\.:format\)/, ""), 
                        :verb => %W{ GET POST PUT PATCH DELETE }.grep(route.verb).first.downcase.to_sym, 
                        :controller => route.defaults[:controller], 
                        :action => route.defaults[:action] } }.
        group_by { |route| route[:controller] }.
        map { |route_group| Resource.new(route_group, route_group[0], 'routing') }
      end

      def call(resource)
        resource.obj[1].each do |route|
          builder.context("#{route[:verb].upcase} #{route[:path].gsub(/\(.*?\)/, '')} should route to '#{route[:controller]}##{route[:action]}'") do

          route_specifics = { :controller => route[:controller], 
                              :action => route[:action] }

          route[:path].gsub(/\(.*?\)/, '').scan(/:[a-zA-Z_]+/).flatten.each do |parameter|  
            route_specifics[parameter.gsub(':','')] = "#{parameter.gsub(':','').upcase}"
          end
          
          route_requested = route[:path].gsub(/\(.*?\)/, '').gsub(/:[a-zA-Z_]+/){ |param| param.gsub(':','').upcase }

          builder.it("expect(:#{route[:verb]} => '#{route_requested}').to route_to(#{route_specifics.map { |k,v| ":#{k} => '#{v}'"}.join(', ')})")
        end
        end
      end

      #######
      private
      #######

      def require_helper_string
        @require_helper_string ||= Utils::FileUtils.collect_helper_strings
      end
    end
  end
end