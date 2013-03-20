$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), './' ) )

module Generator
  begin :exceptions
  end

  autoload :Base, 'generator/base'
  autoload :Template, 'generator/template'
end