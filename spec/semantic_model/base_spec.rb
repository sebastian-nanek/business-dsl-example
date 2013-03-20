require 'spec_helper'

describe SemanticModel::Base do
  it_should_behave_like "a container that allows defining rules"

  subject { SemanticModel::Base.new }
  let(:a_rule) { Parser::Rule.new(/Sample matcher/) }
  let(:an_object) { SemanticModel::Elements::Base.new("Sample object") }

  it "knows if is empty (noe rules and objects) or not" do
    subject.should be_empty
    subject.push(SemanticModel::Elements::Base.new("Test resource"))
    subject.should_not be_empty
  end

  it "allows pushing an instance of business element" do
    expect { subject.push an_object }.to change(subject.symbol_table, :size).by(1)
  end

  it "allows pushing an array of business elements" do
    arr = 3.times.collect { |i| obj = an_object.clone; obj.name += " #{i.to_s}"; obj}    
    expect { subject.push arr }.to change(subject.symbol_table, :size).by(3)
  end

  it "does not allow pushing non-element and non-array classes by raising an exception" do
    expect { subject.push Object.new }.to raise_exception(SemanticModel::InvalidObject)
  end

  context "with some custom rules" do
    subject { SemanticModel::Base.new(:rules => [ a_rule ]) }
    
    it "knows all its rules - default and customized" do
      subject.rules.should_not be_empty
      subject.rules.length.should == SemanticModel::Base.default_rules.length + 1
    end
  end

  context "at class level" do
    subject {SemanticModel::Base}
    
    it "knows default rules" do
      SemanticModel::Base.default_rules.should_not be_empty
    end
  end
end