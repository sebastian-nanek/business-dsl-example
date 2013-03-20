$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module SemanticModel
  begin :exceptions
    # meta exception
    class ImpossibleMerge < Exception; end
    class InvalidObject < Exception; end

    # exceptions for specific objects
    class InvalidFieldType < Exception; end
    class UnknownRightRule < Exception; end
    class EmptyRightsRule < Exception; end
    class InvalidStateMachineTransition < Exception; end
    class InvalidValidationType < Exception; end
    class UnknownValidation < Exception; end
    class UnknownReportCriteria < Exception; end
    class ImpossibleReportCriteriaCombination < Exception; end
  end

  autoload :Base, 'semantic_model/base'
  autoload :DefiningRules, 'semantic_model/defining_rules'
  autoload :DefaultRules, 'semantic_model/default_rules'

  autoload :Commons, 'semantic_model/commons'
  autoload :Elements, 'semantic_model/elements'
  autoload :Stubs, 'semantic_model/stubs'
end
