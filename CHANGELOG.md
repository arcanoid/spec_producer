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