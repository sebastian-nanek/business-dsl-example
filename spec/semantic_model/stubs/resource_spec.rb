require 'spec_helper'

describe SemanticModel::Stubs::Resource do
  it_should_behave_like "resource object"

  context "with initialized object" do
    subject { SemanticModel::Stubs::Resource.new "Sample model element" }
    let(:r_fields) { [ 
      SemanticModel::Elements::ResourceField.new("author", :string), 
      SemanticModel::Elements::ResourceField.new("volumes", :integer) 
    ]}

    it "can be destubized" do
      subject.record_fields = r_fields
      element = subject.destubize!
      element.name.should == subject.name
      element.record_fields.length.should == 2
      element.record_fields.first.name.should == r_fields.first.name
      element.record_fields.first.datatype.should == r_fields.first.datatype
    end
  end
end