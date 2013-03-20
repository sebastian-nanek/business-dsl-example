class SemanticModel::Stubs::Base
  include SemanticModel::Commons::Base

  begin :attributes
    attr_accessor :name
    attr_accessor :data
  end


  def initialize(name, options = {})
    @name = name
    @identifier = name.to_s.downcase.parameterize            
    @data = options.with_indifferent_access[:data] || []
    @errors = {}   
  end

  def stub?
    true
  end
end