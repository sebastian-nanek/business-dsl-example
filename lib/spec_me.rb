$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module SpecMe
  begin :exceptions
    class RuntimeException < Exception; end
    class ExternalProgramError < Exception; end
  end

  autoload :Application, 'spec_me/application'
  autoload :Utils, 'spec_me/utils'
end