require 'spec_helper'

describe SemanticModel::Stubs::Report do
  context "with initialized object" do
    subject { SemanticModel::Stubs::Report.new "Sample model element" }
    let(:filtered_fields) { [ :title, :volumes ]}
    let(:criteria) { { :author => {:equal => "Umberto Eco"} } }

    it "can be destubized" do
      subject.filtered_fields = filtered_fields
      subject.criteria = criteria
      element = subject.destubize!
      element.name.should == subject.name
      element.filtered_fields.length.should == 2
      element.filtered_fields.first.should == :title
      element.criteria[:author].should == criteria[:author]
    end
  end
end