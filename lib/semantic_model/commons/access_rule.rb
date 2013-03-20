module SemanticModel::Commons::AccessRule
  extend ActiveSupport::Concern

  OBJECT_ATTRIBUTES = [ 
    :role, :resource, 
    :can_view, :can_create, :can_change, :can_destroy, :can_list
  ]
  ACCESS_RIGHTS = [ :view, :create, :change, :destroy, :list ]

  included do
    OBJECT_ATTRIBUTES.each do |attr_name|
      attr_accessor attr_name
    end    
  end

  def initialize(resource, data)    
    data = data.with_indifferent_access
    @resource = resource || data[:resource]
    @access_rules = data[:access_rules]

    data = data.with_indifferent_access
    OBJECT_ATTRIBUTES.each do |attr|
      var = "@#{attr}"
      unless instance_variable_defined?(var)
        instance_variable_set(var, data[attr])
      end
    end 
  end
  
  def self.map_access_rights(rights_as_array)
    rights = {}
    rights_as_array.each do |access_rule|
      if access_rule.to_sym == :manage
        ACCESS_RIGHTS.each do |right_name|
          rights["can_#{right_name}".to_sym] = true        
        end
      elsif ACCESS_RIGHTS.include?(access_rule.to_sym)
        rights["can_#{access_rule}".to_sym] = true
      else
        raise SemanticModel::UnknownRightRule.new "Unknown access rights rule provided: #{access_rule}."
      end      
    end

    if rights.empty? or rights_as_array.empty?     
      raise SemanticModel::EmptyRightsRule.new "No access rights rule provided."
    end

    rights
  end
end