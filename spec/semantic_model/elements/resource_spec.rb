require 'spec_helper'

describe SemanticModel::Elements::Resource do
  it_should_behave_like "resource object"

  context "with initialized object" do
    subject { SemanticModel::Elements::Resource.new "Sample model element" }

    it "as subject has its name set, it is valid" do        
      subject.name = "Test semantic model element"
      subject.should be_valid
    end

    it "has parameterized identifier" do
      subject.name = "Test semantic model element"
      subject.identifier.should == "test-semantic-model-element"
    end

    it "stores errors after validations if no name provided (as most basic validation)" do
      subject.name = ""
      subject.valid?
      subject.errors[:name].should_not be_nil
      subject.errors[:name].should_not be_empty
    end
  end
end