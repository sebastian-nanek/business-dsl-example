require 'spec_helper'

describe SemanticModel::Elements::ResourceField do
  it_should_behave_like "resource object"

  context "with initialized object" do
    subject { SemanticModel::Elements::ResourceField.new "sample field", :string }

    it "as subject has its name set, datatype defined, it is valid" do        
      subject.name.should == "sample field"
      subject.datatype.should == :string
      subject.should be_valid
    end

    it "has parameterized identifier" do
      subject.name.should == "sample field"
      subject.identifier.should == "sample-field"
    end

    it "stores errors after validations if no name provided (as most basic validation)" do
      subject.name = ""
      subject.valid?
      subject.should_not be_valid
      subject.errors[:name].should_not be_nil
      subject.errors[:name].should_not be_empty
    end

    it "can map some uncommon type definition into basic types" do
      subject.map_datatype("floating point number").should == :float
      subject.map_datatype("floating number").should == :float
      subject.map_datatype("float number").should == :float
      subject.map_datatype("string").should == :string
      subject.map_datatype("long string").should == :text
      subject.map_datatype("long text").should == :text
      subject.map_datatype("number").should == :integer
    end

    it "leaves basic types untouched after mapping" do
      subject.map_datatype("text").should == :text
      subject.map_datatype("string").should == :string
      subject.map_datatype("date").should == :date
      subject.map_datatype("time").should == :time
      subject.map_datatype("float").should == :float
      subject.map_datatype("integer").should == :integer
      subject.map_datatype("currency").should == :currency
      subject.map_datatype("enumeration").should == :enumeration
    end
  end
end