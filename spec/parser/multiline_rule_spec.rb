require 'spec_helper'

describe Parser::MultilineRule do

  context "on object initialization" do
    subject { Parser::MultilineRule } 

    it "raises exceptions if no rule or building code provided" do            
      expect { subject.new(nil, nil).to raise_exception(Parser::NoMatchingRuleProvided) }
      expect { (subject.new(/There is a house of rising sun./, nil) { @dummy_code = true } ).to raise_exception(Parser::NoMatchingRuleProvided) }
      expect { subject.new(/There is a house of rising sun./, nil).to raise_exception(Parser::EmptyCode) }
    end
  end

  context "with initialized, very basic rule provided" do
    subject { Parser::MultilineRule.new(/Very basic matching expression/, /and some code/) {} } 

    it "is multiline matching rule" do
      subject.should be_multiline
    end
  end

  context "with rule that produce objects and one-line expression" do
    subject do
      Parser::MultilineRule.new(/Expression with a gap "(.*)"/, /and define some field named "(.*)"/) { |data, fields_array|        
        name = data.last
        resource = SemanticModel::Elements::Resource.new(name)

        unless fields_array.nil?
          fields = fields_array.collect do |field|
            SemanticModel::Elements::ResourceField.new(field.last.to_s, :text)
          end
          resource.record_fields = fields
        end

        resource
      }
    end

    let(:expression) { "Expression with a gap \"So tru\"." }
    let(:lines) { ['and define some field named "dummy"', 'and define some field named "nanny"'] }

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

    it "also builds following subexpressions" do
      parsed_object = subject.parse(expression, lines)
      resource = parsed_object.first
      resource.should be_a_kind_of(SemanticModel::Elements::Resource)
      resource.record_fields.length.should == 2
    end
  end

  context "with initialized, multiline rule provided" do
    subject { Parser::MultilineRule.new(/Very basic matching expression/, /with some multiline expr/) {} } 

    it "is multiline matching rule" do
      subject.should be_multiline
    end
  end

  context "with multiline rule and basic production code provided" do
    subject do
      Parser::MultilineRule.new(/Expression with a gap .*/, /multiline expression/) { |matches, data_array|
        name = matches.second
        SemanticModel::Elements::Resource.new(name)
      }
    end   
  end
end