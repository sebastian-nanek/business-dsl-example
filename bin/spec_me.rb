#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib", __FILE__)

$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), '../lib' ) )
require File.join(File.dirname(__FILE__), '../lib/loader' )

SpecMe::Application.initialize!
SpecMe::Application.parse_spec!(SpecMe::Application.config.spec_file)
SpecMe::Application.generate_application!