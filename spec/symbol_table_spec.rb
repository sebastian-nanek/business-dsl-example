require 'spec_helper'

describe SymbolTable do

  context "at class level" do
    it "maps keys from strings" do
      subject.map_key("Test model").should == "test-model"
      subject.map_key("Test  Model  ").should == "test-model"
      subject.map_key("oth er  name").should == "oth-er-name"
    end
  end

  context "with an initialized instance" do
    subject { SymbolTable.new }

    let(:r_fields) { [ 
      SemanticModel::Elements::ResourceField.new("author", :string), 
      SemanticModel::Elements::ResourceField.new("volumes", :integer) 
    ]}

    it "allows object storage under given string or symbol key using either operator or push" do
      subject << SemanticModel::Elements::Resource.new("test")
      subject.push SemanticModel::Elements::Resource.new("test2")      
    end

    it "stores only one object on given key" do
      subject << SemanticModel::Elements::Resource.new("test", {:a => 1})
      expect { 
        begin
          subject << SemanticModel::Elements::Resource.new("test", {:a => 3});
        rescue Exception => e; end  # to stop propagating exception
      }.not_to change { subject.table.size }
    end

    it "raises an exception on redefinition" do
      subject << SemanticModel::Elements::Resource.new("test", {:a => 1})
      expect { subject << SemanticModel::Elements::Resource.new("test", {:a => 2}) }.to raise_exception(SymbolTable::SymbolAlreadyUsed)      
    end

    it "allows SymbolTable to be iterated" do
      subject.should respond_to(:each)
    end

    it "delegates key mapping to class level method" do
      ["class Test", "does it map it properly", "I donT know, but gonna checkit"].each do |key|
        subject.map_key(key).should == subject.class.map_key(key)
      end
    end

    it "destubizes a resource stub if provided, before putting into the table" do
      resource = SemanticModel::Stubs::Resource.new("test_object")   
      resource.record_fields = r_fields
      subject.push(resource)
      subject.empty?.should_not be_true
      subject.has_key?(resource.name).should be_true
      subject[resource.name].should be_a_kind_of(SemanticModel::Elements::Resource)
    end

    context "and a stored resource" do
      before :each do
        @resource = SemanticModel::Elements::Resource.new("Test model")
        subject << @resource
      end

      it "allows accessing stored object" do      
        subject["Test model"].should == @resource
      end

      it "allows checking existence of given key" do
        subject.has_key?("Dummy key").should be_false
        subject.has_key?("Test model").should be_true
      end

      it "allows stored object to be changed" do
        obj = subject["Test model"]
        obj.data = { a: 1 }
        subject["Test model"].data.should == { a: 1}
      end
    end
  end
end