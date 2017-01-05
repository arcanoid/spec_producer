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

To produce all tests for routes, run:

```ruby
bundle exec rake spec_producer:routes
```

To produce all spec files for views, run:

```ruby
bundle exec rake spec_producer:views
```

To produce all spec files for helpers, run:

```ruby
bundle exec rake spec_producer:helpers
```

To produce all spec files for controllers, run:

```ruby
bundle exec rake spec_producer:controllers
```

To produce all spec files for jobs, run:

```ruby
bundle exec rake spec_producer:jobs
```

To produce all spec files for mailers, run:

```ruby
bundle exec rake spec_producer:mailers
```

To produce all spec files for serializers, run:

```ruby
bundle exec rake spec_producer:serializers
```

In case you have factory_girl gem installed, to produce a list of sample factory files for your models, run:

```ruby
bundle exec rake spec_producer:factories
```

Additionally this gem (from version 0.2.0) allows users to print all their missing spec files by reading all 
directories for Views, Models, Controllers, Helpers etc.

To print all types of missing tests, run:

```ruby
bundle exec rake missing_specs_printer:all
```

To print all missing model tests, run:

```ruby
bundle exec rake missing_specs_printer:models
```

To print all missing controller tests, run:

```ruby
bundle exec rake missing_specs_printer:controllers
```

To print all missing helper tests, run:

```ruby
bundle exec rake missing_specs_printer:helpers
```

To print all missing view tests, run:

```ruby
bundle exec rake missing_specs_printer:views
```

To print all missing job tests, run:

```ruby
bundle exec rake missing_specs_printer:jobs
```

To print all missing mailer tests, run:

```ruby
bundle exec rake missing_specs_printer:mailers
```

To print all missing route tests, run:

```ruby
bundle exec rake missing_specs_printer:routes
```

To print all missing serializer tests, run:

```ruby
bundle exec rake missing_specs_printer:serializers
```

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arcanoid/spec_producer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

