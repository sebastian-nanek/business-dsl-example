require 'spec_helper'

describe SemanticModel::Commons::ResourceValidation do
  context "at class level" do
    subject { SemanticModel::Commons::ResourceValidation }
    
    it "maps all validations from string to array and returns its parameters - when no value in validation is passed" do
      subject.map_validation("a unique value").should == { :uniqueness => true }
      subject.map_validation("always present").should == { :presence => true }
      subject.map_validation("always a number").should == { :numericality => true }
    end

    it "maps all validations from string to array and returns its parameters - when there is a value in validation is passed" do
      subject.map_validation("always greater than 42").should == { :greater_than => "42" }
      subject.map_validation("always less than 42").should == { :less_than => "42" }
      subject.map_validation("always less than 42").should == { :less_than => "42" }
      subject.map_validation("always equal to 3.14").should == { :equality => "3.14" }
      subject.map_validation("always shorter than 3 characters").should == { :shorter_than => "3" }
      subject.map_validation("always 5 characters long").should == { :length => "5" }
      subject.map_validation("always longer than 3 characters").should == { :longer_than => "3" }
      subject.map_validation("always not greater than 42").should == { :less_or_equal_to => "42" }
      subject.map_validation("always not smaller than 42").should == { :greater_or_equal_to => "42" }
      subject.map_validation("always in format /\\d\\d-\\d\\d\\d/").should == { :format => "\\d\\d\-\\d\\d\\d" }
    end

    it "raises an exception if unknown validation is passed" do
      expect {subject.map_validation("always wrong")}.to raise_exception SemanticModel::UnknownValidation
    end
  end
end