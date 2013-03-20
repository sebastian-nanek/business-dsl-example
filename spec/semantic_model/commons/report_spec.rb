require 'spec_helper'

describe SemanticModel::Commons::Report do
  context "at class level" do
    subject { SemanticModel::Commons::Report }
    
    it "maps filtered fields from string to array" do
      sample_filters = '"author", "title" and "issbn"'
      subject.map_filters(sample_filters).should == %w{author issbn title}
      sample_filters = '"author", "title"'
      subject.map_filters(sample_filters).should == %w{author title}
    end

    it "maps criteria fields from string to appropriate hashes" do
      sample_criteria = [
        ["volumes", "greater than", "3"],
        ["author", "equal to", "Umberto Eco"], 
        ["issue year", "less than or equal to", "1997"]
      ]
      subject.map_criteria(sample_criteria[0]).should == { "volumes" => { :greater => "3" } }
      subject.map_criteria(sample_criteria[1]).should == { "author" => { :equal => "Umberto Eco" } }
      subject.map_criteria(sample_criteria[2]).should == { "issue year" => { :less_or_equal => "1997" } }
    end

    it "merges criteria hashes with proper fields" do
      criteria = [ {"author" => { :equal => "Gabriel Garcia Marquez"}}, {"year" => {:greater => "2009"}}]
      expect { subject.merge_criteria(criteria) }.not_to raise_exception
      subject.merge_criteria(criteria).should == {"author" => { :equal => "Gabriel Garcia Marquez"}, "year" => {:greater => "2009"}}
      criteria = [ {"author" => { :equal => "Gabriel Garcia Marquez"}}, {"year" => {:greater => "2000"}}, {"year" => {:less_or_equal => "2012"}}]
      subject.merge_criteria(criteria).should == {"author" => { :equal => "Gabriel Garcia Marquez"}, "year" => {:greater => "2000", :less_or_equal => "2012"}}
      criteria = [ {"author" => { :equal => "Gabriel Garcia Marquez"}}, {"year" => {:greater => "2000"}}, {"year" => {:less_or_equal => "2012"}}]
      expect { subject.merge_criteria(criteria) }.not_to raise_exception
    end

    it "raises exceptions if no merge possible" do      
      criteria = [ {"author" => { :equal => "Gabriel Garcia Marquez"}}, {"year" => {:greater => "2000"}}, {"year" => {:greater => "2012"}}]
      expect { subject.merge_criteria(criteria) }.to raise_exception(SemanticModel::ImpossibleReportCriteriaCombination)
    end
  end
end