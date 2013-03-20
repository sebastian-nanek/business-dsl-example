$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module SemanticModel::Commons
  autoload :Base, 'commons/base'
  autoload :Resource, 'commons/resource'  
  autoload :Report, 'commons/report'  
  autoload :Role, 'commons/role'  
  autoload :StateMachine, 'commons/state_machine'  
  autoload :StateMachineTransition, 'commons/state_machine_transition'  
  autoload :AccessRule, 'commons/access_rule'   
  autoload :ResourceField, 'commons/resource_field'  
  autoload :ResourceValidation, 'commons/resource_validation'  
  autoload :ResourceRelation, 'commons/resource_relation'  
end