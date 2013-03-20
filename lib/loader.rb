$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'semantic_model' ) )
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'symbol_table' ) )
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'spec_me' ) )
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'parser' ) )
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'generator' ) )

%w{active_support erb json active_support/all}.each do |lib|
  require lib
end

autoload :Parser, 'parser'
autoload :SemanticModel, 'semantic_model'
autoload :SymbolTable, 'symbol_table'
autoload :SpecMe, 'spec_me'
autoload :Generator, 'generator'