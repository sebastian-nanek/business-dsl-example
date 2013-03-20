$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module SemanticModel::Elements
  autoload :Base, 'elements/base'
  autoload :Resource, 'elements/resource'  
  autoload :ResourceField, 'elements/resource_field'  
  autoload :Report, 'elements/report'  
  autoload :Role, 'elements/role'  
  autoload :StateMachine, 'elements/state_machine'  
  autoload :StateMachineTransition, 'elements/state_machine_transition'
  autoload :AccessRule, 'elements/access_rule'  
  autoload :ResourceRelation, 'elements/resource_relation'   
  autoload :ResourceValidation, 'elements/resource_validation'   
end