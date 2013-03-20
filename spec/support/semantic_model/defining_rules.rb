require 'spec_helper'

shared_examples_for "a container that allows defining rules" do 
  context "at instance level" do
    let(:semantic_model) { described_class.new }

    describe ".define_rule" do
      context "with defined very basic rule" do
        before :each do
          semantic_model.define_rule(/(.*) Subsection "(.*)"/) { |name| }
        end

        it "default rule is accessible as other rules" do
          semantic_model.rules.should have( 1 + SemanticModel::DefaultRules.rules.length ).item
        end
      end
    end
  end

  context "at class level" do
    let(:semantic_model) { described_class }
    
    let(:matcher_regexp) { /Some sample code that stores resource "(.*)"/ }
    let(:multiline_regexp) { /a field named "(.*)"/ }

    it "allows building instances of Parser::Rule with ease" do
      code_block = proc { 
        semantic_model.build_rule(matcher_regexp) do |name|
          SemanticModel::Elements::Resource.new(name)
        end
      }
      expect { code_block.call }.not_to raise_exception
      code_block.call.should be_a_kind_of(Parser::Rule)
      code_block.call.expression.should == matcher_regexp
    end

    it "builds Parser::MultilineRule if second Regexp parameter is provided" do
      code_block = proc { 
        semantic_model.build_rule(matcher_regexp, multiline_regexp) do |name, field_names|
          SemanticModel::Elements::Resource.new(name)
        end
      }
      expect { code_block.call }.not_to raise_exception
      code_block.call.should be_a_kind_of(Parser::MultilineRule)
      code_block.call.expression.should == matcher_regexp
      code_block.call.multiline_expression.should == multiline_regexp
    end


  end
end
