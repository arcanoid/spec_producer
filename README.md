# SpecProducer

[![Build Status](https://travis-ci.org/arcanoid/spec_producer.svg?branch=master)](https://travis-ci.org/arcanoid/spec_producer)
[![Gem Version](https://badge.fury.io/rb/spec_producer.svg)](https://badge.fury.io/rb/spec_producer)

SpecProducer is a library that is meant to assist users in skipping the tedious work of creating spec tests for basic
Rails applications. It reads through Active Record subclasses of the project and prepares some of the basic spec tests for you.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'spec_producer'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spec_producer

## Usage

Currently this gem supports the production of spec tests for active record models.
If the spec file already exists then it prints out the contents it would generated
for a model.

To produce all possible tests you can run the public API methods directly from a Rails console
or use the rake tasks provided by the gem (run rake -T | grep spec_producer for all available rake tasks)
on  a rails project.

```ruby
  # Using a rake task (currently supports producing only model specs)
  bundle exec rake spec_producer:all

  #or produce all tests for models:

  bundle exec rake spec_producer:models
```

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
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arcanoid/spec_producer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

