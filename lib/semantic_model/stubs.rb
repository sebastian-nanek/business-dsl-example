$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module SemanticModel::Stubs
  autoload :Base, 'stubs/base'
  autoload :Resource, 'stubs/resource'
  autoload :Report, 'stubs/report'
  autoload :Role, 'stubs/role'  
  autoload :StateMachine, 'stubs/state_machine'  

#  autoload :StateMachineTransition, 'stubs/state_machine_transition'  
#  autoload :ResourceRelation, 'stubs/resource_relation'   
#  autoload :AccessRule, 'stubs/access_rule'  
#  autoload :ResourceValidation, 'stubs/resource_validation'   
end