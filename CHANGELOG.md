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