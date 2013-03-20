require './lib/loader'
require 'rspec'

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |c|
  c.mock_with :rspec
  c.pattern = "**/*_spec.rb"
  c.color_enabled = true
end
