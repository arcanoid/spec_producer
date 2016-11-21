# SpecProducer

[![Build Status](https://travis-ci.org/arcanoid/spec_producer.svg?branch=master)](https://travis-ci.org/arcanoid/spec_producer)
[![Gem Version](https://badge.fury.io/rb/spec_producer.svg)](https://badge.fury.io/rb/spec_producer)

SpecProducer is a gem that is meant to assist users in skipping the tedious work of creating spec tests for basic 
functionality. It reads through the files of the project and prepares some of the basic spec tests for you. 

## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem 'spec_producer'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spec_producer

## Usage

Currently this gem supports the production of spec tests for activemodel Models and routing specs.
If the spec file already exists then it prints what could be its contents.

To produce all possible tests, run:

```ruby
SpecProducer.produce_specs_for_all_types
```

To produce all tests for models, run:

```ruby
SpecProducer.produce_specs_for_models
```

To produce all tests for routes, run:

```ruby
SpecProducer.produce_specs_for_routes
```

To produce all spec files for views, run:

```ruby
SpecProducer.produce_specs_for_views
```

To produce all spec files for helpers, run:

```ruby
SpecProducer.produce_specs_for_helpers
```

To produce all spec files for controllers, run:

```ruby
SpecProducer.produce_specs_for_controllers
```

Additionally this gem (from version 0.2.0) allows users to print all their missing spec files by reading all 
directories for Views, Models, Controllers and Helpers.

To print all types of missing tests, run:

```ruby
SpecProducer.print_all_missing_spec_files
```

To print all missing model tests, run:

```ruby
SpecProducer.print_missing_model_specs
```

To print all missing controller tests, run:

```ruby
SpecProducer.print_missing_controller_specs
```

To print all missing helper tests, run:

```ruby
SpecProducer.print_missing_helper_specs
```

To print all missing view tests, run:

```ruby
SpecProducer.print_missing_view_specs
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arcanoid/spec_producer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

