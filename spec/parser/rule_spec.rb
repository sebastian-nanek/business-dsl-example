require 'spec_helper'

describe Parser::Rule do

  context "on object initialization" do
    subject { Parser::Rule } 

    it "raises exceptions if no rule or building code provided" do            
      expect { subject.new(nil, nil).to raise_exception(Parser::NoMatchingRuleProvided) }
      expect { subject.new(/There is a house of rising sun./).to raise_exception(Parser::EmptyCode) }
    end
  end


  context "with initialized, very basic rule provided" do
    subject { Parser::Rule.new(/Very basic matching expression/) {} } 

    it "is not multiline matching rule" do
      subject.should_not be_multiline
    end
  end

  context "with rule that produce objects and one-line expression" do
    subject do
      Parser::Rule.new(/Expression with a gap "(.*)"/) { |data|        
        name = data.first
        SemanticModel::Elements::Resource.new(name)
      }
    end

    let(:expression) do
      "Expression with a gap \"So tru\"."
    end

    it "should match the expression" do
      subject.matches?(expression).should be_true
    end

    it "should build an instance of SemanticModel::Elements::Resource with name properly set" do
      parsed_objects = subject.parse(expression)
      parsed_objects.length.should == 1
      parsed_object = parsed_objects.first
      parsed_object.should be_a_kind_of(SemanticModel::Elements::Resource)
      parsed_object.name.should == "So tru"
    end
  end

  context "with initialized, multiline rule provided" do
    subject { Parser::Rule.new(/Very basic matching expression/) {} } 

    it "is multiline matching rule" do
      subject.should_not be_multiline
    end
  end

  context "with multiline rule and basic production code provided" do
    subject do
      Parser::Rule.new(/Expression with a gap .*/) { |matches|
        name = matches.second
        SemanticModel::Elements::Resource.new(name)
      }
    end   
  end
end