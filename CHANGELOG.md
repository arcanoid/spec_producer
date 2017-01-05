## 0.13.0 (2017-01-05)

Features:
* Major refactoring on how specs are produced (some previous functionality may not be supported here)
* Add rake tasks for each functionality supported

## 0.12.0 (2016-11-8)

Features:
* Cover more characteristics through static analysis
* Update serializer specs
* Colorized responses
* Run specs after production
* Initial attempt for command line runs

## 0.11.0 (2016-10-18)

Features:
* Add serializer specs production
* Fixes in view specs
* Handle missing Delayed Jobssetup
* Update helper specs to include helper methods
* Logs in name error now describe the error as well.

## 0.10.0 (2016-10-07)

Features:
* Allow clients to set namespace in options for missing resources

Fixes:
* Problem with missing resources methods due to typo.

## 0.9.0 (2016-10-06)

* Ignore optional parameters when producing routing specs
* Read helper that might be used already in the existing specs
* Adds new set_up_necessities method that checks whether necessary gems exist in the gemfile and if not updates it.
* aDDS new method for producing factories for each model
* Adds more info in the view specs produced
* Print missing specs files for mailers and jobs
* Produce specs for mailers and jobs


## 0.8.0 (2016-08-30)

Fixes:
* Updated production of routing specs

## 0.7.0 (2016-08-10)

Features:
* Producer now tries to produce all factories for the project that uses it

## 0.6.0 (2016-08-09)

Features:
* Update all produced specs to specify the proper type of it to comply with rspec 3.5 and onwards

## 0.5.0 (2016-08-02)

Features:
* Updated routing specs producer to use expect rather than should
* Mini fix for projects that may not have ActiveRecord set

## 0.4.0 (2016-07-09)

Features:
* Added tests for readonly attributes
* Added more validation tests
* Added tests for db associations

Bug fixes:
* Fixes bug with naming
* Fixes bug when spec directory doesn't exist
* Fixes bug that skipped models in deeper namespace
* Code reformats and clearer output

## 0.3.0 (2016-06-12)

Features:
* Added some activemodel specs through shoulda matchers
* Added produce_specs_for_views to produce spec files with pending indications for all Views.
* Added produce_specs_for_helpers to produce spec files with pending indications for all Helpers.
* Added produce_specs_for_controllers to produce spec files with pending indications for all Controllers.

## 0.2.0 (2016-06-04)

Features:
* Added print_missing_model_specs to print all the missing tests that refer to Models
* Added print_missing_controller_specs to print all the missing tests that refer to Controllers
* Added print_missing_helper_specs to print all the missing tests that refer to Helpers
* Added print_missing_view_specs to print all the missing tests that refer to Views
* Added print_all_missing_spec_files to print the missing tests for all types covered with single methods.

## 0.1.0 (2016-06-04)

Features:
* Added produce_specs_for_models to product spec tests for all Models in projects
* Added produce_specs_for_routes to product route tests for all Routes in projects
* Added produce_specs_for_all_types to product spec tests for all types covered with single methods.