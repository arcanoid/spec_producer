# Establish an in memory connection to SQLite3
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
# Load the schema
load 'support/schema.rb'
# And require  AR models
require 'support/models'
#require File.dirname(__FILE__) + '/support.rb'

# TODO: Just a hack to pass Rails.root we need a proper config
# here. We should probably introduce a dummy app like engines
# do.
RSpec.configure do |config|
  config.before(:each) do
    root = Class.new(Object) do
      def root
        "spec/rails_root/"
      end

      def join(other)
        root + other
      end

      def application
        self
      end

      def eager_load!
        self
      end
    end
    allow(Rails).to receive(:root).and_return(root.new)
    allow(Rails).to receive(:application).and_return(root.new.application)
  end
end
