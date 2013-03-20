require 'spec_helper'

describe Parser::Base do

  let(:semantic_model) { SemanticModel::Base.new }

  context "during object initialization" do
    subject { Parser::Base } 

    it "requires an instance of SemanticModel on initialization" do      
      expect { subject.new(SemanticModel::Base.new) }.not_to raise_exception(Parser::SemanticModelNotProvided)
    end

    it "raises an exception if no instance of SemanticModel provided on initialization" do      
      expect { 
        subject.new("Dummy text") 
      }.to raise_exception(Parser::SemanticModelNotProvided)
    end
  end

  context "with Semantic Model that contains some basic rules" do

    let(:rule_a) do 
      Parser::Rule.new(/Resource with name "(.*)"/) { |data|
        SemanticModel::Elements::Resource.new(data.first)
      }
    end

    let(:rule_b) do 
      Parser::Rule.new(/Another resource with name "(.*)"/) { |data|
        SemanticModel::Elements::Resource.new(data.first + " 2")
      }
    end

    let(:semantic_model) do
      model = SemanticModel::Base.new(
        :rules => [
          rule_a,
          rule_b
        ])
    end

    subject { Parser::Base.new(semantic_model) }

    it "takes parsing rules from provided SemanticModel" do      
      subject.parse_rules.should_not be_empty
      subject.parse_rules.should have(2 + SemanticModel::DefaultRules.length).items
    end

    it 'finds matching rule for given code' do
      subject.find_matching_rule('Resource with name "Steve`s report"').should == rule_a
      subject.find_matching_rule('Another resource with name "Joan`s report"').should == rule_b
    end

    it 'returns nil if it cannot find matching rule' do
      subject.find_matching_rule('Report named "Steve`s pets"').should be_nil
    end
    
    it "matches lines by line file and adds object to associated semantic model" do      
      sample_spec = """ 
        Resource with name \"Invoice\".
        Another resource with name \"Invoice Entry\".
        Another resource with name \"Invoice Status\".
      """

      subject.parse_data(sample_spec)
      subject.semantic_model.symbol_table.should have(3).items
      subject.semantic_model.symbol_table.values.collect{ |x| x.class }.uniq.should == [ SemanticModel::Elements::Resource ]
    end
  end

  context "with an initialized instance, that contains one context-oriented rule" do
    subject { Parser::Base.new(semantic_model) } 
    let(:spec) { """ 
          System stores resource \"Invoice\" that contains following fields:
          - text field \"ident\"
          - date field \"issue_date\"
      """ }

    it "prints data rows in valid context if preceded by a dash sign" do
      subject.parse_data(spec)
      resource = subject.semantic_model.symbol_table["Invoice"]
      resource.name.should == "Invoice"
      resource.record_fields.length.should == 2
      resource.record_fields.first.name.should == "ident"
      resource.record_fields.first.datatype.should == :text
      resource.record_fields.last.name.should == "issue_date"
      resource.record_fields.last.datatype.should == :date
    end
  end  

  context "on preprocessing, when a more sophisticated spec is being processed" do

    let(:spec) { """ 

      # sample spec definition
      1. Section \"Invoice\"

        System stores resource \"Invoice\".
        System stores resource \"Invoice Entry\".
        System stores resource \"Invoice Status\".

      2. Section \"InvoiceEntry\"

        This section is defined in document \"./spec/support/sample_subspec.txt\".
      3. Section \"Other information\"
        # sample spec definition - file end

    """ }

    subject { Parser::Base.new(semantic_model) }

    context "building SemanticModel" do
      it "builds semantic model objects based from objects both in main text and included file" do
        subject.parse_data(spec)
        subject.semantic_model.symbol_table["Invoice"].should be_a_kind_of(SemanticModel::Elements::Base)
        subject.semantic_model.symbol_table["Invoice Entry"].should be_a_kind_of(SemanticModel::Elements::Base)
        subject.semantic_model.symbol_table["Invoice Status"].should be_a_kind_of(SemanticModel::Elements::Base)
        
        subject.semantic_model.symbol_table["Invoice"].name.should == "Invoice"
        subject.semantic_model.symbol_table["Invoice Entry"].name.should == "Invoice Entry"
        subject.semantic_model.symbol_table["Invoice Status"].name.should == "Invoice Status"
      end
    end


    context "processing spec text" do
      it "preprocesses code by stripping lines, removing empty and converting it into lines array" do
        result = subject.preprocess_code(spec)
        result.select { |x| x.empty? }.length.should == 0
        result.select { |x| x.match(/^\s/) }.length.should == 0
        result.should be_a_kind_of(Array)
      end

      it "loads data from external files and puts it inplace" do
        result = subject.preprocess_code(spec)
        result = subject.remove_comments(result)
        result = subject.load_external_files(result)
        
        # asserting that no exception is raised on this method call
        expect { subject.load_external_files(result) }.not_to raise_exception(Parser::IncludedFileNotFound)
        
        # check that external code has been merged into the original one
        result.join("\n").should match("Paid invoice")
      end


      it "raises proper exception if no file found" do
        spec_with_wrong_file = spec.gsub("./spec/support/sample_subspec.txt", "./spec/support/wrong_file.txt")
        result = subject.preprocess_code(spec_with_wrong_file)
        result = subject.remove_comments(result)
        expect { subject.load_external_files(result) }.to raise_exception(Parser::IncludedFileNotFound)
        
      end

      it "removes all lines that are comments (begins with '#' sign)" do
        result = subject.preprocess_code(spec)
        result = subject.remove_comments(result)      
        result.last.should == "3. Section \"Other information\""
      end
    end
  end
end