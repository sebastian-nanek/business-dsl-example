require 'spec_helper'

describe SemanticModel::Elements::Base do
  context "with initialized object" do
    subject { SemanticModel::Elements::Base.new "Sample model element" }

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

  context "at class level" do
    subject { SemanticModel::Elements::Base }
    let(:descending_klass) { SemanticModel::Elements::Resource }

    it "has a list of possible merge classes" do
      subject.possible_merge_classes.should == [ 
        SemanticModel::Elements::Base,
        SemanticModel::Stubs::Base,
     ]
    end

    it "has valid list of possible merge classes, even if is an instance of that class" do
      descending_klass.possible_merge_classes.should == [ 
        SemanticModel::Elements::Resource,
        SemanticModel::Stubs::Resource,
     ]
    end
  end
  
  context "on merging records" do
    subject { SemanticModel::Elements::Base.new "Sample model" }
    let(:sample_stub) { SemanticModel::Stubs::Base.new "Sample model" }
    let(:sample_stub_with_other_name) { SemanticModel::Stubs::Base.new "Sample model with other name" }

    it "allows merging stubs into records if names match" do      
      subject.merge_with sample_stub
      subject.name.should == "Sample model"
    end

    it "does not raise exception if names match" do      
      expect { subject.merge_with sample_stub }.not_to raise_exception
    end

    it "raises exception if names do not match" do      
      expect { subject.merge_with(sample_stub_with_other_name) }.to raise_exception(SemanticModel::ImpossibleMerge)      
    end

    context "subject and stub with some data provided" do
      subject { 
        SemanticModel::Elements::Base.new "Sample model", {
          :data => [SemanticModel::Elements::ResourceField.new("creation_date", :date)]
        } 
      }
      let(:stub_with_data) { 
       SemanticModel::Stubs::Base.new "Sample model", {
          :data => [SemanticModel::Elements::ResourceField.new("name", :text)]
        } 
      }

      it "merges data fields" do
        subject.merge_with(stub_with_data) 
        subject.data.length.should == 2
      end
    end
  end
end