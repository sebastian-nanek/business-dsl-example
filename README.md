Business DSL example

An example application showing how to develop a human-readable business-oriented domain specific language. Application covers:
  * sample parser implementation (using and parse rules)
  * executable script to interact with the libraries
  * sample semantic model that could describe a simple business application
  * a set of basic rules of transformation business rules into semantic model objects
  * starting template generation

This software is able to generate a working application, based on a textual spec and provided template set. For futher information, feel free to tweet me at @trusbl or contact me other way.

Running the application
=======================

	./bin/spec_me.rb NAME=BookSample 
	  	FILE=/home/sbl/msc/examples/books.spc \
	 	OUTPUT=/home/sbl/books-out \
	 	TEMPLATE=/home/sbl/msc/template --trace

Where FILE is the path to your source code, OUTPUT is compilation target directory and TEMPLATE is path containing template generator.

Example code 
============

Defining data structures (please keep in mind that this example covers only a small part of available rules).

	1. Section "Available resources"
	  System stores resource "Invoice" that contains following fields:
	  - text field "description"
	  - currency field "amount"
	  - date field "issue_date"
	  - date field "payment_date"

	  System stores resource "Invoice Entry" that contains following fields:
	  - text field "name"
	  - currency field "amount"

Implementing templates	
======================

If you plan to automatically generate an application from a domain model, you need to write own generator/template module. Template directory shall contain a class, that has at least 2 methods - `initialize` and `build!`. See following pseudo-code:

	class RailsTemplate
	# (...)
	def initialize(semantic_model, application_name,
		target_directory, template_directory)
		@semantic_model = semantic_model
		@target_directory = target_directory
		@template_directory = template_directory
		@application_name = application_name
	end

	def build!
		begin
			run_app_generator!
			clone_files!
			build_application!
			show_after_create_instruction
		rescue Exception => e
			rescue_exception(e)
		end
	end
	# (...)


Summary
=======

See LICENSE for reusage details. Please drop me a message (@trusbl) if you plan to use it or need any help.