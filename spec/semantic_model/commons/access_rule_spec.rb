require 'spec_helper'

describe SemanticModel::Commons::AccessRule do
  context "at class level" do
    subject { SemanticModel::Commons::AccessRule }
    let(:all_available_rights) {  
      { 
        :can_destroy => true,
        :can_change => true,
        :can_list => true,
        :can_view => true,
        :can_create => true
      }
    }

    it "should properly map an one-element array of existing rule names" do
      access_rule = [ "destroy" ]
      subject.map_access_rights(access_rule).should == { :can_destroy => true }
    end

    it "should properly map array of existing rule names" do
      access_rule = [ "destroy", "create", "view", "change", "list" ]
      rule_map = subject.map_access_rights(access_rule)
      rule_map.should == all_available_rights
    end

    it "maps manage access right to all rights" do
      access_rule = [ "manage" ]
      rule_map = subject.map_access_rights(access_rule)
      rule_map.should == all_available_rights
    end

    it "should raise Exception if invalid access rule provided" do
      access_rule = [ "destroy", "create", "navigate" ]
      expect { subject.map_access_rights(access_rule) }.to raise_exception SemanticModel::UnknownRightRule      
    end

    it "should raise Exception if no access rule provided" do
      access_rule = [  ]
      expect { subject.map_access_rights(access_rule) }.to raise_exception SemanticModel::EmptyRightsRule
    end
  end

end