module SemanticModel::Commons::StateMachine
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :states, :transitions, :base_resource ]

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def initialize(resource, data = {})
    data = data.with_indifferent_access

    @base_resource = resource
    @states = data[:states]
    @transitions = data[:transitions]
  end

  # map a list of sates provided as string into an array 
  # of strings representing  each state name
  def self.map_states(states_as_string)    
    states = states_as_string.split(/and|,/).map(&:strip).collect do |state_string|
      state_string.gsub('"', '')
    end
    states
  end
end