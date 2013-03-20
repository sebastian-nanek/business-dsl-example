require 'spec_helper'

describe SemanticModel::Commons::StateMachine do
  context "at class level" do
    subject { SemanticModel::Commons::StateMachine }
    
    it "maps states from string to array" do
      sample_states = '"pending", "awaiting" and "completed"'
      subject.map_states(sample_states).should == %w{pending awaiting completed}
      sample_states = '"pending", "awaiting"'
      subject.map_states(sample_states).should == %w{pending awaiting}
    end
  end
end