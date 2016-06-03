# SpecProducer

SpecProducer is a gem that is meant to assist users in skipping the tedious work of creating spec tests for basic 
functionality. It reads through the files of the project and prepares some of the basic spec tests for you. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spec_producer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spec_producer

## Usage

Currently this gem supports the production of spec tests for activemodel Models and routing specs.

To produce all possible tests, run:
* SpecProducer.produce_specs_for_all_types

To produce all tests for models, run:
* SpecProducer.produce_specs_for_models

To produce all tests for routes, run:
* SpecProducer.produce_specs_for_routes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/spec_producer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

