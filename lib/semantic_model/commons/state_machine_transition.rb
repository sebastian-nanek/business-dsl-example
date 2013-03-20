module SemanticModel::Commons::StateMachineTransition
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ :source, :target, :state_machine]

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def initialize(resource, data = {})
    data = data.with_indifferent_access
    @resource = resource
    @source = data[:source]
    @target = data[:target]
    raise SemanticModel::InvalidStateMachineTransition.new "No source state provided for state machine transition." if @source.nil?
    raise SemanticModel::InvalidStateMachineTransition.new "No target state provided for state machine transition." if @target.nil?
  end
end