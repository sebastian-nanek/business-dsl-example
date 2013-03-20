require 'spec_helper'

shared_examples_for "resource object" do 
  context "at instance level" do
    let(:resource_object) { described_class.new }
  end

  context "at class level" do
    let(:resource_object) { described_class }
  end
end
